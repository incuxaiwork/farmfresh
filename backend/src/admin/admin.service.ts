import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { AdminCreateProductDto } from './dto/admin-create-product.dto';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getDashboard() {
    const [
      totalCustomers,
      totalFarmers,
      totalDeliveryPartners,
      totalProducts,
      totalOrders,
      activeOrders,
      completedOrders,
      cancelledOrders,
      totalRevenue,
      pendingWithdrawals,
      pendingFarmerApprovals,
      lowStockProducts,
      ordersByStatusRaw,
      monthlyRevenueRaw,
    ] = await Promise.all([
      this.prisma.user.count({ where: { role: 'CUSTOMER', deletedAt: null } }),
      this.prisma.user.count({ where: { role: 'FARMER', deletedAt: null } }),
      this.prisma.user.count({ where: { role: 'DELIVERY_PARTNER', deletedAt: null } }),
      this.prisma.product.count({ where: { deletedAt: null } }),
      this.prisma.order.count(),
      this.prisma.order.count({ where: { status: { in: ['PENDING', 'CONFIRMED', 'ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY'] as any } } }),
      this.prisma.order.count({ where: { status: { in: ['COMPLETED', 'DELIVERED'] as any } } }),
      this.prisma.order.count({ where: { status: 'CANCELLED' as any } }),
      this.prisma.order.aggregate({ _sum: { total: true }, where: { status: { in: ['COMPLETED', 'DELIVERED'] as any } } }),
      this.prisma.withdrawal.count({ where: { status: 'PENDING' } }),
      this.prisma.farmerProfile.count({ where: { kycStatus: 'PENDING' as any } }),
      this.prisma.inventory.count({ where: { status: { in: ['LOW_STOCK', 'OUT_OF_STOCK'] as any } } }),
      this.prisma.order.groupBy({
        by: ['status'],
        _count: { id: true },
      }),
      this.prisma.$queryRaw<any[]>`
        SELECT 
          strftime('%Y-%m', "created_at" / 1000, 'unixepoch') as month,
          COALESCE(SUM("total"), 0) as "revenue"
        FROM "orders"
        WHERE "created_at" >= (strftime('%s', 'now', '-12 months') * 1000)
          AND "status" IN ('COMPLETED', 'DELIVERED')
        GROUP BY strftime('%Y-%m', "created_at" / 1000, 'unixepoch')
        ORDER BY month ASC
      `,
    ]);

    const recentOrders = await this.prisma.order.findMany({
      take: 10,
      orderBy: { createdAt: 'desc' },
      include: {
        customer: { select: { name: true, email: true } },
        items: { include: { product: { select: { name: true } } } },
      },
    });

    const topProducts = await this.prisma.product.findMany({
      take: 5,
      where: { deletedAt: null },
      orderBy: { soldCount: 'desc' },
      select: { id: true, name: true, soldCount: true, rating: true, price: true },
    });

    const topFarmers = await this.prisma.farmerProfile.findMany({
      take: 5,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        farmName: true,
        user: { select: { name: true } },
        products: { select: { soldCount: true, rating: true, price: true } },
      },
    });

    return {
      stats: {
        totalRevenue: Number(totalRevenue._sum.total || 0),
        todaySales: 0,
        monthlySales: 0,
        totalOrders,
        activeCustomers: totalCustomers,
        activeFarmers: totalFarmers,
        deliveryPartners: totalDeliveryPartners,
        pendingProductApprovals: 0,
        pendingFarmerApprovals,
        lowInventory: lowStockProducts,
        activeDeliveries: activeOrders,
      },
      recentOrders: recentOrders.map((o) => ({
        ...o,
        customerName: o.customer?.name,
        totalAmount: Number(o.total),
      })),
      topSellingProducts: topProducts.map((p) => ({
        name: p.name,
        count: p.soldCount,
        revenue: Number(p.price) * p.soldCount,
      })),
      topFarmers: topFarmers.map((f) => ({
        name: f.user?.name || f.farmName,
        orders: f.products.reduce((sum, p) => sum + p.soldCount, 0),
        revenue: f.products.reduce((sum, p) => sum + (Number(p.price || 0) * p.soldCount), 0),
      })),
      monthlyRevenue: monthlyRevenueRaw,
      ordersByStatus: ordersByStatusRaw.map(o => ({
        status: o.status,
        count: o._count.id,
      })),
    };
  }

  async getStatistics(filters: { period?: string; startDate?: string; endDate?: string }) {
    const where: any = {};
    const now = new Date();

    if (filters.startDate) {
      where.createdAt = { ...where.createdAt, gte: new Date(filters.startDate) };
    }
    if (filters.endDate) {
      where.createdAt = { ...where.createdAt, lte: new Date(filters.endDate) };
    }
    if (filters.period === 'today') {
      const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      where.createdAt = { gte: startOfDay };
    } else if (filters.period === 'week') {
      const startOfWeek = new Date(now);
      startOfWeek.setDate(now.getDate() - 7);
      where.createdAt = { gte: startOfWeek };
    } else if (filters.period === 'month') {
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      where.createdAt = { gte: startOfMonth };
    }

    const ordersByStatus = await this.prisma.order.groupBy({
      by: ['status'],
      _count: { id: true },
      _sum: { total: true },
      where,
    });

    const revenueByMonth = await this.prisma.$queryRaw`
      SELECT 
        strftime('%Y-%m', "created_at" / 1000, 'unixepoch') as month,
        COUNT(*) as "orderCount",
        COALESCE(SUM("total"), 0) as "revenue"
      FROM "orders"
      WHERE "created_at" >= (strftime('%s', 'now', '-12 months') * 1000)
        AND "status" IN ('COMPLETED', 'DELIVERED')
      GROUP BY strftime('%Y-%m', "created_at" / 1000, 'unixepoch')
      ORDER BY month ASC
    `;

    return {
      ordersByStatus,
      revenueByMonth: (revenueByMonth as any[]).map(r => ({
        ...r,
        orderCount: Number(r.orderCount)
      }))
    };
  }

  async getCustomers(filters: { search?: string; status?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = { role: 'CUSTOMER', deletedAt: null };
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search } },
        { email: { contains: filters.search } },
        { phone: { contains: filters.search } },
      ];
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          role: true,
          deletedAt: true,
          createdAt: true,
          _count: { select: { orders: true } },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      items: users.map(u => ({
        ...u,
        isActive: !u.deletedAt,
      })),
      total, page, limit, totalPages: Math.ceil(total / limit),
    };
  }

  async updateCustomerStatus(id: string, status: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('Customer not found');
    if (user.role !== 'CUSTOMER') throw new BadRequestException('User is not a customer');

    return { success: true };
  }

  async getFarmers(filters: { search?: string; kycStatus?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = { role: 'FARMER' };
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search } },
        { email: { contains: filters.search } },
      ];
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          role: true,
          deletedAt: true,
          createdAt: true,
          addresses: { select: { addressLine1: true, city: true, state: true }, take: 1 },
          farmerProfile: {
            select: {
              id: true,
              farmName: true,
              farmAddress: true,
              kycStatus: true,
              kycDocUrl: true,
              _count: { select: { products: true } },
              bankAccount: {
                select: {
                  bankName: true,
                  accountNumber: true,
                  routingNumber: true,
                },
              },
              products: {
                select: {
                  _count: { select: { orderItems: true } },
                  orderItems: { select: { total: true } },
                },
              },
            },
          },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    let filtered = users;
    if (filters.kycStatus) {
      filtered = users.filter(u => u.farmerProfile?.kycStatus === filters.kycStatus);
    }

    const items = filtered.map(u => {
      const fp = u.farmerProfile;
      const totalOrders = fp?.products?.reduce((sum, p) => sum + p._count.orderItems, 0) || 0;
      const totalRevenue = fp?.products?.reduce((sum, p) =>
        sum + p.orderItems.reduce((s, oi) => s + Number(oi.total), 0), 0) || 0;

      return {
        id: u.id,
        name: u.name,
        email: u.email,
        phone: u.phone,
        role: u.role,
        createdAt: u.createdAt,
        isActive: !u.deletedAt,
        avatar: null,
        farmName: fp?.farmName || '',
        farmAddress: fp?.farmAddress || '',
        productCount: fp?._count.products || 0,
        status: u.deletedAt ? 'SUSPENDED' : (fp?.kycStatus || 'PENDING'),
        kycStatus: fp?.kycStatus || 'PENDING',
        address: u.addresses?.[0] ? `${u.addresses[0].addressLine1}, ${u.addresses[0].city}, ${u.addresses[0].state}` : '',
        totalOrders,
        totalRevenue,
        farmDetails: {
          name: fp?.farmName || '',
          location: fp?.farmAddress || '',
          size: '',
          crops: [],
          certifications: [],
        },
        bankAccount: fp?.bankAccount ? {
          accountHolder: u.name,
          accountNumber: fp.bankAccount.accountNumber,
          ifscCode: fp.bankAccount.routingNumber,
          bankName: fp.bankAccount.bankName,
        } : { accountHolder: u.name, accountNumber: '', ifscCode: '', bankName: '' },
      };
    });

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async approveFarmer(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { farmerProfile: true },
    });
    if (!user || user.role !== 'FARMER') throw new NotFoundException('Farmer not found');
    if (!user.farmerProfile) throw new BadRequestException('Farmer has no profile');

    await this.prisma.farmerProfile.update({
      where: { id: user.farmerProfile.id },
      data: { kycStatus: 'APPROVED' as any },
    });

    return { success: true };
  }

  async rejectFarmer(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { farmerProfile: true },
    });
    if (!user || user.role !== 'FARMER') throw new NotFoundException('Farmer not found');
    if (!user.farmerProfile) throw new BadRequestException('Farmer has no profile');

    await this.prisma.farmerProfile.update({
      where: { id: user.farmerProfile.id },
      data: { kycStatus: 'REJECTED' as any },
    });

    return { success: true };
  }

  async suspendFarmer(id: string) {
    await this.prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
    return { success: true };
  }

  async getDeliveryPartners(filters: { search?: string; status?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = { role: 'DELIVERY_PARTNER' };
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search } },
        { email: { contains: filters.search } },
        { phone: { contains: filters.search } },
      ];
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          role: true,
          deletedAt: true,
          createdAt: true,
          _count: { select: { deliveries: true } },
          deliveries: {
            select: {
              status: true,
              distance: true,
              deliveryCharge: true,
              deliveredTime: true,
              deliveryStartTime: true,
            },
          },
          addresses: { select: { addressLine1: true, city: true, state: true }, take: 1 },
        },
      }),
      this.prisma.user.count({ where }),
    ]);

    const items = users.map(u => {
      const completedDeliveries = u.deliveries.filter(d => d.status === 'DELIVERED').length;
      const totalDistance = u.deliveries.reduce((sum, d) => sum + Number(d.distance || 0), 0);
      const totalEarnings = u.deliveries
        .filter(d => d.status === 'DELIVERED')
        .reduce((sum, d) => sum + Number(d.deliveryCharge || 0), 0);

      const onTimeDeliveries = u.deliveries.filter(d => {
        if (d.status !== 'DELIVERED' || !d.deliveryStartTime || !d.deliveredTime) return false;
        const duration = new Date(d.deliveredTime).getTime() - new Date(d.deliveryStartTime).getTime();
        return duration <= 60 * 60 * 1000;
      }).length;
      const onTimePercentage = completedDeliveries > 0
        ? Math.round((onTimeDeliveries / completedDeliveries) * 100)
        : 0;

      const avgTimeMinutes = completedDeliveries > 0
        ? Math.round(u.deliveries
            .filter(d => d.status === 'DELIVERED' && d.deliveryStartTime && d.deliveredTime)
            .reduce((sum, d, _, arr) => {
              const dur = (new Date(d.deliveredTime!).getTime() - new Date(d.deliveryStartTime!).getTime()) / 60000;
              return sum + dur / arr.length;
            }, 0))
        : 0;

      return {
        id: u.id,
        name: u.name,
        email: u.email,
        phone: u.phone,
        role: u.role,
        createdAt: u.createdAt,
        isActive: !u.deletedAt,
        isAvailable: !u.deletedAt,
        status: u.deletedAt ? 'SUSPENDED' : 'ACTIVE',
        vehicleType: 'Bike',
        vehicleNumber: 'N/A',
        licenseNumber: 'N/A',
        completedDeliveries,
        rating: 0,
        avgRating: 0,
        onTimePercentage,
        averageDeliveryTime: avgTimeMinutes,
        totalDistance: Math.round(totalDistance),
        totalEarnings,
        address: u.addresses?.[0] ? `${u.addresses[0].addressLine1}, ${u.addresses[0].city}, ${u.addresses[0].state}` : '',
        joinedAt: u.createdAt,
      };
    });

    let filtered = items;
    if (filters.status) {
      filtered = items.filter(i => i.status === filters.status);
    }

    return { items: filtered, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async suspendDeliveryPartner(id: string) {
    await this.prisma.user.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
    return { success: true };
  }

  async activateDeliveryPartner(id: string) {
    await this.prisma.user.update({
      where: { id },
      data: { deletedAt: null },
    });
    return { success: true };
  }

  async getOrders(filters: { search?: string; status?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.status) where.status = filters.status as any;
    if (filters.search) {
      where.OR = [
        { orderNumber: { contains: filters.search } },
        { address: { contains: filters.search } },
        { customer: { name: { contains: filters.search } } },
      ];
    }

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: { select: { name: true, email: true, phone: true } },
          items: { include: { product: { select: { name: true, unit: true } } } },
          payment: { select: { status: true, method: true } },
        },
      }),
      this.prisma.order.count({ where }),
    ]);

    const items = orders.map(o => ({
      id: o.id,
      orderNumber: o.orderNumber,
      customerId: o.customerId,
      customerName: o.customer?.name,
      customer: {
        name: o.customer?.name || '',
        email: o.customer?.email || '',
        phone: o.customer?.phone || '',
      },
      items: o.items.map(oi => ({
        id: oi.id,
        productId: oi.productId,
        productName: oi.product?.name || '',
        name: oi.product?.name || '',
        unit: oi.product?.unit || '',
        quantity: oi.quantity,
        unitPrice: Number(oi.price),
        price: Number(oi.price),
        total: Number(oi.total),
        totalPrice: Number(oi.total),
        farmerId: oi.farmerId,
      })),
      itemCount: o.items.length,
      subtotal: Number(o.subtotal),
      deliveryFee: Number(o.deliveryFee),
      tax: 0,
      discount: Number(o.discount),
      total: Number(o.total),
      totalAmount: Number(o.total),
      status: o.status,
      paymentStatus: o.payment?.status || 'PENDING',
      address: o.address,
      shippingAddress: {
        street: o.address || '',
        city: '',
        state: '',
        zipCode: '',
        phone: o.customer?.phone || '',
      },
      statusHistory: [],
      specialInstructions: o.notes || '',
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getCoupons(filters: { search?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.search) {
      where.code = { contains: filters.search };
    }

    const [coupons, total] = await Promise.all([
      this.prisma.coupon.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.coupon.count({ where }),
    ]);

    const items = coupons.map(c => ({
      ...c,
      discountValue: Number(c.value),
      value: Number(c.value),
      maxUses: c.usageLimit || 0,
      usageLimit: c.usageLimit || 0,
      minOrderAmount: Number(c.minOrderAmount),
      isActive: new Date(c.expiresAt) > new Date(),
      description: '',
      maxDiscountAmount: null,
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async createCoupon(dto: any) {
    const existing = await this.prisma.coupon.findUnique({ where: { code: dto.code.toUpperCase() } });
    if (existing) throw new ConflictException('Coupon code already exists');

    return this.prisma.coupon.create({
      data: {
        code: dto.code.toUpperCase(),
        discountType: dto.discountType,
        value: dto.discountValue || dto.value || 0,
        minOrderAmount: dto.minOrderAmount || 0,
        expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
        usageLimit: dto.maxUses || dto.usageLimit || 100,
      },
    });
  }

  async updateCoupon(id: string, dto: any) {
    const coupon = await this.prisma.coupon.findUnique({ where: { id } });
    if (!coupon) throw new NotFoundException('Coupon not found');

    if (dto.code && dto.code.toUpperCase() !== coupon.code) {
      const existing = await this.prisma.coupon.findUnique({ where: { code: dto.code.toUpperCase() } });
      if (existing) throw new ConflictException('Coupon code already exists');
    }

    return this.prisma.coupon.update({
      where: { id },
      data: {
        code: dto.code ? dto.code.toUpperCase() : undefined,
        discountType: dto.discountType,
        value: dto.discountValue ?? dto.value ?? undefined,
        minOrderAmount: dto.minOrderAmount,
        expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : undefined,
        usageLimit: dto.maxUses ?? dto.usageLimit ?? undefined,
      },
    });
  }

  async deleteCoupon(id: string) {
    const coupon = await this.prisma.coupon.findUnique({ where: { id } });
    if (!coupon) throw new NotFoundException('Coupon not found');

    await this.prisma.coupon.delete({ where: { id } });
    return { success: true };
  }

  async createProduct(dto: AdminCreateProductDto) {
    // Check if farmer exists
    const farmerProfile = await this.prisma.farmerProfile.findUnique({
      where: { id: dto.farmerId },
    });
    if (!farmerProfile) {
      throw new NotFoundException('Farmer profile not found');
    }

    if (dto.discountPrice !== undefined && dto.discountPrice >= dto.price) {
      throw new BadRequestException('Discount price must be strictly less than base price');
    }

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

    if (dto.harvestDate && dto.expiryDate) {
      const harvest = new Date(dto.harvestDate);
      const expiry = new Date(dto.expiryDate);
      if (expiry <= harvest) {
        throw new BadRequestException('Expiry date must be set after harvest date');
      }
    }

    const slug = dto.slug ? dto.slug.toLowerCase().trim() : dto.name.toLowerCase().trim().replace(/[^a-z0-9\s-]/g, '').replace(/\s+/g, '-');
    const duplicate = await this.prisma.product.findUnique({ where: { slug } });
    if (duplicate) {
      throw new ConflictException('Product slug already exists');
    }

    return this.prisma.$transaction(async (tx) => {
      const product = await tx.product.create({
        data: {
          farmerId: dto.farmerId,
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
          status: 'APPROVED',
          harvestDate: dto.harvestDate ? new Date(dto.harvestDate) : null,
          expiryDate: dto.expiryDate ? new Date(dto.expiryDate) : null,
          inventory: {
            create: {
              currentStock: dto.stock,
              farmerId: dto.farmerId,
            },
          },
        },
      });

      return product;
    });
  }

  async getProducts(filters: { search?: string; status?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = { deletedAt: null };
    if (filters.status) where.status = filters.status as any;
    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search } },
      ];
    }

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          images: { select: { imageUrl: true, isPrimary: true }, take: 1 },
          category: { select: { name: true } },
          inventory: { select: { currentStock: true } },
          farmer: { select: { farmName: true } },
        },
      }),
      this.prisma.product.count({ where }),
    ]);

    const items = products.map(p => ({
      id: p.id,
      name: p.name,
      description: p.description,
      price: Number(p.price),
      discountPrice: p.discountPrice ? Number(p.discountPrice) : null,
      category: p.category?.name || '',
      categoryId: p.categoryId,
      stock: p.inventory ? Number(p.inventory.currentStock) : 0,
      unit: p.unit,
      farmerId: p.farmerId,
      farmerName: p.farmer?.farmName || '',
      imageUrl: p.images?.[0]?.imageUrl || null,
      images: p.images.map(i => ({ id: i.imageUrl, url: i.imageUrl, isPrimary: i.isPrimary })),
      status: p.status,
      isFeatured: p.featured,
      isActive: p.status !== 'DRAFT' && p.status !== 'ARCHIVED',
      rating: Number(p.rating),
      reviewCount: p.reviewCount,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getInventory(filters: { search?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.search) {
      where.OR = [
        { product: { name: { contains: filters.search } } },
        { farmer: { farmName: { contains: filters.search } } },
      ];
    }

    const [inventory, total] = await Promise.all([
      this.prisma.inventory.findMany({
        where,
        skip,
        take: limit,
        orderBy: { currentStock: 'asc' },
        include: {
          product: { select: { name: true, unit: true } },
          farmer: { select: { farmName: true } },
        },
      }),
      this.prisma.inventory.count({ where }),
    ]);

    const items = inventory.map(i => ({
      id: i.id,
      productId: i.productId,
      productName: i.product?.name || '',
      farmerId: i.farmerId,
      farmerName: i.farmer?.farmName || '',
      currentStock: Number(i.currentStock),
      unit: i.product?.unit || '',
      minStock: Number(i.minStockLevel),
      maxStock: Number(i.maxStockLevel),
      reorderLevel: Number(i.reorderLevel),
      status: i.status,
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getBanners(filters: { page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const [banners, total] = await Promise.all([
      this.prisma.banner.findMany({
        where: {},
        skip,
        take: limit,
        orderBy: { displayOrder: 'asc' },
      }),
      this.prisma.banner.count(),
    ]);

    return { items: banners, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async createBanner(dto: any) {
    return this.prisma.banner.create({
      data: {
        title: dto.title,
        subtitle: dto.subtitle,
        imageUrl: dto.imageUrl,
        linkUrl: dto.linkUrl,
        displayOrder: dto.displayOrder || 0,
        isActive: dto.isActive !== false,
        startDate: dto.startDate ? new Date(dto.startDate) : null,
        endDate: dto.endDate ? new Date(dto.endDate) : null,
      },
    });
  }

  async updateBanner(id: string, dto: any) {
    const banner = await this.prisma.banner.findUnique({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');

    return this.prisma.banner.update({
      where: { id },
      data: {
        title: dto.title,
        subtitle: dto.subtitle,
        imageUrl: dto.imageUrl,
        linkUrl: dto.linkUrl,
        displayOrder: dto.displayOrder,
        isActive: dto.isActive,
        startDate: dto.startDate ? new Date(dto.startDate) : undefined,
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
      },
    });
  }

  async deleteBanner(id: string) {
    const banner = await this.prisma.banner.findUnique({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');

    await this.prisma.banner.delete({ where: { id } });
    return { success: true };
  }

  async getNotifications(filters: { page?: number; limit?: number; role?: string }) {
    const page = filters.page || 1;
    const limit = filters.limit || 50;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.role) {
      where.user = { role: filters.role as any };
    }

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { user: { select: { name: true, email: true, role: true } } },
      }),
      this.prisma.notification.count({ where }),
    ]);

    const items = notifications.map(n => ({
      ...n,
      targetRole: n.user?.role || 'ALL',
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async sendNotification(dto: { title: string; body: string; targetType?: string; targetValue?: string; type?: string; targetRole?: string }) {
    const targetRole = dto.targetRole || dto.targetValue || 'ALL';
    const where: any = { deletedAt: null };

    if (targetRole && targetRole !== 'ALL') {
      where.role = targetRole as any;
    }

    const users = await this.prisma.user.findMany({
      where,
      select: { id: true },
    });

    if (users.length === 0) throw new BadRequestException('No target users found');

    const data = users.map(u => ({
      userId: u.id,
      type: (dto.type || 'SYSTEM') as any,
      title: dto.title,
      body: dto.body,
    }));

    await this.prisma.notification.createMany({ data });

    return { sent: users.length };
  }

  async getSettings() {
    const settings = await this.prisma.platformSetting.findMany();
    const settingsObj: Record<string, string> = {};
    settings.forEach(s => { settingsObj[s.key] = s.value; });
    return settingsObj;
  }

  async updateSettings(dto: Record<string, string>) {
    const updates = Object.entries(dto).map(([key, value]) =>
      this.prisma.platformSetting.upsert({
        where: { key },
        update: { value: String(value) },
        create: { key, value: String(value) },
      })
    );

    await Promise.all(updates);
    return { success: true };
  }

  async getAuditLogs(filters: { action?: string; entity?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.action) where.action = { contains: filters.action };
    if (filters.entity) where.action = { contains: filters.entity };

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { user: { select: { name: true, email: true } } },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    const items = logs.map(l => ({
      ...l,
      userName: l.user?.name || 'System',
      entity: l.action.split('_')[0] || 'SYSTEM',
      entityId: l.metadata?.split(':')[1] || '',
      details: l.metadata || '',
      description: l.metadata || l.action,
      ip: l.ipAddress || '',
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getCmsContent() {
    const items = await this.prisma.cmsContent.findMany({ orderBy: { key: 'asc' } });
    return items;
  }

  async updateCmsContent(key: string, dto: { title?: string; content?: string }) {
    return this.prisma.cmsContent.upsert({
      where: { key },
      update: {
        title: dto.title,
        content: dto.content,
      },
      create: {
        key,
        title: dto.title || key,
        content: dto.content || '',
      },
    });
  }

  async getReviews(filters: { status?: string; search?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.status) where.status = filters.status as any;

    const [reviews, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          product: { select: { name: true } },
          user: { select: { name: true, email: true } },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    const items = reviews.map(r => ({
      ...r,
      customerId: r.userId,
      customerName: r.user?.name || '',
      productName: r.product?.name || '',
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async moderateReview(id: string, action: 'approve' | 'reject' | 'flag') {
    const review = await this.prisma.review.findUnique({ where: { id } });
    if (!review) throw new NotFoundException('Review not found');

    const statusMap: Record<string, any> = {
      approve: 'APPROVED',
      reject: 'REJECTED',
      flag: 'PENDING_MODERATION',
    };

    return this.prisma.review.update({
      where: { id },
      data: { status: statusMap[action] as any },
    });
  }

  async getPayouts(filters: { status?: string; search?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.status) where.status = filters.status as any;

    const [payouts, total] = await Promise.all([
      this.prisma.withdrawal.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: { user: { select: { name: true, email: true } } },
      }),
      this.prisma.withdrawal.count({ where }),
    ]);

    const items = payouts.map(p => ({
      ...p,
      amount: Number(p.amount),
      farmerId: p.userId,
      farmerName: p.user?.name || '',
      status: p.status,
      period: '',
      bankAccount: '',
      createdAt: p.createdAt,
      processedAt: p.processedAt,
    }));

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async processPayout(id: string) {
    const payout = await this.prisma.withdrawal.findUnique({ where: { id } });
    if (!payout) throw new NotFoundException('Payout not found');
    if (payout.status !== 'PENDING') throw new BadRequestException('Payout is not pending');

    return this.prisma.withdrawal.update({
      where: { id },
      data: {
        status: 'TRANSFERRED' as any,
        processedAt: new Date(),
      },
    });
  }

  async getDeliveries(filters: { search?: string; status?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (filters.status) where.status = filters.status as any;
    if (filters.search) {
      where.order = {
        orderNumber: { contains: filters.search },
      };
    }

    const [deliveries, total] = await Promise.all([
      this.prisma.deliveryAssignment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          order: {
            select: {
              id: true,
              orderNumber: true,
              total: true,
              address: true,
            },
          },
          driver: {
            select: { name: true, email: true },
          },
        },
      }),
      this.prisma.deliveryAssignment.count({ where }),
    ]);

    return { items: deliveries, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getOrderIssues(filters: { status?: string; page?: number; limit?: number }) {
    const page = filters.page || 1;
    const limit = filters.limit || 20;

    return { items: [], total: 0, page, limit, totalPages: 0 };
  }

  async resolveIssue(id: string, resolution: string) {
    return { id, resolution, status: 'RESOLVED' };
  }
}
