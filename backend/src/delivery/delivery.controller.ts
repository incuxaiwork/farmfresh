import { Controller, Get, Post, Patch, Param, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { DeliveryService } from './delivery.service';
import { AssignDriverDto } from './dto/assign-driver.dto';
import { UpdateLocationDto } from './dto/update-location.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';

@ApiTags('Logistics & Delivery')
@Controller('delivery')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('JWT-auth')
export class DeliveryController {
  constructor(private readonly deliveryService: DeliveryService) {}

  @Post('assign')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Assign a delivery task assignment to a driver (Admin Only)' })
  @ApiResponse({ status: 201, description: 'Delivery task assigned successfully' })
  async assignDriver(@Body() dto: AssignDriverDto) {
    const data = await this.deliveryService.assignDriver(dto);
    return new SuccessResponseDto('Delivery driver assigned successfully', data);
  }

  @Get('farmer-location/:farmerId')
  @Roles('DELIVERY_PARTNER', 'ADMIN')
  @ApiOperation({ summary: 'Get farmer GPS coordinates for delivery navigation' })
  async getFarmerLocation(@CurrentUser() user: CurrentUserPayload, @Param('farmerId') farmerId: string) {
    const data = await this.deliveryService.getFarmerLocation(farmerId);
    return new SuccessResponseDto('Farmer location loaded successfully', data);
  }

  @Get()
  @Roles('DELIVERY_PARTNER', 'ADMIN', 'CUSTOMER')
  @ApiOperation({ summary: 'Query active or historical delivery task assignments' })
  async findAll(
    @CurrentUser() user: CurrentUserPayload,
    @Query('status') status?: 'PENDING_ASSIGNMENT' | 'ASSIGNED' | 'ACCEPTED' | 'REJECTED' | 'HEADING_TO_PICKUP' | 'PICKED_UP' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED',
    @Query('driverId') driverId?: string,
  ) {
    const data = await this.deliveryService.findAll(user.id, user.role, { status, driverId });
    return new SuccessResponseDto('Deliveries loaded successfully', data);
  }

  @Get('dashboard')
  @Roles('DELIVERY_PARTNER')
  async getDashboard(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.getDashboard(user.id);
    return new SuccessResponseDto('Dashboard loaded successfully', data);
  }

  @Get('statistics')
  @Roles('DELIVERY_PARTNER')
  async getStatistics(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.getStatistics(user.id);
    return new SuccessResponseDto('Statistics loaded successfully', data);
  }

  @Get('earnings')
  @Roles('DELIVERY_PARTNER')
  async getEarnings(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.getEarnings(user.id);
    return new SuccessResponseDto('Earnings loaded successfully', data);
  }

  @Get('transactions')
  @Roles('DELIVERY_PARTNER')
  async getTransactions(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.getTransactions(user.id);
    return new SuccessResponseDto('Transactions loaded successfully', data);
  }

  @Get('history')
  @Roles('DELIVERY_PARTNER')
  async getHistory(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.getHistory(user.id);
    return new SuccessResponseDto('History loaded successfully', data);
  }

  @Get('profile')
  @Roles('DELIVERY_PARTNER')
  async getProfile(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.getProfile(user.id);
    return new SuccessResponseDto('Profile loaded successfully', data);
  }

  @Patch('profile')
  @Roles('DELIVERY_PARTNER')
  async updateProfile(@CurrentUser() user: CurrentUserPayload, @Body() body: any) {
    const data = await this.deliveryService.updateProfile(user.id, body);
    return new SuccessResponseDto('Profile updated successfully', data);
  }

  @Patch('toggle-availability')
  @Roles('DELIVERY_PARTNER')
  async toggleAvailability(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.deliveryService.toggleAvailability(user.id);
    return new SuccessResponseDto('Availability toggled successfully', data);
  }

  @Get(':id')
  @Roles('DELIVERY_PARTNER', 'ADMIN', 'CUSTOMER')
  @ApiOperation({ summary: 'Retrieve specific delivery status details by assignment ID' })
  async findOne(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.deliveryService.findOne(id, user.id, user.role);
    return new SuccessResponseDto('Delivery details loaded successfully', data);
  }

  @Patch(':id/accept')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Accept assigned delivery task (Driver Only)' })
  async acceptDelivery(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.deliveryService.acceptDelivery(id, user.id, user.role);
    return new SuccessResponseDto('Delivery assignment accepted successfully', data);
  }

  @Patch(':id/reject')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Reject assigned delivery task (Driver Only)' })
  async rejectDelivery(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.deliveryService.rejectDelivery(id, user.id, user.role);
    return new SuccessResponseDto('Delivery assignment rejected successfully', data);
  }

  @Patch(':id/pickup')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Start transit heading to farm to retrieve order crops (Driver Only)' })
  async startPickup(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.deliveryService.startPickup(id, user.id, user.role);
    return new SuccessResponseDto('Pickup route started successfully', data);
  }

  @Patch(':id/confirm-pickup')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Confirm package retrieval at farm (Driver Only)' })
  async confirmPickup(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.deliveryService.confirmPickup(id, user.id, user.role);
    return new SuccessResponseDto('Pickup confirmed successfully', data);
  }

  @Patch(':id/start')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Start route heading to customer doorstep (Driver Only)' })
  async startDelivery(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.deliveryService.startDelivery(id, user.id, user.role);
    return new SuccessResponseDto('Delivery route started successfully', data);
  }

  @Patch(':id/location')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Update live coordinates location (Driver Only, pushes live tracking signals)' })
  async updateLocation(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: UpdateLocationDto,
  ) {
    const data = await this.deliveryService.updateLocation(id, user.id, user.role, dto);
    return new SuccessResponseDto('Driver location updated successfully', data);
  }

  @Post(':id/verify-otp')
  @HttpCode(HttpStatus.OK)
  @Roles('DELIVERY_PARTNER')
  @ApiOperation({ summary: 'Validate OTP code shared by customer to complete order delivery (Driver Only)' })
  async verifyOtpAndComplete(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body('otp') otp: string,
  ) {
    const data = await this.deliveryService.verifyOtpAndComplete(id, user.id, user.role, otp);
    return new SuccessResponseDto('Delivery completed successfully', data);
  }
}
