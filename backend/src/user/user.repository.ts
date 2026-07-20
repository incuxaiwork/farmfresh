import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { UpdateProfileDto } from '../common/dto/update-profile.dto';
import { RegisterCustomerDto } from '../auth/dto/register-customer.dto';
import { RegisterFarmerDto } from '../auth/dto/register-farmer.dto';
import { RegisterDeliveryDto } from '../auth/dto/register-delivery.dto';

@Injectable()
export class UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async findByPhone(phone: string) {
    return this.prisma.user.findUnique({
      where: { phone },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        avatar: true,
        createdAt: true,
      },
    });
  }

  async exists(phone: string, excludeId?: string) {
    const where: any = { phone };
    if (excludeId) where.id = { not: excludeId };
    const user = await this.prisma.user.findFirst({ where });
    return !!user;
  }

  async createFromCustomerRegistration(dto: RegisterCustomerDto) {
    return this.prisma.user.create({
      data: {
        name: `${dto.firstName} ${dto.lastName}`,
        email: dto.email.toLowerCase(),
        phone: dto.phone,
        passwordHash: 'temp-hash', // Should be hashed by caller
        role: 'CUSTOMER' as any,
      },
    });
  }

  async createFromFarmerRegistration(dto: RegisterFarmerDto) {
    return this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email.toLowerCase(),
        phone: dto.phone,
        passwordHash: 'temp-hash', // Should be hashed by caller
        role: 'FARMER' as any,
        farmerProfile: {
          create: {
            farmName: dto.farmName,
            farmAddress: dto.farmAddress,
            kycStatus: 'PENDING' as any,
            kycDocUrl: dto.governmentId,
            bankAccount: {
              create: {
                bankName: 'Partner Bank',
                accountNumber: dto.bankAccountDetails,
                routingNumber: '0000',
              },
            },
          },
        },
      },
    });
  }

  async createFromDeliveryRegistration(dto: RegisterDeliveryDto) {
    return this.prisma.user.create({
      data: {
        name: `${dto.firstName} ${dto.lastName}`,
        email: dto.email.toLowerCase(),
        phone: dto.phone,
        passwordHash: 'temp-hash', // Should be hashed by caller
        role: 'DELIVERY_PARTNER' as any,
      },
    });
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const data: any = {};
    if (dto.name !== undefined) data.name = dto.name;
    if (dto.phone !== undefined) {
      // Check if phone is already in use by another user
      const existingPhone = await this.prisma.user.findFirst({
        where: { phone: dto.phone, id: { not: userId } },
      });
      if (existingPhone) {
        throw new ConflictException('This phone number is already registered to another user');
      }
      data.phone = dto.phone;
    }
    if (dto.avatar !== undefined) data.avatar = dto.avatar;

    return this.prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async uploadProfileImage(userId: string, imageUrl: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { avatar: imageUrl },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async deleteProfilePicture(userId: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { avatar: null },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async findAll(format: 'json' | 'jsonWithProfile' = 'json') {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        phone: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
        ...(format === 'jsonWithProfile' && { farmerProfile: { select: { farmName: true, farmAddress: true } } }),
      },
    });

    return users.map(user => {
      const userJson: any = {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        avatar: user.avatar,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      };

      if (format === 'jsonWithProfile' && user.farmerProfile) {
        userJson.farmerProfile = user.farmerProfile;
      }

      return userJson;
    });
  }
}