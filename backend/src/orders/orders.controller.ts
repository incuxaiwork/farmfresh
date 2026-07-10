import { Controller, Get, Post, Patch, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';

@ApiTags('Orders')
@Controller('orders')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('JWT-auth')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Checkout active shopping cart and create a new order (Customer Only)' })
  @ApiResponse({ status: 201, description: 'Order created and inventory reserved' })
  async create(@CurrentUser() user: CurrentUserPayload, @Body() dto: CreateOrderDto) {
    const data = await this.ordersService.create(user.id, dto);
    return new SuccessResponseDto('Order placed and inventory reserved successfully', data);
  }

  @Get()
  @Roles('CUSTOMER', 'FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Retrieve order histories lists (Customers see own; Farmers see sub-items; Admins see all)' })
  async findAll(
    @CurrentUser() user: CurrentUserPayload,
    @Query('status') status?: string,
    @Query('farmerId') farmerId?: string,
    @Query('customerId') customerId?: string,
    @Query('sortBy') sortBy?: 'newest' | 'oldest' | 'amount',
  ) {
    const data = await this.ordersService.findAll(user.id, user.role, { status, farmerId, customerId, sortBy });
    return new SuccessResponseDto('Orders loaded successfully', data);
  }

  @Get(':id')
  @Roles('CUSTOMER', 'FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Retrieve specific order details by ID' })
  async findOne(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.ordersService.findOne(id, user.id, user.role);
    return new SuccessResponseDto('Order details loaded successfully', data);
  }

  @Patch(':id/status')
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Update order status parameters (Farmers accept/preparing own items; Admins edit main status)' })
  async updateStatus(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: UpdateOrderStatusDto,
  ) {
    const data = await this.ordersService.updateStatus(id, user.id, user.role, dto.status);
    return new SuccessResponseDto('Order status updated successfully', data);
  }

  @Patch(':id/cancel')
  @Roles('CUSTOMER', 'ADMIN')
  @ApiOperation({ summary: 'Cancel a pending order and release reserved stock (Customer or Admin Only)' })
  async cancel(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.ordersService.cancel(id, user.id, user.role);
    return new SuccessResponseDto('Order cancelled successfully', data);
  }
}
