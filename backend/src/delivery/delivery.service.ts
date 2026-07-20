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

  async getFarmerLocation(farmerId: string) {
    const farmerProfile = await this.prisma.farmerProfile.findUnique({
      where: { id: farmerId },
      select: {
        farmName: true,
        farmAddress: true,
        farmLatitude: true,
        farmLongitude: true,
        user: { select: { name: true, phone: true } },
      },
    });

    if (!farmerProfile) {
      throw new NotFoundException('Farmer not found');
    }

    return {
      farmerId,
      farmName: farmerProfile.farmName,
      farmAddress: farmerProfile.farmAddress,
      latitude: farmerProfile.farmLatitude ? Number(farmerProfile.farmLatitude) : null,
      longitude: farmerProfile.farmLongitude ? Number(farmerProfile.farmLongitude) : null,
      contactName: farmerProfile.user.name,
      contactPhone: farmerProfile.user.phone,
    };
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
              status: true,
              customer: { select: { id: true, name: true, phone: true, email: true } },
            },
          },
          driver: {
            select: { name: true, phone: true },
          },
        },
      });

      const assignedToMe = assignedRaw.map(a => {
        const orderData = a.order as any;
        return {
          ...a,
          deliveryFee: a.deliveryCharge,
          farmerLatitude: orderData?.farmerLatitude ? Number(orderData.farmerLatitude) : null,
          farmerLongitude: orderData?.farmerLongitude ? Number(orderData.farmerLongitude) : null,
          customerLatitude: orderData?.customerLatitude ? Number(orderData.customerLatitude) : null,
          customerLongitude: orderData?.customerLongitude ? Number(orderData.customerLongitude) : null,
          customer: a.order.customer
            ? {
                id: a.order.customer.id,
                name: a.order.customer.name,
                phone: a.order.customer.phone,
                email: a.order.customer.email,
              }
            : null,
          deliveryAddress: a.order.address ? { fullAddress: a.order.address } : null,
        };
      });

      // 2. Get orders that need delivery and have no assignment
      const ordersWithoutAssignment = await this.prisma.order.findMany({
        where: {
          status: { in: ['CONFIRMED', 'ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP'] as any },
          OR: [
            { delivery: null },
            { delivery: { status: { in: ['REJECTED', 'CANCELLED'] as any } } }
          ],
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
        farmerLatitude: o.farmerLatitude ? Number(o.farmerLatitude) : null,
        farmerLongitude: o.farmerLongitude ? Number(o.farmerLongitude) : null,
        customerLatitude: o.customerLatitude ? Number(o.customerLatitude) : null,
        customerLongitude: o.customerLongitude ? Number(o.customerLongitude) : null,
        order: {
          orderNumber: o.orderNumber,
          total: o.total,
          address: o.address,
          customerId: o.customerId,
          status: o.status,
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
            status: true,
            customer: { select: { id: true, name: true, phone: true, email: true } },
          },
        },
        driver: {
          select: { name: true, phone: true },
        },
      },
    });

    return assignments.map(a => {
      const orderData = a.order as any;
      return {
        ...a,
        deliveryFee: a.deliveryCharge,
        farmerLatitude: orderData?.farmerLatitude ? Number(orderData.farmerLatitude) : null,
        farmerLongitude: orderData?.farmerLongitude ? Number(orderData.farmerLongitude) : null,
        customerLatitude: orderData?.customerLatitude ? Number(orderData.customerLatitude) : null,
        customerLongitude: orderData?.customerLongitude ? Number(orderData.customerLongitude) : null,
        customer: a.order.customer
          ? {
              id: a.order.customer.id,
              name: a.order.customer.name,
              phone: a.order.customer.phone,
              email: a.order.customer.email,
            }
          : null,
        deliveryAddress: a.order.address ? { fullAddress: a.order.address } : null,
      };
    });
  }

  async findOne(id: string, userId: string, role: string) {
    try {
      const assignment = await this._checkAssignmentOwnership(id, userId, role);
      
      // Enrich with coordinates from order and farmer profile
      const order = await this.prisma.order.findUnique({
        where: { id: assignment.orderId },
        include: {
          items: { include: { product: true } },
          customer: { select: { name: true, email: true } },
        },
      });

      let farmerCoords = null;
      let farmerInfo = null;
      if (order?.items?.[0]?.farmerId) {
        const farmerProfile = await this.prisma.farmerProfile.findUnique({
          where: { id: order.items[0].farmerId },
          include: { user: { select: { name: true, phone: true } } },
        });
        if (farmerProfile) {
          farmerCoords = {
            latitude: farmerProfile.farmLatitude ? Number(farmerProfile.farmLatitude) : null,
            longitude: farmerProfile.farmLongitude ? Number(farmerProfile.farmLongitude) : null,
          };
          farmerInfo = {
            id: farmerProfile.userId,
            name: farmerProfile.user.name,
            phone: farmerProfile.user.phone || '',
            farmName: farmerProfile.farmName,
          };
        }
      }

      return {
        ...assignment,
        deliveryFee: assignment.deliveryCharge,
        farmerLatitude: order?.farmerLatitude ? Number(order.farmerLatitude) : farmerCoords?.latitude,
        farmerLongitude: order?.farmerLongitude ? Number(order.farmerLongitude) : farmerCoords?.longitude,
        customerLatitude: order?.customerLatitude ? Number(order.customerLatitude) : null,
        customerLongitude: order?.customerLongitude ? Number(order.customerLongitude) : null,
        customer: order?.customer ? {
          id: order.customerId,
          name: (order.customer as any).name,
          phone: (order.customer as any).phone || '',
          email: (order.customer as any).email,
        } : null,
        farmer: farmerInfo,
        deliveryAddress: order?.address ? { fullAddress: order.address } : null,
      };
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
          let farmerCoords = null;
          let farmerInfo = null;
          if (order.items[0]?.farmerId) {
            const farmerProfile = await this.prisma.farmerProfile.findUnique({
              where: { id: order.items[0].farmerId },
              include: { user: { select: { name: true, phone: true } } },
            });
            if (farmerProfile) {
              farmerCoords = {
                latitude: farmerProfile.farmLatitude ? Number(farmerProfile.farmLatitude) : null,
                longitude: farmerProfile.farmLongitude ? Number(farmerProfile.farmLongitude) : null,
              };
              farmerInfo = {
                id: farmerProfile.userId,
                name: farmerProfile.user.name,
                phone: farmerProfile.user.phone || '',
                farmName: farmerProfile.farmName,
              };
            }
          }
          return {
            id: order.id,
            orderId: order.id,
            driverId: userId,
            status: 'PENDING_ASSIGNMENT',
            deliveryCharge: 5.00,
            distance: 3.5,
            farmerLatitude: order.farmerLatitude ? Number(order.farmerLatitude) : farmerCoords?.latitude,
            farmerLongitude: order.farmerLongitude ? Number(order.farmerLongitude) : farmerCoords?.longitude,
            customerLatitude: order.customerLatitude ? Number(order.customerLatitude) : null,
            customerLongitude: order.customerLongitude ? Number(order.customerLongitude) : null,
            order,
            farmer: farmerInfo,
            customer: order.customer ? {
              id: order.customerId,
              name: (order.customer as any).name,
              phone: (order.customer as any).phone || '',
              email: (order.customer as any).email,
            } : null,
            deliveryAddress: order.address ? { fullAddress: order.address } : null,
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
      include: {
        deliveries: {
          where: { status: 'DELIVERED' as any },
          select: { deliveryCharge: true },
        },
      },
    });
    if (!user) throw new NotFoundException('Delivery partner user profile not found');

    const completedDeliveries = user.deliveries || [];
    const totalEarnings = completedDeliveries.reduce(
      (sum, d) => sum + Number(d.deliveryCharge),
      0,
    );

    return {
      id: user.id,
      name: user.name,
      phone: user.phone || '',
      email: user.email,
      profileImage: null,
      vehicle: null,
      license: null,
      bankAccount: null,
      rating: {
        average: 0,
        total: 0,
      },
      totalEarnings,
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
