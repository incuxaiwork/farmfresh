import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AdminCreateProductDto } from './dto/admin-create-product.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@ApiTags('Admin')
@Controller('admin')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('ADMIN')
@ApiBearerAuth('JWT-auth')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get admin dashboard stats and recent activity' })
  async getDashboard() {
    const data = await this.adminService.getDashboard();
    return new SuccessResponseDto('Dashboard loaded', data);
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Get detailed platform statistics' })
  async getStatistics(
    @Query('period') period?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const data = await this.adminService.getStatistics({ period, startDate, endDate });
    return new SuccessResponseDto('Statistics loaded', data);
  }

  @Get('customers')
  @ApiOperation({ summary: 'List all customers' })
  async getCustomers(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getCustomers({
      search,
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Customers loaded', data);
  }

  @Patch('customers/:id/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update customer account status' })
  async updateCustomerStatus(@Param('id') id: string, @Body('status') status: string) {
    await this.adminService.updateCustomerStatus(id, status);
    return new SuccessResponseDto('Customer status updated');
  }

  @Get('farmers')
  @ApiOperation({ summary: 'List all farmers' })
  async getFarmers(
    @Query('search') search?: string,
    @Query('kycStatus') kycStatus?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getFarmers({
      search,
      kycStatus,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Farmers loaded', data);
  }

  @Patch('farmers/:id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve farmer KYC verification' })
  async approveFarmer(@Param('id') id: string) {
    await this.adminService.approveFarmer(id);
    return new SuccessResponseDto('Farmer approved');
  }

  @Patch('farmers/:id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject farmer KYC verification' })
  async rejectFarmer(@Param('id') id: string) {
    await this.adminService.rejectFarmer(id);
    return new SuccessResponseDto('Farmer rejected');
  }

  @Patch('farmers/:id/suspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend farmer account' })
  async suspendFarmer(@Param('id') id: string) {
    await this.adminService.suspendFarmer(id);
    return new SuccessResponseDto('Farmer suspended');
  }

  @Get('delivery-partners')
  @ApiOperation({ summary: 'List all delivery partners' })
  async getDeliveryPartners(
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getDeliveryPartners({
      search,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Delivery partners loaded', data);
  }

  @Patch('delivery-partners/:id/suspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend delivery partner account' })
  async suspendDeliveryPartner(@Param('id') id: string) {
    await this.adminService.suspendDeliveryPartner(id);
    return new SuccessResponseDto('Delivery partner suspended');
  }

  @Patch('delivery-partners/:id/activate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Activate delivery partner account' })
  async activateDeliveryPartner(@Param('id') id: string) {
    await this.adminService.activateDeliveryPartner(id);
    return new SuccessResponseDto('Delivery partner activated');
  }

  @Get('orders')
  @ApiOperation({ summary: 'List all orders (admin view)' })
  async getOrders(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getOrders({
      search,
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Orders loaded', data);
  }

  @Get('coupons')
  @ApiOperation({ summary: 'List all coupons' })
  async getCoupons(
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getCoupons({
      search,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Coupons loaded', data);
  }

  @Post('coupons')
  @ApiOperation({ summary: 'Create a new coupon' })
  async createCoupon(@Body() dto: any) {
    const data = await this.adminService.createCoupon(dto);
    return new SuccessResponseDto('Coupon created', data);
  }

  @Patch('coupons/:id')
  @ApiOperation({ summary: 'Update an existing coupon' })
  async updateCoupon(@Param('id') id: string, @Body() dto: any) {
    const data = await this.adminService.updateCoupon(id, dto);
    return new SuccessResponseDto('Coupon updated', data);
  }

  @Delete('coupons/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a coupon' })
  async deleteCoupon(@Param('id') id: string) {
    await this.adminService.deleteCoupon(id);
    return new SuccessResponseDto('Coupon deleted');
  }

  @Get('banners')
  @ApiOperation({ summary: 'List all banners' })
  async getBanners(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getBanners({
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Banners loaded', data);
  }

  @Post('banners')
  @ApiOperation({ summary: 'Create a new banner' })
  async createBanner(@Body() dto: any) {
    const data = await this.adminService.createBanner(dto);
    return new SuccessResponseDto('Banner created', data);
  }

  @Patch('banners/:id')
  @ApiOperation({ summary: 'Update an existing banner' })
  async updateBanner(@Param('id') id: string, @Body() dto: any) {
    const data = await this.adminService.updateBanner(id, dto);
    return new SuccessResponseDto('Banner updated', data);
  }

  @Delete('banners/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a banner' })
  async deleteBanner(@Param('id') id: string) {
    await this.adminService.deleteBanner(id);
    return new SuccessResponseDto('Banner deleted');
  }

  @Get('notifications')
  @ApiOperation({ summary: 'List all notifications' })
  async getNotifications(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('role') role?: string,
  ) {
    const data = await this.adminService.getNotifications({
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
      role,
    });
    return new SuccessResponseDto('Notifications loaded', data);
  }

  @Post('notifications/send')
  @ApiOperation({ summary: 'Send notification to users' })
  async sendNotification(@Body() dto: { title: string; body: string; targetType: string; targetValue?: string; type?: string }) {
    const data = await this.adminService.sendNotification(dto);
    return new SuccessResponseDto('Notification sent', data);
  }

  @Get('settings')
  @ApiOperation({ summary: 'Get all platform settings' })
  async getSettings() {
    const data = await this.adminService.getSettings();
    return new SuccessResponseDto('Settings loaded', data);
  }

  @Patch('settings')
  @ApiOperation({ summary: 'Update platform settings' })
  async updateSettings(@Body() dto: Record<string, string>) {
    await this.adminService.updateSettings(dto);
    return new SuccessResponseDto('Settings updated');
  }

  @Get('audit-logs')
  @ApiOperation({ summary: 'List audit logs' })
  async getAuditLogs(
    @Query('action') action?: string,
    @Query('entity') entity?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getAuditLogs({
      action,
      entity,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Audit logs loaded', data);
  }

  @Get('cms')
  @ApiOperation({ summary: 'Get all CMS content' })
  async getCmsContent() {
    const data = await this.adminService.getCmsContent();
    return new SuccessResponseDto('CMS content loaded', data);
  }

  @Patch('cms/:key')
  @ApiOperation({ summary: 'Update CMS content by key' })
  async updateCmsContent(@Param('key') key: string, @Body() dto: { title?: string; content?: string }) {
    const data = await this.adminService.updateCmsContent(key, dto);
    return new SuccessResponseDto('CMS content updated', data);
  }

  @Get('reviews')
  @ApiOperation({ summary: 'List all reviews' })
  async getReviews(
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getReviews({
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Reviews loaded', data);
  }

  @Patch('reviews/:id/moderate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Moderate a review (approve/reject/flag)' })
  async moderateReview(@Param('id') id: string, @Body('action') action: 'approve' | 'reject' | 'flag') {
    const data = await this.adminService.moderateReview(id, action);
    return new SuccessResponseDto('Review moderated', data);
  }

  @Get('payouts')
  @ApiOperation({ summary: 'List all payout requests' })
  async getPayouts(
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getPayouts({
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Payouts loaded', data);
  }

  @Patch('payouts/:id/process')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Process a pending payout' })
  async processPayout(@Param('id') id: string) {
    const data = await this.adminService.processPayout(id);
    return new SuccessResponseDto('Payout processed', data);
  }

  @Post('products')
  @ApiOperation({ summary: 'Create a product on behalf of a farmer' })
  async createProduct(@Body() dto: AdminCreateProductDto) {
    const data = await this.adminService.createProduct(dto);
    return new SuccessResponseDto('Product created successfully', data);
  }

  @Get('products')
  @ApiOperation({ summary: 'List all products (admin view)' })
  async getProducts(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getProducts({
      search,
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Products loaded', data);
  }

  @Get('inventory')
  @ApiOperation({ summary: 'List all inventory items (admin view)' })
  async getInventory(
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getInventory({
      search,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Inventory loaded', data);
  }

  @Get('deliveries')
  @ApiOperation({ summary: 'List all delivery assignments' })
  async getDeliveries(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getDeliveries({
      search,
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Deliveries loaded', data);
  }

  @Get('order-issues')
  @ApiOperation({ summary: 'List all order issues' })
  async getOrderIssues(
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.adminService.getOrderIssues({
      status,
      page: page ? parseInt(page) : 1,
      limit: limit ? parseInt(limit) : 20,
    });
    return new SuccessResponseDto('Order issues loaded', data);
  }

  @Patch('order-issues/:id/resolve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Resolve an order issue' })
  async resolveIssue(@Param('id') id: string, @Body('resolution') resolution: string) {
    const data = await this.adminService.resolveIssue(id, resolution);
    return new SuccessResponseDto('Issue resolved', data);
  }
}
