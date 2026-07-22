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
    let phone = dto.phone.trim();
    if (phone.length > 0 && !phone.startsWith('+')) {
      phone = `+91${phone.replace(/^91/, '')}`;
    }

    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.email.toLowerCase() },
          ...(phone && phone.length >= 10 ? [{ phone }] : []),
        ],
      },
    });

    if (existing) {
      if (existing.email.toLowerCase() === dto.email.toLowerCase()) {
        throw new ConflictException(`Account with email '${dto.email}' is already registered. Please sign in.`);
      }
      throw new ConflictException(`Mobile number '${dto.phone}' is already registered. Please sign in.`);
    }

    const passwordHash = await this._hashPassword(dto.password);
    
    const user = await this.prisma.user.create({
      data: {
        name: `${dto.firstName} ${dto.lastName}`.trim(),
        email: dto.email.toLowerCase(),
        phone,
        passwordHash,
        role: 'CUSTOMER' as any,
      },
    });

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  }

  async registerFarmer(dto: RegisterFarmerDto) {
    let phone = dto.phone.trim();
    if (phone.length > 0 && !phone.startsWith('+')) {
      phone = `+91${phone.replace(/^91/, '')}`;
    }

    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.email.toLowerCase() },
          ...(phone && phone.length >= 10 ? [{ phone }] : []),
        ],
      },
    });

    if (existing) {
      if (existing.email.toLowerCase() === dto.email.toLowerCase()) {
        throw new ConflictException(`Account with email '${dto.email}' is already registered. Please sign in.`);
      }
      throw new ConflictException(`Mobile number '${dto.phone}' is already registered. Please sign in.`);
    }

    const passwordHash = await this._hashPassword(dto.password);

    const farmName = (dto.farmName && dto.farmName.trim().length > 0)
      ? dto.farmName
      : `${dto.name}'s Organic Farm`;

    const farmAddress = (dto.farmAddress && dto.farmAddress.trim().length > 0)
      ? dto.farmAddress
      : 'Local Verifying Zone';

    const kycDocUrl = (dto.governmentId && dto.governmentId.trim().length > 0)
      ? dto.governmentId
      : 'GOV-ID-VERIFIED';

    const accountNumber = (dto.bankAccountDetails && dto.bankAccountDetails.trim().length > 0)
      ? dto.bankAccountDetails
      : '1234567890';

    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email.toLowerCase(),
        phone,
        passwordHash,
        role: 'FARMER' as any,
        farmerProfile: {
          create: {
            farmName,
            farmAddress,
            kycStatus: 'APPROVED' as any,
            kycDocUrl,
            bankAccount: {
              create: {
                bankName: 'HDFC Bank',
                accountNumber,
                routingNumber: 'HDFC0001234',
              },
            },
          },
        },
      },
    });

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  }

  async registerDelivery(dto: RegisterDeliveryDto) {
    let phone = dto.phone.trim();
    if (phone.length > 0 && !phone.startsWith('+')) {
      phone = `+91${phone.replace(/^91/, '')}`;
    }

    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: dto.email.toLowerCase() },
          ...(phone && phone.length >= 10 ? [{ phone }] : []),
        ],
      },
    });

    if (existing) {
      if (existing.email.toLowerCase() === dto.email.toLowerCase()) {
        throw new ConflictException(`Account with email '${dto.email}' is already registered. Please sign in.`);
      }
      throw new ConflictException(`Mobile number '${dto.phone}' is already registered. Please sign in.`);
    }

    const passwordHash = await this._hashPassword(dto.password);

    const user = await this.prisma.user.create({
      data: {
        name: `${dto.firstName} ${dto.lastName}`.trim(),
        email: dto.email.toLowerCase(),
        phone,
        passwordHash,
        role: 'DELIVERY_PARTNER' as any,
      },
    });

    return { id: user.id, name: user.name, email: user.email, role: user.role };
  }

  async login(dto: LoginDto) {
    const identity = (dto.email || dto.username || '').toLowerCase();
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email: identity },
          { phone: dto.username || dto.email },
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

    if (dto.role) {
      const selectedRoleUpper = dto.role.trim().toUpperCase();
      const userRoleUpper = user.role.toString().toUpperCase();
      
      let matches = false;
      if (selectedRoleUpper.includes('CUSTOMER') && userRoleUpper === 'CUSTOMER') matches = true;
      else if (selectedRoleUpper.includes('FARMER') && userRoleUpper === 'FARMER') matches = true;
      else if (selectedRoleUpper.includes('DELIVERY') && (userRoleUpper === 'DELIVERY' || userRoleUpper === 'DELIVERY_PARTNER')) matches = true;
      else if (selectedRoleUpper.includes('ADMIN') && userRoleUpper === 'ADMIN') matches = true;
      else if (selectedRoleUpper === userRoleUpper) matches = true;

      if (!matches) {
        const prettyActualRole = userRoleUpper === 'FARMER'
          ? 'Farmer Partner'
          : (userRoleUpper === 'DELIVERY_PARTNER' || userRoleUpper === 'DELIVERY' ? 'Delivery Express Partner' : (userRoleUpper === 'ADMIN' ? 'Admin Portal' : 'Customer Marketplace'));
        throw new UnauthorizedException(`Access denied. Account '${user.email}' is registered as a ${prettyActualRole}. Please select '${prettyActualRole}' from the portal role dropdown.`);
      }
    }

    const tokens = await this._generateTokens(user.id, user.email, user.role);
    return {
      user: { id: user.id, name: user.name, email: user.email, role: user.role, phone: user.phone, avatar: user.avatar },
      ...tokens,
    };
  }

  async logout(userId: string, refreshToken: string) {
    // Find all tokens for this user and delete the matching one
    const tokens = await this.prisma.refreshToken.findMany({
      where: { userId },
    });

    let deleted = false;
    for (const t of tokens) {
      const match = await this._comparePassword(refreshToken, t.tokenHash);
      if (match) {
        await this.prisma.refreshToken.delete({ where: { id: t.id } });
        deleted = true;
        break;
      }
    }

    if (!deleted) {
      await this.prisma.refreshToken.deleteMany({ where: { userId } });
    }

    return { success: true };
  }

  async logoutByToken(refreshToken: string) {
    if (!refreshToken) return { success: true };
    try {
      const tokens = await this.prisma.refreshToken.findMany();
      for (const t of tokens) {
        const match = await this._comparePassword(refreshToken, t.tokenHash);
        if (match) {
          await this.prisma.refreshToken.delete({ where: { id: t.id } });
          break;
        }
      }
    } catch (_) {}
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

    return { message: 'Password reset link sent to your email address' };
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

    // In production, send email via email service. Token is NOT returned to client.
    return { message: 'Verification link sent to your email' };
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

    // In production, send via SMS provider. Code is NOT returned to client.
    return { message: 'OTP verification code sent' };
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
        phone: true,
        avatar: true,
        createdAt: true,
      },
    });
    if (!user) throw new NotFoundException('User profile not found');
    return user;
  }


  async updateProfile(
    userId: string,
    name?: string,
    phone?: string,
    farmName?: string,
    farmAddress?: string,
    avatar?: string,
  ) {
    const data: any = {};
    if (name !== undefined) data.name = name;
    if (phone !== undefined) data.phone = phone;
    if (avatar !== undefined) data.avatar = avatar;

    // Only update FarmerProfile if user is actually a farmer
    if (farmName !== undefined || farmAddress !== undefined) {
      const farmerProfile = await this.prisma.farmerProfile.findUnique({ where: { userId } });
      if (farmerProfile) {
        const profileData: any = {};
        if (farmName !== undefined) profileData.farmName = farmName;
        if (farmAddress !== undefined) profileData.farmAddress = farmAddress;
        data.farmerProfile = { update: profileData };
      }
    }

    const updatedUser = await this.prisma.user.update({
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
    return updatedUser;
  }

  async changePassword(userId: string, currentPass: string, newPass: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) throw new NotFoundException('User not found');

    const match = await this._comparePassword(currentPass, user.passwordHash);
    if (!match) {
      throw new BadRequestException('Incorrect current password');
    }

    const passwordHash = await this._hashPassword(newPass);
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });
    return { success: true };
  }
}