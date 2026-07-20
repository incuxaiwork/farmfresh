import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class FarmerService {
  constructor(private prisma: PrismaService) {}

  async getDashboard(userId: string) {
    const farmer = await this.prisma.farmerProfile.findUnique({ where: { userId } });
    if (!farmer) throw new NotFoundException('Farmer profile not found');

    const farmerId = farmer.id;

    const products = await this.prisma.product.findMany({
      where: { farmerId, deletedAt: null },
      include: { inventory: true }
    });

    let activeProducts = 0;
    let outOfStockProducts = 0;
    for (const p of products) {
      if (p.status === 'ACTIVE') activeProducts++;
      if (p.inventory && Number(p.inventory.currentStock) <= 0) outOfStockProducts++;
    }

    const orderItems = await this.prisma.orderItem.findMany({
      where: { farmerId },
      include: { order: { select: { status: true, createdAt: true } } }
    });

    let pendingOrders = 0;
    let acceptedOrders = 0;
    let deliveredOrders = 0;
    let totalRevenue = 0;
    let todaySales = 0;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const item of orderItems) {
      const status = item.order.status;
      if (status === 'PENDING') pendingOrders++;
      else if (status === 'ACCEPTED' || status === 'PREPARING' || status === 'READY_FOR_PICKUP') acceptedOrders++;
      else if (status === 'DELIVERED') deliveredOrders++;

      if (status === 'DELIVERED' || status === 'COMPLETED') {
        const amt = Number(item.total);
        totalRevenue += amt;
        if (new Date(item.order.createdAt) >= today) {
          todaySales += amt;
        }
      }
    }

    return {
      todaySales,
      totalRevenue,
      pendingOrders,
      acceptedOrders,
      deliveredOrders,
      activeProducts,
      outOfStockProducts,
      monthlyRevenue: [],
      weeklyOrders: [],
      unreadNotifications: 0,
    };
  }

  async getStatistics(userId: string) {
    const farmer = await this.prisma.farmerProfile.findUnique({ where: { userId } });
    if (!farmer) throw new NotFoundException('Farmer profile not found');

    const farmerId = farmer.id;

    const productsCount = await this.prisma.product.count({
      where: { farmerId, deletedAt: null }
    });

    const orderItems = await this.prisma.orderItem.findMany({
      where: { farmerId },
      include: { order: { select: { status: true, createdAt: true } } }
    });

    let totalEarnings = 0;
    let monthlyEarnings = 0;
    let weeklyEarnings = 0;
    let dailyEarnings = 0;

    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(now.getFullYear(), now.getMonth(), now.getDate() - now.getDay());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    for (const item of orderItems) {
      const status = item.order.status;
      if (status === 'DELIVERED' || status === 'COMPLETED') {
        const amt = Number(item.total);
        totalEarnings += amt;
        
        const date = new Date(item.order.createdAt);
        if (date >= startOfMonth) monthlyEarnings += amt;
        if (date >= startOfWeek) weeklyEarnings += amt;
        if (date >= startOfDay) dailyEarnings += amt;
      }
    }

    const withdrawals = await this.prisma.withdrawal.findMany({
      where: { userId: farmer.userId }
    });

    let pendingWithdrawals = 0;
    let completedWithdrawals = 0;
    for (const w of withdrawals) {
      if (w.status === 'PENDING') pendingWithdrawals += Number(w.amount);
      if (w.status === 'TRANSFERRED' || w.status === 'APPROVED') completedWithdrawals += Number(w.amount);
    }

    const orderIds = new Set(orderItems.map(oi => oi.orderId));
    
    return {
      totalEarnings,
      monthlyEarnings,
      weeklyEarnings,
      dailyEarnings,
      pendingWithdrawals,
      completedWithdrawals,
      totalOrders: orderIds.size,
      totalProducts: productsCount,
    };
  }

  async getTransactions(userId: string, page: number = 1, limit: number = 10) {
    const farmer = await this.prisma.farmerProfile.findUnique({ where: { userId } });
    if (!farmer) throw new NotFoundException('Farmer profile not found');

    const farmerId = farmer.id;

    const earnings = await this.prisma.farmerEarning.findMany({
      where: { farmerId },
      include: {
        farmer: true
      }
    });

    const withdrawals = await this.prisma.withdrawal.findMany({
      where: { userId }
    });

    const allTransactions = [
      ...earnings.map(e => ({
        id: e.id,
        type: 'CREDIT',
        amount: Number(e.amount),
        description: `Earnings from Order`,
        status: 'COMPLETED',
        createdAt: e.createdAt,
        orderId: e.orderId
      })),
      ...withdrawals.map(w => ({
        id: w.id,
        type: 'DEBIT',
        amount: Number(w.amount),
        description: `Withdrawal to Bank`,
        status: w.status,
        createdAt: w.createdAt,
        orderId: null
      }))
    ];

    allTransactions.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    const startIndex = (page - 1) * limit;
    const paginated = allTransactions.slice(startIndex, startIndex + limit);

    return paginated;
  }

  async updateLocation(userId: string, latitude: number, longitude: number) {
    const farmer = await this.prisma.farmerProfile.findUnique({ where: { userId } });
    if (!farmer) throw new NotFoundException('Farmer profile not found');

    return this.prisma.farmerProfile.update({
      where: { userId },
      data: {
        farmLatitude: latitude,
        farmLongitude: longitude,
      },
    });
  }
}