import { Controller, Post, Get, Body, UseGuards, Req, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterCustomerDto } from './dto/register-customer.dto';
import { RegisterFarmerDto } from './dto/register-farmer.dto';
import { RegisterDeliveryDto } from './dto/register-delivery.dto';
import { LoginDto } from './dto/login.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { VerifyOtpDto, SendOtpDto } from './dto/verify-otp.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { AuthGuard } from '@nestjs/passport';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register/customer')
  @ApiOperation({ summary: 'Register a new Customer' })
  @ApiResponse({ status: 201, description: 'Customer account registered successfully' })
  async registerCustomer(@Body() dto: RegisterCustomerDto) {
    const data = await this.authService.registerCustomer(dto);
    return new SuccessResponseDto('Customer account registered successfully', data);
  }

  @Public()
  @Post('register/farmer')
  @ApiOperation({ summary: 'Register a new Farmer Partner' })
  @ApiResponse({ status: 201, description: 'Farmer account registered and pending verification' })
  async registerFarmer(@Body() dto: RegisterFarmerDto) {
    const data = await this.authService.registerFarmer(dto);
    return new SuccessResponseDto('Farmer account registered, pending verification', data);
  }

  @Public()
  @Post('register/delivery')
  @ApiOperation({ summary: 'Register a new Delivery Partner' })
  @ApiResponse({ status: 201, description: 'Delivery partner account registered and pending verification' })
  async registerDelivery(@Body() dto: RegisterDeliveryDto) {
    const data = await this.authService.registerDelivery(dto);
    return new SuccessResponseDto('Delivery partner registered, pending verification', data);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login user and retrieve tokens' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  async login(@Body() dto: LoginDto) {
    const data = await this.authService.login(dto);
    return new SuccessResponseDto('Login successful', data);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Log out active session and revoke refresh tokens' })
  async logout(@Body('refreshToken') token: string) {
    const data = await this.authService.logout(token);
    return new SuccessResponseDto('Logout successful', data);
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt-refresh'))
  @ApiOperation({ summary: 'Rotate active JWT session tokens' })
  async refresh(@Req() req: any) {
    const data = await this.authService.refresh(
      req.user.id,
      req.user.email,
      req.user.role,
      req.user.refreshToken,
    );
    return new SuccessResponseDto('Tokens refreshed successfully', data);
  }

  @Public()
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit email to generate password reset links' })
  async forgotPassword(@Body('email') email: string) {
    const data = await this.authService.forgotPassword(email);
    return new SuccessResponseDto('Password reset email dispatched successfully', data);
  }

  @Public()
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify reset token and submit new password' })
  async resetPassword(@Body() dto: ResetPasswordDto) {
    const data = await this.authService.resetPassword(dto);
    return new SuccessResponseDto('Password has been updated successfully', data);
  }

  @Post('send-email-verification')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Dispatch verification links to user email' })
  async sendEmailVerification(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.authService.sendEmailVerification(user.id);
    return new SuccessResponseDto('Verification link dispatched successfully', data);
  }

  @Public()
  @Post('verify-email')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit email verification tokens' })
  async verifyEmail(@Query('token') token: string) {
    const data = await this.authService.verifyEmail(token);
    return new SuccessResponseDto('Email verified successfully', data);
  }

  @Public()
  @Post('send-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send SMS verification OTP code' })
  async sendOtp(@Body() dto: SendOtpDto) {
    const data = await this.authService.sendOtp(dto.phone);
    return new SuccessResponseDto('Verification OTP sent successfully', data);
  }

  @Public()
  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit SMS verification OTP code' })
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    const data = await this.authService.verifyOtp(dto.phone, dto.code);
    return new SuccessResponseDto('Phone number verified successfully', data);
  }

  @Get('profile')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Retrieve active authenticated user profile details' })
  async getProfile(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.authService.getProfile(user.id);
    return new SuccessResponseDto('Profile loaded successfully', data);
  }
}
