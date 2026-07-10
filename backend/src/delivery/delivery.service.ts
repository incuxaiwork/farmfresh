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
    const assignment = await this.prisma.deliveryAssignment.findUnique({
      where: { id: assignmentId },
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
    const where: any = {};

    if (role === 'DELIVERY_PARTNER') {
      where.driverId = userId;
    } else if (role === 'CUSTOMER') {
      where.order = { customerId: userId };
    } else if (role !== 'ADMIN') {
      throw new ForbiddenException('Access denied');
    }

    if (filters.status) where.status = filters.status as any;
    if (filters.driverId && role === 'ADMIN') where.driverId = filters.driverId;

    return this.prisma.deliveryAssignment.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        order: {
          select: { orderNumber: true, total: true, address: true, customerId: true },
        },
        driver: {
          select: { name: true, phone: true },
        },
      },
    });
  }

  async findOne(id: string, userId: string, role: string) {
    return this._checkAssignmentOwnership(id, userId, role);
  }

  async acceptDelivery(id: string, userId: string, role: string) {
    const assignment = await this._checkAssignmentOwnership(id, userId, role);

    if (assignment.status !== ('ASSIGNED' as any)) {
      throw new BadRequestException('Delivery assignment is not in ASSIGNED state');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.deliveryAssignment.update({
        where: { id },
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
    const assignment = await this._checkAssignmentOwnership(id, userId, role);

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
}
