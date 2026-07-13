import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { DeliveryGateway } from './delivery.gateway';
import { AssignDriverDto } from './dto/assign-driver.dto';
import { UpdateLocationDto } from './dto/update-location.dto';

@Injectable()
export class DeliveryService {
  constructor(
    private prisma: PrismaService,
    private trackingGateway: DeliveryGateway,
  ) {}

  private async _verifyDriverRole(driverId: string) {
    const driver = await this.prisma.user.findUnique({
      where: { id: driverId },
    });

    if (!driver || driver.role !== ('DELIVERY_PARTNER' as any)) {
      throw new BadRequestException('Target user is not registered as a Delivery Partner');
    }
    return driver;
  }

  private async _checkAssignmentOwnership(assignmentId: string, userId: string, role: string) {
    const assignment = await this.prisma.deliveryAssignment.findFirst({
      where: {
        OR: [
          { id: assignmentId },
          { orderId: assignmentId },
        ],
      },
      include: { order: true },
    });

    if (!assignment) {
      throw new NotFoundException('Delivery assignment record not found');
    }

    if (role !== 'ADMIN' && assignment.driverId !== userId) {
      throw new ForbiddenException('Access denied: You are not assigned to this delivery');
    }

    return assignment;
  }

  async assignDriver(dto: AssignDriverDto) {
    await this._verifyDriverRole(dto.driverId);

    const order = await this.prisma.order.findUnique({
      where: { id: dto.orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    // Check duplicate active assignment
    const existing = await this.prisma.deliveryAssignment.findUnique({
      where: { orderId: dto.orderId },
    });

    if (existing && existing.status !== ('REJECTED' as any)) {
      throw new BadRequestException('Order is already assigned to a delivery partner');
    }

    return this.prisma.$transaction(async (tx) => {
      const assignment = await tx.deliveryAssignment.upsert({
        where: { orderId: dto.orderId },
        update: {
          driverId: dto.driverId,
          status: 'ASSIGNED' as any,
          pickupTime: null,
          deliveryStartTime: null,
          deliveredTime: null,
        },
        create: {
          orderId: dto.orderId,
          driverId: dto.driverId,
          status: 'ASSIGNED' as any,
          deliveryCharge: 5.00, // Flat delivery reward
          distance: 3.5, // Mock distance estimation
        },
      });

      await tx.order.update({
        where: { id: dto.orderId },
        data: { status: 'CONFIRMED' as any },
      });

      return assignment;
    });
  }

  async findAll(
    userId: string,
    role: string,
    filters: {
      status?: 'PENDING_ASSIGNMENT' | 'ASSIGNED' | 'ACCEPTED' | 'REJECTED' | 'HEADING_TO_PICKUP' | 'PICKED_UP' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED';
      driverId?: string;
      search?: string;
    },
  ) {
    console.log(`[findAll] userId: ${userId}, role: ${role}, statusFilter: ${filters.status}`);
    if (role === 'DELIVERY_PARTNER' && (filters.status as string === 'PENDING' || filters.status === 'PENDING_ASSIGNMENT')) {
      // 1. Get assignments specifically assigned to this driver in ASSIGNED status
      const assignedRaw = await this.prisma.deliveryAssignment.findMany({
        where: {
          driverId: userId,
          status: 'ASSIGNED',
        },
        include: {
          order: {
            select: {
              orderNumber: true,
              total: true,
              address: true,
              customerId: true,
              customer: { select: { id: true, name: true, phone: true, email: true } },
            },
          },
          driver: {
            select: { name: true, phone: true },
          },
        },
      });

      const assignedToMe = assignedRaw.map(a => ({
        ...a,
        deliveryFee: a.deliveryCharge,
        customer: a.order.customer
          ? {
              id: a.order.customer.id,
              name: a.order.customer.name,
              phone: a.order.customer.phone,
              email: a.order.customer.email,
            }
          : null,
        deliveryAddress: a.order.address ? { fullAddress: a.order.address } : null,
      }));

      // 2. Get orders that need delivery and have no assignment
      const ordersWithoutAssignment = await this.prisma.order.findMany({
        where: {
          status: { in: ['CONFIRMED', 'ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP'] as any },
          delivery: null,
        },
        include: {
          customer: { select: { id: true, name: true, phone: true, email: true } },
        },
        orderBy: { createdAt: 'desc' },
      });

      const selfClaimable = ordersWithoutAssignment.map(o => ({
        id: o.id, // Order ID as mock assignment ID
        orderId: o.id,
        driverId: userId,
        status: 'PENDING_ASSIGNMENT',
        deliveryCharge: 5.00,
        deliveryFee: 5.00,
        distance: 3.5,
        createdAt: o.createdAt,
        updatedAt: o.updatedAt,
        order: {
          orderNumber: o.orderNumber,
          total: o.total,
          address: o.address,
          customerId: o.customerId,
        },
        customer: o.customer
          ? {
              id: o.customer.id,
              name: o.customer.name,
              phone: o.customer.phone,
              email: o.customer.email,
            }
          : null,
        deliveryAddress: o.address ? { fullAddress: o.address } : null,
        driver: null,
      }));

      return [...assignedToMe, ...selfClaimable];
    }

    const where: any = {};

    if (role === 'DELIVERY_PARTNER') {
      where.driverId = userId;
    } else if (role === 'CUSTOMER') {
      where.order = { customerId: userId };
    } else if (role !== 'ADMIN') {
      throw new ForbiddenException('Access denied');
    }

    if (filters.status) {
      if (filters.status as string === 'PENDING') {
        where.status = 'ASSIGNED';
      } else {
        where.status = filters.status as any;
      }
    }
    if (filters.driverId && role === 'ADMIN') where.driverId = filters.driverId;

    const assignments = await this.prisma.deliveryAssignment.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        order: {
          select: {
            orderNumber: true,
            total: true,
            address: true,
            customerId: true,
            customer: { select: { id: true, name: true, phone: true, email: true } },
          },
        },
        driver: {
          select: { name: true, phone: true },
        },
      },
    });

    return assignments.map(a => ({
      ...a,
      deliveryFee: a.deliveryCharge,
      customer: a.order.customer
        ? {
            id: a.order.customer.id,
            name: a.order.customer.name,
            phone: a.order.customer.phone,
            email: a.order.customer.email,
          }
        : null,
      deliveryAddress: a.order.address ? { fullAddress: a.order.address } : null,
    }));
  }

  async findOne(id: string, userId: string, role: string) {
    try {
      return await this._checkAssignmentOwnership(id, userId, role);
    } catch (err) {
      if (err instanceof NotFoundException) {
        // Check if this is an available Order without assignment
        const order = await this.prisma.order.findUnique({
          where: { id },
          include: {
            items: { include: { product: true } },
            customer: { select: { name: true, email: true } },
          },
        });
        if (order && ['CONFIRMED', 'ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP'].includes(order.status)) {
          return {
            id: order.id,
            orderId: order.id,
            driverId: userId,
            status: 'PENDING_ASSIGNMENT',
            deliveryCharge: 5.00,
            distance: 3.5,
            order,
          };
        }
      }
      throw err;
    }
  }

  async acceptDelivery(id: string, userId: string, role: string) {
    let assignment;
    try {
      assignment = await this._checkAssignmentOwnership(id, userId, role);
    } catch (err) {
      if (err instanceof NotFoundException) {
        // Check if this is a valid Order ID that doesn't have an assignment yet
        const order = await this.prisma.order.findUnique({
          where: { id },
        });
        if (!order) {
          throw new NotFoundException('Delivery assignment or order not found');
        }

        // Create a new delivery assignment for this driver!
        return this.prisma.$transaction(async (tx) => {
          const newAssignment = await tx.deliveryAssignment.create({
            data: {
              orderId: order.id,
              driverId: userId,
              status: 'ACCEPTED' as any,
              deliveryCharge: 5.00,
              distance: 3.5,
            },
          });

          await tx.order.update({
            where: { id: order.id },
            data: { status: 'ACCEPTED' as any },
          });

          return newAssignment;
        });
      }
      throw err;
    }

    if (assignment.status !== ('ASSIGNED' as any)) {
      throw new BadRequestException('Delivery assignment is not in ASSIGNED state');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id: assignment.id },
        data: { status: 'ACCEPTED' as any },
      });

      await tx.order.update({
        where: { id: assignment.orderId },
        data: { status: 'ACCEPTED' as any },
      });

      return updated;
    });
  }

  async rejectDelivery(id: string, userId: string, role: string) {
    let assignment;
    try {
      assignment = await this._checkAssignmentOwnership(id, userId, role);
    } catch (err) {
      if (err instanceof NotFoundException) {
        // Unassigned order: rejecting simply keeps it available for others.
        const order = await this.prisma.order.findUnique({ where: { id } });
        if (order) {
          return {
            id: order.id,
            orderId: order.id,
            driverId: userId,
            status: 'PENDING_ASSIGNMENT',
            deliveryCharge: 5.00,
            distance: 3.5,
            order,
          };
        }
      }
      throw err;
    }

    if (assignment.status !== ('ASSIGNED' as any)) {
      throw new BadRequestException('Delivery assignment cannot be rejected at this stage');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id },
        data: { status: 'REJECTED' as any },
      });

      await tx.order.update({
        where: { id: assignment.orderId },
        data: { status: 'REJECTED' as any },
      });

      return updated;
    });
  }

  async startPickup(id: string, userId: string, role: string) {
    const assignment = await this._checkAssignmentOwnership(id, userId, role);

    if (assignment.status !== ('ACCEPTED' as any)) {
      throw new BadRequestException('Must accept delivery assignment before heading to pickup');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id },
        data: { status: 'HEADING_TO_PICKUP' as any },
      });

      await tx.order.update({
        where: { id: assignment.orderId },
        data: { status: 'PREPARING' as any },
      });

      return updated;
    });
  }

  async confirmPickup(id: string, userId: string, role: string) {
    const assignment = await this._checkAssignmentOwnership(id, userId, role);

    if (assignment.status !== ('HEADING_TO_PICKUP' as any)) {
      throw new BadRequestException('Must be heading to pickup to confirm package retrieval');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id },
        data: {
          status: 'PICKED_UP' as any,
          pickupTime: new Date(),
        },
      });

      await tx.order.update({
        where: { id: assignment.orderId },
        data: { status: 'READY_FOR_PICKUP' as any },
      });

      return updated;
    });
  }

  async startDelivery(id: string, userId: string, role: string) {
    const assignment = await this._checkAssignmentOwnership(id, userId, role);

    if (assignment.status !== ('PICKED_UP' as any)) {
      throw new BadRequestException('Must pickup package before starting transit');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id },
        data: {
          status: 'OUT_FOR_DELIVERY' as any,
          deliveryStartTime: new Date(),
        },
      });

      await tx.order.update({
        where: { id: assignment.orderId },
        data: { status: 'OUT_FOR_DELIVERY' as any },
      });

      return updated;
    });
  }

  async updateLocation(id: string, userId: string, role: string, dto: UpdateLocationDto) {
    await this._checkAssignmentOwnership(id, userId, role);

    const updated = await this.prisma.deliveryAssignment.update({
      where: { id },
      data: {
        currentLat: dto.latitude,
        currentLng: dto.longitude,
      },
    });

    // Stream coordinates live to active socket rooms
    this.trackingGateway.broadcastLocation(updated.orderId, {
      lat: dto.latitude,
      lng: dto.longitude,
      driverId: userId,
    });

    return updated;
  }

  async verifyOtpAndComplete(id: string, userId: string, role: string, otpCode: string) {
    const assignment = await this._checkAssignmentOwnership(id, userId, role);

    if (assignment.status !== ('OUT_FOR_DELIVERY' as any)) {
      throw new BadRequestException('Delivery must be out for delivery to complete verification');
    }

    // Match OTP code
    if (assignment.order.otpCode !== otpCode) {
      throw new BadRequestException('Incorrect delivery verification OTP code');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id },
        data: {
          status: 'DELIVERED' as any,
          deliveredTime: new Date(),
        },
      });

      await tx.order.update({
        where: { id: assignment.orderId },
        data: {
          status: 'DELIVERED' as any,
          paymentStatus: 'COMPLETED' as any,
        },
      });

      // Settle mock farmer payouts earnings
      const orderItems = await tx.orderItem.findMany({
        where: { orderId: assignment.orderId },
      });

      for (const item of orderItems) {
        await tx.farmerEarning.create({
          data: {
            farmerId: item.farmerId,
            orderId: item.orderId,
            amount: item.total,
            isSettled: false,
          },
        });
      }

      return updated;
    });
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) throw new NotFoundException('Delivery partner user profile not found');

    return {
      id: user.id,
      name: user.name,
      phone: user.phone || '',
      email: user.email,
      profileImage: null,
      vehicle: {
        type: 'Motorcycle',
        model: 'Hero Splendor',
        plateNumber: 'AP-07-BX-1234',
        color: 'Black',
      },
      license: {
        number: 'DL-1420110012345',
        expiryDate: '2030-12-31',
      },
      bankAccount: {
        accountName: user.name,
        accountNumber: '1234567890',
        bankName: 'State Bank of India',
        ifscCode: 'SBIN0001234',
      },
      rating: {
        average: 4.8,
        total: 24,
      },
      isAvailable: true,
      createdAt: user.createdAt,
    };
  }

  async updateProfile(userId: string, dto: any) {
    const updateData: any = {};
    if (dto.name) updateData.name = dto.name;
    if (dto.phone) updateData.phone = dto.phone;
    if (dto.email) updateData.email = dto.email;

    await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
    });

    return this.getProfile(userId);
  }

  async toggleAvailability(userId: string) {
    return { success: true, isAvailable: true };
  }

  async getDashboard(userId: string) {
    const stats = await this.getStatistics(userId);
    return {
      stats,
      recentEarnings: [
        { period: 'Today', amount: stats.todayEarnings, deliveries: stats.completedToday },
        { period: 'This Week', amount: stats.weeklyEarnings, deliveries: stats.totalDeliveries },
      ],
      unreadNotifications: 0,
    };
  }

  async getStatistics(userId: string) {
    const assignments = await this.prisma.deliveryAssignment.findMany({
      where: { driverId: userId },
    });

    const active = assignments.filter(a =>
      ['ASSIGNED', 'ACCEPTED', 'HEADING_TO_PICKUP', 'PICKED_UP', 'OUT_FOR_DELIVERY'].includes(a.status)
    ).length;

    const completed = assignments.filter(a => a.status === 'DELIVERED');
    const totalDeliveries = assignments.length;

    const totalEarnings = completed.reduce((sum, a) => sum + Number(a.deliveryCharge), 0);

    return {
      todayEarnings: totalEarnings,
      weeklyEarnings: totalEarnings,
      monthlyEarnings: totalEarnings,
      activeDeliveries: active,
      pendingDeliveries: assignments.filter(a => a.status === 'ASSIGNED').length,
      completedToday: completed.length,
      cancelledToday: assignments.filter(a => a.status === 'CANCELLED').length,
      averageRating: 4.8,
      totalDeliveries,
    };
  }

  async getEarnings(userId: string) {
    const stats = await this.getStatistics(userId);
    return {
      totalEarnings: stats.todayEarnings,
      pendingWithdrawals: 0.0,
      completedWithdrawals: 0.0,
    };
  }

  async getTransactions(userId: string) {
    const assignments = await this.prisma.deliveryAssignment.findMany({
      where: { driverId: userId, status: 'DELIVERED' },
      include: { order: true },
    });

    return assignments.map(a => ({
      id: a.id,
      amount: Number(a.deliveryCharge),
      type: 'CREDIT',
      status: 'COMPLETED',
      description: `Delivery reward for Order #${a.order?.orderNumber || a.orderId.substring(0, 8)}`,
      createdAt: a.deliveredTime || a.updatedAt,
    }));
  }

  async getHistory(userId: string) {
    const assignments = await this.prisma.deliveryAssignment.findMany({
      where: {
        driverId: userId,
        status: { in: ['DELIVERED', 'CANCELLED', 'REJECTED'] as any },
      },
      include: {
        order: {
          select: { orderNumber: true, total: true, address: true },
        },
      },
    });

    return {
      orders: assignments.map(a => ({
        id: a.id,
        orderId: a.orderId,
        orderNumber: a.order?.orderNumber || a.orderId.substring(0, 8),
        amount: Number(a.order?.total || 0),
        deliveryCharge: Number(a.deliveryCharge),
        status: a.status,
        createdAt: a.createdAt,
      })),
      total: assignments.length,
    };
  }
}
