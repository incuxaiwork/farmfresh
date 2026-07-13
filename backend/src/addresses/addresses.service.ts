import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';

@Injectable()
export class AddressesService {
  constructor(private prisma: PrismaService) {}

  private _mapToFrontend(address: any) {
    return {
      id: address.id,
      label: address.addressLine2 || 'Home',
      street: address.addressLine1,
      city: address.city,
      state: address.state,
      zipCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    };
  }

  async findAll(userId: string) {
    const list = await this.prisma.userAddress.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
    return list.map(a => this._mapToFrontend(a));
  }

  async create(userId: string, dto: CreateAddressDto) {
    // If set as default, reset other default addresses for this user
    if (dto.isDefault) {
      await this.prisma.userAddress.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });
    }

    const address = await this.prisma.userAddress.create({
      data: {
        userId,
        addressLine1: dto.street,
        addressLine2: dto.label,
        city: dto.city,
        state: dto.state,
        postalCode: dto.zipCode,
        country: dto.country || 'India',
        isDefault: dto.isDefault ?? false,
      },
    });

    return this._mapToFrontend(address);
  }

  async update(id: string, userId: string, dto: UpdateAddressDto) {
    const existing = await this.prisma.userAddress.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      throw new NotFoundException('Address not found');
    }

    // If set as default, reset other default addresses for this user
    if (dto.isDefault) {
      await this.prisma.userAddress.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });
    }

    const data: any = {};
    if (dto.street !== undefined) data.addressLine1 = dto.street;
    if (dto.label !== undefined) data.addressLine2 = dto.label;
    if (dto.city !== undefined) data.city = dto.city;
    if (dto.state !== undefined) data.state = dto.state;
    if (dto.zipCode !== undefined) data.postalCode = dto.zipCode;
    if (dto.country !== undefined) data.country = dto.country;
    if (dto.isDefault !== undefined) data.isDefault = dto.isDefault;

    const address = await this.prisma.userAddress.update({
      where: { id },
      data,
    });

    return this._mapToFrontend(address);
  }

  async remove(id: string, userId: string) {
    const existing = await this.prisma.userAddress.findFirst({
      where: { id, userId },
    });

    if (!existing) {
      throw new NotFoundException('Address not found');
    }

    await this.prisma.userAddress.delete({
      where: { id },
    });

    return { success: true };
  }
}
