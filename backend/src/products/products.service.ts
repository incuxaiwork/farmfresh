import { Injectable, NotFoundException, ConflictException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  private _generateSlug(name: string): string {
    return name
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-');
  }

  private async _getFarmerProfileId(userId: string): Promise<string> {
    const profile = await this.prisma.farmerProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new ForbiddenException('A verified Farmer Profile is required to manage products');
    }
    return profile.id;
  }

  async create(userId: string, dto: CreateProductDto) {
    const farmerId = await this._getFarmerProfileId(userId);

    // Business checks: discount vs price
    if (dto.discountPrice !== undefined && dto.discountPrice >= dto.price) {
      throw new BadRequestException('Discount price must be strictly less than base price');
    }

    // Category exists check
    const category = await this.prisma.category.findUnique({ where: { id: dto.categoryId } });
    if (!category) {
      throw new NotFoundException('Category not found');
    }

    if (dto.subCategoryId) {
      const sub = await this.prisma.category.findUnique({ where: { id: dto.subCategoryId } });
      if (!sub) {
        throw new NotFoundException('Sub category not found');
      }
    }

    // Date validators
    if (dto.harvestDate && dto.expiryDate) {
      const harvest = new Date(dto.harvestDate);
      const expiry = new Date(dto.expiryDate);
      if (expiry <= harvest) {
        throw new BadRequestException('Expiry date must be set after harvest date');
      }
    }

    const slug = dto.slug ? dto.slug.toLowerCase().trim() : this._generateSlug(dto.name);
    const duplicate = await this.prisma.product.findUnique({ where: { slug } });
    if (duplicate) {
      throw new ConflictException('Product slug already exists');
    }

    // Prisma Transaction to create product and inventory together
    return this.prisma.$transaction(async (tx) => {
      const product = await tx.product.create({
        data: {
          farmerId,
          categoryId: dto.categoryId,
          subCategoryId: dto.subCategoryId,
          name: dto.name,
          slug,
          description: dto.description,
          shortDescription: dto.shortDescription,
          price: dto.price,
          discountPrice: dto.discountPrice,
          unit: dto.unit,
          minOrderQty: dto.minOrderQty ?? 1,
          maxOrderQty: dto.maxOrderQty ?? 10,
          organic: dto.organic ?? false,
          featured: dto.featured ?? false,
          seasonal: dto.seasonal ?? false,
          status: 'APPROVED' as any, // Default to APPROVED in this sandbox
          harvestDate: dto.harvestDate ? new Date(dto.harvestDate) : null,
          expiryDate: dto.expiryDate ? new Date(dto.expiryDate) : null,
          inventory: {
            create: {
              currentStock: dto.stock,
              farmerId,
            },
          },
        },
      });

      return product;
    });
  }

  async findAll(filters: {
    status?: 'APPROVED' | 'DRAFT' | 'PENDING_APPROVAL' | 'REJECTED' | 'ARCHIVED';
    categoryId?: string;
    subCategoryId?: string;
    farmerId?: string;
    minPrice?: number;
    maxPrice?: number;
    organic?: boolean;
    featured?: boolean;
    seasonal?: boolean;
    search?: string;
    sortBy?: 'price' | 'popularity' | 'newest' | 'rating' | 'sold';
    sortOrder?: 'asc' | 'desc';
    role?: string;
  }) {
    const where: any = {
      deletedAt: null,
    };

    // Access control check: Customers can ONLY read approved products
    if (filters.role === 'CUSTOMER') {
      where.status = 'APPROVED' as any;
    } else if (filters.status) {
      where.status = filters.status as any;
    }

    if (filters.categoryId) where.categoryId = filters.categoryId;
    if (filters.subCategoryId) where.subCategoryId = filters.subCategoryId;
    if (filters.farmerId) where.farmerId = filters.farmerId;
    if (filters.organic !== undefined) where.organic = filters.organic;
    if (filters.featured !== undefined) where.featured = filters.featured;
    if (filters.seasonal !== undefined) where.seasonal = filters.seasonal;

    const minPriceNum = filters.minPrice !== undefined && !isNaN(Number(filters.minPrice)) ? Number(filters.minPrice) : undefined;
    const maxPriceNum = filters.maxPrice !== undefined && !isNaN(Number(filters.maxPrice)) ? Number(filters.maxPrice) : undefined;

    if (minPriceNum !== undefined || maxPriceNum !== undefined) {
      where.price = {};
      if (minPriceNum !== undefined) where.price.gte = minPriceNum;
      if (maxPriceNum !== undefined) where.price.lte = maxPriceNum;
    }

    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search } },
        { description: { contains: filters.search } },
      ];
    }

    const orderBy: any = {};
    const sortField = filters.sortBy ?? 'newest';
    if (sortField === 'price') {
      orderBy.price = filters.sortOrder ?? 'asc';
    } else if (sortField === 'popularity') {
      orderBy.viewCount = filters.sortOrder ?? 'desc';
    } else if (sortField === 'rating') {
      orderBy.rating = filters.sortOrder ?? 'desc';
    } else if (sortField === 'sold') {
      orderBy.soldCount = filters.sortOrder ?? 'desc';
    } else {
      orderBy.createdAt = filters.sortOrder ?? 'desc';
    }

    return this.prisma.product.findMany({
      where,
      orderBy,
      include: {
        category: true,
        images: true,
        inventory: true,
        farmer: {
          select: { farmName: true },
        },
      },
    });
  }

  async findOne(id: string, userRole?: string) {
    const product = await this.prisma.product.findFirst({
      where: { id, deletedAt: null },
      include: {
        category: true,
        images: true,
        inventory: true,
        farmer: true,
      },
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    if (userRole === 'CUSTOMER' && product.status !== ('APPROVED' as any)) {
      throw new ForbiddenException('You are not authorized to view this product');
    }

    // Increment viewCount asynchronously
    await this.prisma.product.update({
      where: { id },
      data: { viewCount: { increment: 1 } },
    });

    return product;
  }

  async update(productId: string, userId: string, userRole: string, dto: UpdateProductDto) {
    const product = await this.findOne(productId);

    // Authorization checks
    if (userRole !== 'ADMIN') {
      const farmerId = await this._getFarmerProfileId(userId);
      if (product.farmerId !== farmerId) {
        throw new ForbiddenException('You can only update your own products');
      }
    }

    const updateData: any = {};

    if (dto.name) {
      updateData.name = dto.name;
      if (!dto.slug) {
        updateData.slug = this._generateSlug(dto.name);
      }
    }

    if (dto.slug) {
      updateData.slug = dto.slug.toLowerCase().trim();
    }

    // Duplicate check
    if (updateData.slug) {
      const duplicate = await this.prisma.product.findFirst({
        where: { id: { not: productId }, slug: updateData.slug },
      });
      if (duplicate) {
        throw new ConflictException('Product slug already exists');
      }
    }

    if (dto.price !== undefined) {
      updateData.price = dto.price;
    }

    if (dto.discountPrice !== undefined) {
      updateData.discountPrice = dto.discountPrice;
    }

    // Cross-validate prices
    const targetPrice = dto.price ?? Number(product.price);
    const targetDiscount = dto.discountPrice ?? (product.discountPrice ? Number(product.discountPrice) : undefined);

    if (targetDiscount !== undefined && targetDiscount >= targetPrice) {
      throw new BadRequestException('Discount price must be less than base price');
    }

    if (dto.categoryId) {
      const category = await this.prisma.category.findUnique({ where: { id: dto.categoryId } });
      if (!category) throw new NotFoundException('Category not found');
      updateData.categoryId = dto.categoryId;
    }

    if (dto.subCategoryId !== undefined) updateData.subCategoryId = dto.subCategoryId;
    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.shortDescription !== undefined) updateData.shortDescription = dto.shortDescription;
    if (dto.unit !== undefined) updateData.unit = dto.unit;
    if (dto.minOrderQty !== undefined) updateData.minOrderQty = dto.minOrderQty;
    if (dto.maxOrderQty !== undefined) updateData.maxOrderQty = dto.maxOrderQty;
    if (dto.organic !== undefined) updateData.organic = dto.organic;
    if (dto.featured !== undefined) updateData.featured = dto.featured;
    if (dto.seasonal !== undefined) updateData.seasonal = dto.seasonal;
    if ((dto as any).status !== undefined) {
      updateData.status = userRole === 'FARMER' ? 'APPROVED' as any : (dto as any).status;
    }

    if (dto.harvestDate !== undefined) updateData.harvestDate = dto.harvestDate ? new Date(dto.harvestDate) : null;
    if (dto.expiryDate !== undefined) updateData.expiryDate = dto.expiryDate ? new Date(dto.expiryDate) : null;

    // Transaction to update product fields and stock if modified
    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.product.update({
        where: { id: productId },
        data: updateData,
      });

      if ((dto as any).stock !== undefined) {
        await tx.inventory.update({
          where: { productId },
          data: { currentStock: (dto as any).stock },
        });
      }

      return updated;
    });
  }

  async remove(productId: string, userId: string, userRole: string) {
    const product = await this.findOne(productId);

    if (userRole !== 'ADMIN') {
      const farmerId = await this._getFarmerProfileId(userId);
      if (product.farmerId !== farmerId) {
        throw new ForbiddenException('You can only delete your own products');
      }
    }

    // Soft delete
    return this.prisma.product.update({
      where: { id: productId },
      data: {
        deletedAt: new Date(),
        status: 'ARCHIVED' as any,
      },
    });
  }

  async getFeatured() {
    return this.prisma.product.findMany({
      where: { featured: true, status: 'APPROVED' as any, deletedAt: null },
      include: { images: true, inventory: true },
      take: 10,
    });
  }

  async getPopular() {
    return this.prisma.product.findMany({
      where: { status: 'APPROVED' as any, deletedAt: null },
      include: { images: true, inventory: true },
      orderBy: { viewCount: 'desc' },
      take: 10,
    });
  }

  async updateStatus(productId: string, status: 'APPROVED' | 'REJECTED' | 'DRAFT' | 'PENDING_APPROVAL' | 'ARCHIVED') {
    await this.findOne(productId);
    return this.prisma.product.update({
      where: { id: productId },
      data: { status: status as any },
    });
  }

  async updateStock(productId: string, userId: string, userRole: string, stock: number) {
    const product = await this.findOne(productId);

    if (userRole !== 'ADMIN') {
      const farmerId = await this._getFarmerProfileId(userId);
      if (product.farmerId !== farmerId) {
        throw new ForbiddenException('You can only update your own product inventory');
      }
    }

    return this.prisma.inventory.update({
      where: { productId },
      data: { currentStock: stock },
    });
  }

  async updatePrice(productId: string, userId: string, userRole: string, price: number, discountPrice?: number) {
    const product = await this.findOne(productId);

    if (userRole !== 'ADMIN') {
      const farmerId = await this._getFarmerProfileId(userId);
      if (product.farmerId !== farmerId) {
        throw new ForbiddenException('You can only update your own product pricing');
      }
    }

    if (discountPrice !== undefined && discountPrice >= price) {
      throw new BadRequestException('Discount price must be less than price');
    }

    return this.prisma.product.update({
      where: { id: productId },
      data: { price, discountPrice: discountPrice ?? null },
    });
  }

  async addImages(productId: string, imageUrls: string[]) {
    await this.findOne(productId);

    const imageCreates = imageUrls.map((url, idx) => ({
      imageUrl: url,
      isPrimary: idx === 0,
    }));

    return this.prisma.product.update({
      where: { id: productId },
      data: {
        images: {
          createMany: {
            data: imageCreates,
          },
        },
      },
      include: { images: true },
    });
  }

  async uploadImage(productId: string, imageUrl: string) {
    const product = await this.findOne(productId);

    // Check if a primary image already exists
    const existingPrimary = await this.prisma.productImage.findFirst({
      where: { productId, isPrimary: true },
    });

    return this.prisma.product.update({
      where: { id: productId },
      data: {
        images: {
          create: {
            imageUrl,
            isPrimary: !existingPrimary,
          },
        },
      },
      include: { images: true },
    });
  }

  async deleteImage(productId: string, imageId: string) {
    await this.findOne(productId);

    // Delete image matching IDs
    await this.prisma.productImage.delete({
      where: { id: imageId },
    });

    return { success: true };
  }
}
