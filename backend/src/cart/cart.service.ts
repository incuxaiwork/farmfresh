import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { PricingService } from './pricing.service';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';

@Injectable()
export class CartService {
  constructor(
    private prisma: PrismaService,
    private pricingService: PricingService,
  ) {}

  private async _getOrCreateCart(userId: string) {
    let cart = await this.prisma.cart.findUnique({
      where: { userId },
      include: {
        items: {
          include: {
            product: {
              select: {
                id: true,
                name: true,
                price: true,
                discountPrice: true,
                unit: true,
                status: true,
                minOrderQty: true,
                maxOrderQty: true,
                inventory: { select: { currentStock: true, reservedStock: true } },
              },
            },
          },
        },
      },
    });

    if (!cart) {
      cart = await this.prisma.cart.create({
        data: { userId },
        include: {
          items: {
            include: {
              product: {
                select: {
                  id: true,
                  name: true,
                  price: true,
                  discountPrice: true,
                  unit: true,
                  status: true,
                  minOrderQty: true,
                  maxOrderQty: true,
                  inventory: { select: { currentStock: true, reservedStock: true } },
                },
              },
            },
          },
        },
      });
    }

    return cart;
  }

  private async _recalculateCart(cartId: string, tx: any) {
    const items = await tx.cartItem.findMany({
      where: { cartId },
      include: { product: true },
    });

    // Format items for pricing calculation
    const pricingItems = items.map((item: any) => ({
      quantity: item.quantity,
      unitPrice: Number(item.unitPrice),
      discountPrice: item.product.discountPrice ? Number(item.product.discountPrice) : null,
    }));

    const totals = this.pricingService.calculate(pricingItems);

    return tx.cart.update({
      where: { id: cartId },
      data: {
        subtotal: totals.subtotal,
        discount: totals.discount,
        tax: totals.tax,
        deliveryCharge: totals.deliveryCharge,
        grandTotal: totals.grandTotal,
      },
      include: {
        items: {
          include: { product: true },
        },
      },
    });
  }

  async getCart(userId: string) {
    return this._getOrCreateCart(userId);
  }

  async addItem(userId: string, dto: AddCartItemDto) {
    const cart = await this._getOrCreateCart(userId);

    // Fetch product details
    const product = await this.prisma.product.findUnique({
      where: { id: dto.productId, deletedAt: null },
      include: { inventory: true },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    if (product.status !== ('APPROVED' as any)) {
      throw new BadRequestException('Cannot add unapproved products to cart');
    }

    const availableStock = product.inventory 
      ? Number(product.inventory.currentStock) - Number(product.inventory.reservedStock) 
      : 0;
    if (availableStock <= 0) {
      throw new BadRequestException('Product is currently out of stock');
    }

    // Check existing item in cart
    const existingItem = (cart.items as any[]).find(i => i.productId === dto.productId);
    const targetQuantity = (existingItem?.quantity ?? 0) + dto.quantity;

    if (targetQuantity > availableStock) {
      throw new BadRequestException(`Insufficient stock: Only ${availableStock} units available`);
    }

    if (targetQuantity < product.minOrderQty) {
      throw new BadRequestException(`Quantity must satisfy minimum order limit of ${product.minOrderQty} units`);
    }

    if (targetQuantity > product.maxOrderQty) {
      throw new BadRequestException(`Quantity exceeds maximum order limit of ${product.maxOrderQty} units`);
    }

    const price = Number(product.price);
    const total = price * targetQuantity;

    return this.prisma.$transaction(async (tx) => {
      if (existingItem) {
        await tx.cartItem.update({
          where: { id: existingItem.id },
          data: {
            quantity: targetQuantity,
            totalPrice: total,
          },
        });
      } else {
        await tx.cartItem.create({
          data: {
            cartId: cart.id,
            productId: dto.productId,
            farmerId: product.farmerId,
            quantity: dto.quantity,
            unitPrice: price,
            totalPrice: total,
          },
        });
      }

      return this._recalculateCart(cart.id, tx);
    });
  }

  async updateItem(userId: string, itemId: string, dto: UpdateCartItemDto) {
    const cart = await this._getOrCreateCart(userId);
    const item = (cart.items as any[]).find(i => i.id === itemId);

    if (!item) {
      throw new NotFoundException('Cart item not found');
    }

    // Fetch stock info
    const product = await this.prisma.product.findUnique({
      where: { id: item.productId },
      include: { inventory: true },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    const availableStock = product.inventory 
      ? Number(product.inventory.currentStock) - Number(product.inventory.reservedStock) 
      : 0;
    if (dto.quantity > availableStock) {
      throw new BadRequestException(`Insufficient stock: Only ${availableStock} units available`);
    }

    if (dto.quantity < product.minOrderQty) {
      throw new BadRequestException(`Quantity must satisfy minimum order limit of ${product.minOrderQty} units`);
    }

    if (dto.quantity > product.maxOrderQty) {
      throw new BadRequestException(`Quantity exceeds maximum order limit of ${product.maxOrderQty} units`);
    }

    const price = Number(item.unitPrice);
    const total = price * dto.quantity;

    return this.prisma.$transaction(async (tx) => {
      await tx.cartItem.update({
        where: { id: itemId },
        data: {
          quantity: dto.quantity,
          totalPrice: total,
        },
      });

      return this._recalculateCart(cart.id, tx);
    });
  }

  async removeItem(userId: string, itemId: string) {
    const cart = await this._getOrCreateCart(userId);
    const item = (cart.items as any[]).find(i => i.id === itemId);

    if (!item) {
      throw new NotFoundException('Cart item not found');
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.cartItem.delete({
        where: { id: itemId },
      });

      return this._recalculateCart(cart.id, tx);
    });
  }

  async clearCart(userId: string) {
    const cart = await this._getOrCreateCart(userId);

    return this.prisma.$transaction(async (tx) => {
      await tx.cartItem.deleteMany({
        where: { cartId: cart.id },
      });

      return tx.cart.update({
        where: { id: cart.id },
        data: {
          subtotal: 0.00,
          discount: 0.00,
          tax: 0.00,
          deliveryCharge: 0.00,
          grandTotal: 0.00,
        },
        include: { items: true },
      });
    });
  }
}
