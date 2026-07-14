import { Injectable, ConflictException, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import { RegisterCustomerDto } from './dto/register-customer.dto';
import { RegisterFarmerDto } from './dto/register-farmer.dto';
import { RegisterDeliveryDto } from './dto/register-delivery.dto';
import { LoginDto } from './dto/login.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
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

  private _generateSecureToken(): string {
    return crypto.randomBytes(32).toString('hex');
  }

  private async _generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };
    
    const accessToken = this.jwtService.sign(payload);
    
    const refreshSecret = this.configService.get<string>('jwt.refreshSecret');
    const refreshExpiresIn = this.configService.get<string>('jwt.refreshExpiresIn') || '7d';
    
    const refreshToken = this.jwtService.sign(payload, {
      secret: refreshSecret,
      expiresIn: refreshExpiresIn,
    });

    const tokenHash = await bcrypt.hash(refreshToken, 12);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return { accessToken, refreshToken };
  }

  async registerCustomer(dto: RegisterCustomerDto) {
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
        role: 'CUSTOMER' as any,
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
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.username.toLowerCase() },
          { phone: dto.username },
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
    const tokenHash = await bcrypt.hash(refreshToken, 12);
    
    await this.prisma.refreshToken.deleteMany({
      where: { tokenHash },
    });
    return { success: true };
  }

  async refresh(userId: string, email: string, role: string, oldToken: string) {
    const tokens = await this.prisma.refreshToken.findMany({
      where: { userId },
    });

    let isValid = false;
    for (const t of tokens) {
      const match = await bcrypt.compare(oldToken, t.tokenHash);
      if (match) {
        isValid = true;
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

    const token = this._generateSecureToken();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);

    await this.prisma.verificationToken.create({
      data: {
        token,
        userId: user.id,
        type: 'PASSWORD_RESET',
        expiresAt,
      },
    });

    return { message: 'Password reset link sent to your email address', debugToken: token };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const verification = await this.prisma.verificationToken.findUnique({
      where: { token: dto.token },
    });

    if (!verification || verification.expiresAt < new Date() || verification.type !== 'PASSWORD_RESET') {
      throw new BadRequestException('Reset token has expired or is invalid');
    }

    const passwordHash = await this._hashPassword(dto.newPassword);
    await this.prisma.user.update({
      where: { id: verification.userId },
      data: { passwordHash },
    });

    await this.prisma.verificationToken.delete({ where: { id: verification.id } });
    return { message: 'Password has been updated successfully' };
  }

  async sendEmailVerification(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    const token = this._generateSecureToken();
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

    await this.prisma.verificationToken.create({
      data: {
        token,
        userId: user.id,
        type: 'EMAIL_VERIFICATION',
        expiresAt,
      },
    });

    return { message: 'Verification link sent to your email', debugToken: token };
  }

  async verifyEmail(token: string) {
    const verification = await this.prisma.verificationToken.findUnique({
      where: { token },
    });

    if (!verification || verification.expiresAt < new Date() || verification.type !== 'EMAIL_VERIFICATION') {
      throw new BadRequestException('Verification token has expired or is invalid');
    }

    await this.prisma.verificationToken.delete({ where: { id: verification.id } });
    return { message: 'Email verified successfully!' };
  }

  async sendOtp(phone: string) {
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    await this.prisma.otpCode.upsert({
      where: { phone },
      update: { code, expiresAt },
      create: { phone, code, expiresAt },
    });

    return { message: 'OTP verification code sent', debugCode: code };
  }

  async verifyOtp(phone: string, code: string) {
    const otp = await this.prisma.otpCode.findUnique({
      where: { phone },
    });

    if (!otp || otp.expiresAt < new Date()) {
      throw new BadRequestException('OTP code has expired or is invalid');
    }

    if (otp.code !== code) {
      throw new BadRequestException('Incorrect OTP code');
    }

    await this.prisma.otpCode.delete({ where: { id: otp.id } });
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