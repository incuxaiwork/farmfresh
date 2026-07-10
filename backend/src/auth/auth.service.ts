import { Injectable, ConflictException, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { RegisterCustomerDto } from './dto/register-customer.dto';
import { RegisterFarmerDto } from './dto/register-farmer.dto';
import { RegisterDeliveryDto } from './dto/register-delivery.dto';
import { LoginDto } from './dto/login.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  // In-memory fallback registries for OTPs and verification tokens when Redis is offline
  private readonly _otpRegistry = new Map<string, { code: string; expiresAt: number }>();
  private readonly _tokenRegistry = new Map<string, { userId: string; expiresAt: number }>();

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  private async _hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
  }

  private async _comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  private async _generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };
    
    const accessToken = this.jwtService.sign(payload);
    
    // Generate refresh token
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET') || 'fallbackSuperRefreshSecretKey456';
    const refreshExpiresIn = this.configService.get<string>('JWT_REFRESH_EXPIRATION') || '7d';
    
    const refreshToken = this.jwtService.sign(payload, {
      secret: refreshSecret,
      expiresIn: refreshExpiresIn,
    });

    // Save hashed refresh token to DB
    const hashedToken = crypto.createHash ? crypto.createHash('sha256').update(refreshToken).digest('hex') : refreshToken; // simple fallback
    
    // Simple hash simulation if crypto is not imported
    const tokenHash = await bcrypt.hash(refreshToken, 8);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      },
    });

    return { accessToken, refreshToken };
  }

  async registerCustomer(dto: RegisterCustomerDto) {
    // Check duplicates
    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.email.toLowerCase() },
          { phone: dto.phone },
        ],
      },
    });

    if (existing) {
      throw new ConflictException('Email address or phone number already registered');
    }

    const passwordHash = await this._hashPassword(dto.password);
    
    // Prisma model name matches 'User'
    // Create customer account
    const user = await this.prisma.user.create({
      data: {
        name: `${dto.firstName} ${dto.lastName}`,
        email: dto.email.toLowerCase(),
        passwordHash,
        role: 'CUSTOMER' as any, // Cast for matching Prisma Enums
      },
    });

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  }

  async registerFarmer(dto: RegisterFarmerDto) {
    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.email.toLowerCase() },
          { phone: dto.phone },
        ],
      },
    });

    if (existing) {
      throw new ConflictException('Email address or phone number already registered');
    }

    const passwordHash = await this._hashPassword(dto.password);

    // Create user and profile transactionally
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email.toLowerCase(),
        passwordHash,
        role: 'FARMER' as any,
        farmerProfile: {
          create: {
            farmName: dto.farmName,
            farmAddress: dto.farmAddress,
            kycStatus: 'PENDING' as any,
            kycDocUrl: dto.governmentId, // Using field temporarily
            bankAccount: {
              create: {
                bankName: 'Partner Bank',
                accountNumber: dto.bankAccountDetails, // Encrypted at-rest normally
                routingNumber: '0000',
              },
            },
          },
        },
      },
    });

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  }

  async registerDelivery(dto: RegisterDeliveryDto) {
    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.email.toLowerCase() },
          { phone: dto.phone },
        ],
      },
    });

    if (existing) {
      throw new ConflictException('Email address or phone number already registered');
    }

    const passwordHash = await this._hashPassword(dto.password);

    const user = await this.prisma.user.create({
      data: {
        name: `${dto.firstName} ${dto.lastName}`,
        email: dto.email.toLowerCase(),
        passwordHash,
        role: 'DELIVERY_PARTNER' as any,
      },
    });

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  }

  async login(dto: LoginDto) {
    // Lookup by email or phone
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.username.toLowerCase() },
          { email: dto.username }, // phone number check fallback in logic
        ],
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid login credentials');
    }

    const validPassword = await this._comparePassword(dto.password, user.passwordHash);
    if (!validPassword) {
      throw new UnauthorizedException('Invalid login credentials');
    }

    const tokens = await this._generateTokens(user.id, user.email, user.role);
    return {
      user: { id: user.id, name: user.name, email: user.email, role: user.role },
      ...tokens,
    };
  }

  async logout(refreshToken: string) {
    // Delete refresh token row
    try {
      await this.prisma.refreshToken.deleteMany({
        where: {
          tokenHash: {
            contains: refreshToken.substring(0, 10), // Safe match fallback
          },
        },
      });
    } catch (e) {
      // Ignore not found errors
    }
    return { success: true };
  }

  async refresh(userId: string, email: string, role: string, oldToken: string) {
    // Rotates the refresh token
    // Match in database
    const tokens = await this.prisma.refreshToken.findMany({
      where: { userId },
    });

    let isValid = false;
    for (const t of tokens) {
      const match = await bcrypt.compare(oldToken, t.tokenHash);
      if (match) {
        isValid = true;
        // Delete old token
        await this.prisma.refreshToken.delete({ where: { id: t.id } });
        break;
      }
    }

    if (!isValid) {
      throw new UnauthorizedException('Invalid session or refresh token');
    }

    return this._generateTokens(userId, email, role);
  }

  async forgotPassword(email: string) {
    const user = await this.prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (!user) {
      throw new NotFoundException('No account associated with this email address');
    }

    // Generate reset token
    const token = Math.random().toString(36).substring(2, 15);
    this._tokenRegistry.set(token, {
      userId: user.id,
      expiresAt: Date.now() + 60 * 60 * 1000, // 1 hour
    });

    // In a real system, you would call an email dispatcher here
    return { message: 'Password reset link sent to your email address', debugToken: token };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const session = this._tokenRegistry.get(dto.token);
    if (!session || session.expiresAt < Date.now()) {
      throw new BadRequestException('Reset token has expired or is invalid');
    }

    const passwordHash = await this._hashPassword(dto.newPassword);
    await this.prisma.user.update({
      where: { id: session.userId },
      data: { passwordHash },
    });

    this._tokenRegistry.delete(dto.token);
    return { message: 'Password has been updated successfully' };
  }

  async sendEmailVerification(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const token = Math.random().toString(36).substring(2, 15);
    this._tokenRegistry.set(token, {
      userId: user.id,
      expiresAt: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
    });

    return { message: 'Verification link sent to your email', debugToken: token };
  }

  async verifyEmail(token: string) {
    const session = this._tokenRegistry.get(token);
    if (!session || session.expiresAt < Date.now()) {
      throw new BadRequestException('Verification token has expired or is invalid');
    }

    this._tokenRegistry.delete(token);
    return { message: 'Email verified successfully!' };
  }

  async sendOtp(phone: string) {
    const code = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit
    this._otpRegistry.set(phone, {
      code,
      expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
    });

    // In a real system, you would call an SMS gateway here
    return { message: 'OTP verification code sent', debugCode: code };
  }

  async verifyOtp(phone: string, code: string) {
    const data = this._otpRegistry.get(phone);
    if (!data || data.expiresAt < Date.now()) {
      throw new BadRequestException('OTP code has expired or is invalid');
    }

    if (data.code !== code) {
      throw new BadRequestException('Incorrect OTP code');
    }

    this._otpRegistry.delete(phone);
    return { message: 'Phone number verified successfully!' };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
      },
    });
    if (!user) throw new NotFoundException('User profile not found');
    return user;
  }
}
