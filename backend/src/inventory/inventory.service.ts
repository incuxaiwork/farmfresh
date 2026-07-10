import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { AdjustStockDto } from './dto/adjust-stock.dto';
import { UpdateInventoryDto } from './dto/update-inventory.dto';

@Injectable()
export class InventoryService {
  constructor(private prisma: PrismaService) {}

  private async _getFarmerProfileId(userId: string): Promise<string> {
    const profile = await this.prisma.farmerProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new ForbiddenException('A verified Farmer Profile is required to manage inventory');
    }
    return profile.id;
  }

  private async _checkOwnership(inventoryId: string, userId: string, role: string): Promise<any> {
    const inventory = await this.prisma.inventory.findUnique({
      where: { id: inventoryId },
      include: { product: true },
    });

    if (!inventory) {
      throw new NotFoundException('Inventory record not found');
    }

    if (role !== 'ADMIN') {
      const farmerId = await this._getFarmerProfileId(userId);
      if (inventory.farmerId !== farmerId) {
        throw new ForbiddenException('Access denied: You can only manage stock of your own products');
      }
    }

    return inventory;
  }

  private _recalculateStatus(currentStock: number, reservedStock: number, minLevel: number): 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' {
    const available = currentStock - reservedStock;
    if (available <= 0) return 'OUT_OF_STOCK';
    if (available <= minLevel) return 'LOW_STOCK';
    return 'IN_STOCK';
  }

  async findAll(
    userId: string,
    role: string,
    filters: {
      status?: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' | 'DISCONTINUED';
      farmerId?: string;
      categoryId?: string;
      search?: string;
      sortBy?: 'stock' | 'updatedAt' | 'productName';
      sortOrder?: 'asc' | 'desc';
    },
  ) {
    const where: any = {};

    // Access control check
    if (role === 'FARMER') {
      const farmerId = await this._getFarmerProfileId(userId);
      where.farmerId = farmerId;
    } else if (role !== 'ADMIN') {
      throw new ForbiddenException('Access denied: Unauthorized dashboard view');
    }

    if (filters.status) where.status = filters.status as any;
    if (filters.farmerId && role === 'ADMIN') where.farmerId = filters.farmerId;
    
    if (filters.categoryId) {
      where.product = { categoryId: filters.categoryId };
    }

    if (filters.search) {
      where.product = {
        name: { contains: filters.search, mode: 'insensitive' },
      };
    }

    const orderBy: any = {};
    const sortField = filters.sortBy ?? 'updatedAt';
    if (sortField === 'stock') {
      orderBy.currentStock = filters.sortOrder ?? 'desc';
    } else if (sortField === 'productName') {
      orderBy.product = { name: filters.sortOrder ?? 'asc' };
    } else {
      orderBy.updatedAt = filters.sortOrder ?? 'desc';
    }

    return this.prisma.inventory.findMany({
      where,
      orderBy,
      include: {
        product: {
          select: { name: true, unit: true },
        },
        farmer: {
          select: { farmName: true },
        },
      },
    });
  }

  async findOne(id: string, userId: string, role: string) {
    return this._checkOwnership(id, userId, role);
  }

  async update(id: string, userId: string, role: string, dto: UpdateInventoryDto) {
    const inventory = await this._checkOwnership(id, userId, role);

    const updateData: any = {};
    if (dto.minStockLevel !== undefined) updateData.minStockLevel = dto.minStockLevel;
    if (dto.maxStockLevel !== undefined) updateData.maxStockLevel = dto.maxStockLevel;
    if (dto.reorderLevel !== undefined) updateData.reorderLevel = dto.reorderLevel;
    if (dto.status !== undefined) updateData.status = dto.status as any;

    return this.prisma.inventory.update({
      where: { id },
      data: updateData,
    });
  }

  async addStock(id: string, userId: string, role: string, dto: AdjustStockDto) {
    const inventory = await this._checkOwnership(id, userId, role);

    const currentVal = Number(inventory.currentStock);
    const newVal = currentVal + dto.quantity;

    const newStatus = this._recalculateStatus(
      newVal,
      Number(inventory.reservedStock),
      Number(inventory.minStockLevel),
    );

    return this.prisma.$transaction(async (tx) => {
      // Update inventory values
      const updated = await tx.inventory.update({
        where: { id },
        data: {
          currentStock: newVal,
          status: newStatus as any,
        },
      });

      // Log transaction history
      await tx.inventoryHistory.create({
        data: {
          inventoryId: id,
          action: 'ADD' as any,
          quantity: dto.quantity,
          reason: dto.reason,
          userId,
        },
      });

      return updated;
    });
  }

  async removeStock(id: string, userId: string, role: string, dto: AdjustStockDto) {
    const inventory = await this._checkOwnership(id, userId, role);

    const currentVal = Number(inventory.currentStock);
    const reservedVal = Number(inventory.reservedStock);
    const newVal = currentVal - dto.quantity;

    if (newVal < 0) {
      throw new BadRequestException('Stock quantity cannot be reduced below zero');
    }

    if (newVal - reservedVal < 0) {
      throw new BadRequestException('Available stock is fully reserved by active orders');
    }

    const newStatus = this._recalculateStatus(
      newVal,
      reservedVal,
      Number(inventory.minStockLevel),
    );

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.inventory.update({
        where: { id },
        data: {
          currentStock: newVal,
          status: newStatus as any,
        },
      });

      await tx.inventoryHistory.create({
        data: {
          inventoryId: id,
          action: 'REMOVE' as any,
          quantity: dto.quantity,
          reason: dto.reason,
          userId,
        },
      });

      return updated;
    });
  }

  async adjustStock(id: string, userId: string, role: string, dto: AdjustStockDto) {
    const inventory = await this._checkOwnership(id, userId, role);

    if (dto.quantity < 0) {
      throw new BadRequestException('Adjusted stock quantity must be non-negative');
    }

    const newStatus = this._recalculateStatus(
      dto.quantity,
      Number(inventory.reservedStock),
      Number(inventory.minStockLevel),
    );

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.inventory.update({
        where: { id },
        data: {
          currentStock: dto.quantity,
          status: newStatus as any,
        },
      });

      await tx.inventoryHistory.create({
        data: {
          inventoryId: id,
          action: 'ADJUST' as any,
          quantity: dto.quantity,
          reason: dto.reason,
          userId,
        },
      });

      return updated;
    });
  }

  async getHistory(
    userId: string,
    role: string,
    filters: {
      inventoryId?: string;
      action?: 'ADD' | 'REMOVE' | 'ADJUST';
    },
  ) {
    const where: any = {};

    if (role === 'FARMER') {
      const farmerId = await this._getFarmerProfileId(userId);
      where.inventory = { farmerId };
    } else if (role !== 'ADMIN') {
      throw new ForbiddenException('Access denied: Unauthorized view history');
    }

    if (filters.inventoryId) {
      if (role === 'FARMER') {
        // Double check ownership
        await this._checkOwnership(filters.inventoryId, userId, role);
      }
      where.inventoryId = filters.inventoryId;
    }

    if (filters.action) {
      where.action = filters.action as any;
    }

    return this.prisma.inventoryHistory.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: { name: true },
        },
        inventory: {
          select: {
            product: { select: { name: true } },
          },
        },
      },
    });
  }

  async getLowStockAlerts(userId: string, role: string) {
    const where: any = {
      status: 'LOW_STOCK' as any,
    };

    if (role === 'FARMER') {
      const farmerId = await this._getFarmerProfileId(userId);
      where.farmerId = farmerId;
    } else if (role !== 'ADMIN') {
      throw new ForbiddenException('Access denied');
    }

    return this.prisma.inventory.findMany({
      where,
      include: {
        product: { select: { name: true } },
      },
    });
  }
}
