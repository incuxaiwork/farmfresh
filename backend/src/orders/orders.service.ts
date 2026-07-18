import { Injectable, NotFoundException, BadRequestException, ForbiddenException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import { OrderPricingService } from './pricing.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  constructor(
    private prisma: PrismaService,
    private pricingService: OrderPricingService,
    private configService: ConfigService,
  ) {}

  private _generateOrderNumber(): string {
    const timestamp = Date.now().toString().slice(-6);
    const rand = Math.floor(1000 + Math.random() * 9000).toString();
    return `ORD-${timestamp}-${rand}`;
  }

  private _generateOtpCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async create(customerId: string, dto: CreateOrderDto) {
    // Load cart
    const cart = await this.prisma.cart.findUnique({
      where: { userId: customerId },
      include: {
        items: {
          include: {
            product: {
              include: { inventory: true },
            },
          },
        },
      },
    });

    if (!cart || cart.items.length === 0) {
      throw new BadRequestException('Cannot place order: Shopping cart is empty');
    }

    // Validate stock and status
    for (const item of cart.items) {
      const product = item.product;
      if (product.status !== ('APPROVED' as any)) {
        throw new BadRequestException(`Cannot place order: Product "${product.name}" is unapproved`);
      }

      const current = product.inventory ? Number(product.inventory.currentStock) : 0;
      const reserved = product.inventory ? Number(product.inventory.reservedStock) : 0;
      const available = current - reserved;

      if (available < item.quantity) {
        throw new BadRequestException(`Insufficient stock: Product "${product.name}" has only ${available} available units`);
      }
    }

    // Format items for pricing calculation
    const pricingItems = cart.items.map(item => ({
      quantity: item.quantity,
      price: Number(item.unitPrice),
      discountPrice: item.product.discountPrice ? Number(item.product.discountPrice) : null,
    }));

    const totals = this.pricingService.calculate(pricingItems);
    const orderNumber = this._generateOrderNumber();
    const otpCode = this._generateOtpCode();

    return this.prisma.$transaction(async (tx) => {
      // Create Order
      const order = await tx.order.create({
        data: {
          orderNumber,
          customerId,
          subtotal: totals.subtotal,
          discount: totals.discount,
          deliveryFee: totals.deliveryFee,
          total: totals.total,
          otpCode,
          address: dto.address || 'Delivery address not provided',
          customerLatitude: dto.customerLatitude ?? null,
          customerLongitude: dto.customerLongitude ?? null,
          notes: dto.notes || null,
          status: 'PENDING' as any,
          paymentStatus: 'PENDING' as any,
        },
      });

      // Create Order Items and Reserve Stock
      for (const item of cart.items) {
        const itemDiscount = item.product.discountPrice 
          ? (Number(item.unitPrice) - Number(item.product.discountPrice)) * item.quantity
          : 0;

        await tx.orderItem.create({
          data: {
            orderId: order.id,
            productId: item.productId,
            farmerId: item.farmerId,
            quantity: item.quantity,
            price: item.unitPrice,
            discount: itemDiscount,
            total: Number(item.totalPrice) - itemDiscount,
            status: 'PENDING' as any,
          },
        });

        // Reserve stock
        if (item.product.inventory) {
          await tx.inventory.update({
            where: { productId: item.productId },
            data: {
              reservedStock: {
                increment: item.quantity,
              },
            },
          });
        }
      }

      // Clear cart
      await tx.cartItem.deleteMany({ where: { cartId: cart.id } });
      await tx.cart.update({
        where: { id: cart.id },
        data: {
          subtotal: 0.00,
          discount: 0.00,
          tax: 0.00,
          deliveryCharge: 0.00,
          grandTotal: 0.00,
        },
      });

      // Snapshot farmer coordinates from the first farmer in the order
      const firstFarmerId = cart.items[0]?.farmerId;
      if (firstFarmerId) {
        const farmerProfile = await tx.farmerProfile.findUnique({
          where: { id: firstFarmerId },
          select: { farmLatitude: true, farmLongitude: true },
        });
        if (farmerProfile?.farmLatitude && farmerProfile?.farmLongitude) {
          await tx.order.update({
            where: { id: order.id },
            data: {
              farmerLatitude: farmerProfile.farmLatitude,
              farmerLongitude: farmerProfile.farmLongitude,
            },
          });
        }
      }

      return order;
    }, { timeout: 30000 });
  }

  async findAll(
    userId: string,
    role: string,
    filters: {
      status?: string;
      farmerId?: string;
      customerId?: string;
      sortBy?: 'newest' | 'oldest' | 'amount';
    },
  ) {
    const where: any = {};

    if (role === 'CUSTOMER') {
      where.customerId = userId;
    } else if (role === 'FARMER') {
      const farmer = await this.prisma.farmerProfile.findUnique({ where: { userId } });
      if (!farmer) throw new ForbiddenException('Farmer profile required');
      where.items = {
        some: { farmerId: farmer.id },
      };
    }

    if (filters.status) where.status = filters.status as any;
    if (filters.customerId && role === 'ADMIN') where.customerId = filters.customerId;

    const orderBy: any = {};
    if (filters.sortBy === 'oldest') {
      orderBy.createdAt = 'asc';
    } else if (filters.sortBy === 'amount') {
      orderBy.total = 'desc';
    } else {
      orderBy.createdAt = 'desc';
    }

    return this.prisma.order.findMany({
      where,
      orderBy,
      include: {
        items: {
          include: { product: true },
        },
        customer: {
          select: { name: true, email: true },
        },
      },
    });
  }

  async findOne(id: string, userId: string, role: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        items: { include: { product: true } },
        customer: { select: { name: true, email: true } },
      },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    // Access checks
    if (role === 'CUSTOMER' && order.customerId !== userId) {
      throw new ForbiddenException('Access denied to view this order');
    }

    if (role === 'FARMER') {
      const farmer = await this.prisma.farmerProfile.findUnique({ where: { userId } });
      if (!farmer) throw new ForbiddenException('Farmer profile required');
      const ownsItem = order.items.some(i => i.farmerId === farmer.id);
      if (!ownsItem) {
        throw new ForbiddenException('Access denied: Order contains no items from your farm');
      }
    }

    return order;
  }

  async updateStatus(
    id: string,
    userId: string,
    role: string,
    status: 'PENDING' | 'CONFIRMED' | 'ACCEPTED' | 'REJECTED' | 'PREPARING' | 'READY_FOR_PICKUP' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED' | 'COMPLETED',
  ) {
    const order = await this.findOne(id, userId, role);

    return this.prisma.$transaction(async (tx) => {
      // Admin update
      if (role === 'ADMIN') {
        const updated = await tx.order.update({
          where: { id },
          data: { status: status as any },
        });

        // Handle inventory deductions on confirmation or cancellations
        if (status === 'CONFIRMED') {
          for (const item of order.items) {
            await tx.inventory.update({
              where: { productId: item.productId },
              data: {
                currentStock: { decrement: item.quantity },
                reservedStock: { decrement: item.quantity },
              },
            });
          }
        } else if (status === 'CANCELLED') {
          for (const item of order.items) {
            await tx.inventory.update({
              where: { productId: item.productId },
              data: {
                reservedStock: { decrement: item.quantity },
              },
            });
          }
        }

        return updated;
      }

      // Farmer updates (Farmers update sub-items status)
      if (role === 'FARMER') {
        const farmer = await tx.farmerProfile.findUnique({ where: { userId } });
        if (!farmer) throw new ForbiddenException('Farmer profile required');

        // Update items belonging to this farmer
        await tx.orderItem.updateMany({
          where: {
            orderId: id,
            farmerId: farmer.id,
          },
          data: { status: status as any },
        });

        // If status is REJECTED or CANCELLED, release reserved stock immediately for these items
        if (status === 'REJECTED' || status === 'CANCELLED') {
          const rejectedItems = order.items.filter(i => i.farmerId === farmer.id);
          for (const item of rejectedItems) {
            await tx.inventory.update({
              where: { productId: item.productId },
              data: {
                reservedStock: { decrement: item.quantity },
              },
            });
          }
        }

        // Re-read order items to see if main order status can progress
        const allItems = await tx.orderItem.findMany({ where: { orderId: id } });
        const allAccepted = allItems.every(i => i.status === ('ACCEPTED' as any));
        const allPreparing = allItems.every(i => i.status === ('PREPARING' as any) || i.status === ('READY_FOR_PICKUP' as any));
        const allReady = allItems.every(i => i.status === ('READY_FOR_PICKUP' as any));
        const anyCancelled = allItems.some(i => i.status === ('CANCELLED' as any) || i.status === ('REJECTED' as any));

        let nextMainStatus: string | null = null;
        if (anyCancelled) {
          nextMainStatus = 'CANCELLED';
        } else if (allReady) {
          nextMainStatus = 'READY_FOR_PICKUP';
        } else if (allPreparing) {
          nextMainStatus = 'PREPARING';
        } else if (allAccepted) {
          nextMainStatus = 'ACCEPTED';
        }

        if (nextMainStatus) {
          await tx.order.update({
            where: { id },
            data: { status: nextMainStatus as any },
          });
        }

        // Trigger automatic progression if the order is now ACCEPTED and fully handled
        if (nextMainStatus === 'ACCEPTED') {
          this._autoProgressOrder(id).catch(err => this.logger.error(`Auto progress failed for order ${id}`, err));
        }

        return tx.order.findUnique({
          where: { id },
          include: { items: true },
        });
      }

      throw new BadRequestException('Role not authorized to update order status');
    }, { timeout: 15000 });
  }

  async cancel(id: string, userId: string, role: string) {
    const order = await this.findOne(id, userId, role);

    if (role === 'CUSTOMER' && order.customerId !== userId) {
      throw new ForbiddenException('You can only cancel your own orders');
    }

    if (order.status !== ('PENDING' as any)) {
      throw new BadRequestException('Cannot cancel order that has already been accepted/confirmed');
    }

    return this.prisma.$transaction(async (tx) => {
      // Update main status and item statuses
      const updated = await tx.order.update({
        where: { id },
        data: { status: 'CANCELLED' as any },
      });

      await tx.orderItem.updateMany({
        where: { orderId: id },
        data: { status: 'CANCELLED' as any },
      });

      // Release reserved stocks
      for (const item of order.items) {
        await tx.inventory.update({
          where: { productId: item.productId },
          data: {
            reservedStock: { decrement: item.quantity },
          },
        });
      }

      return updated;
    });
  }

  private async _autoProgressOrder(orderId: string) {
    const delayMs = this.configService.get<number>('orders.transitionDelayMs') || 120000;
    const stages = ['PREPARING', 'READY_FOR_PICKUP', 'DELIVERED'];

    this.logger.log(`Starting auto-progression for order ${orderId} (delay: ${delayMs}ms)`);

    for (const stage of stages) {
      await new Promise(resolve => setTimeout(resolve, delayMs));

      // Check if order was cancelled in the meantime
      const currentOrder = await this.prisma.order.findUnique({ where: { id: orderId } });
      if (!currentOrder || currentOrder.status === 'CANCELLED' || currentOrder.status === 'REJECTED') {
        this.logger.log(`Auto-progression halted for order ${orderId} as it was cancelled/rejected.`);
        return;
      }

      await this.prisma.$transaction(async (tx) => {
        await tx.order.update({
          where: { id: orderId },
          data: { status: stage as any },
        });

        await tx.orderItem.updateMany({
          where: { orderId: orderId },
          data: { status: stage as any },
        });
      });

      this.logger.log(`Order ${orderId} automatically transitioned to ${stage}`);
    }
  }
}
