import { Controller, Post, Get, Patch, Delete, Body, Param, Query, UseGuards, HttpCode, HttpStatus, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';

@ApiTags('Products')
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('FARMER')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Publish a new crop harvest product catalog (Farmer Only)' })
  @ApiResponse({ status: 201, description: 'Product draft submitted successfully' })
  async create(@CurrentUser() user: CurrentUserPayload, @Body() dto: CreateProductDto) {
    const data = await this.productsService.create(user.id, dto);
    return new SuccessResponseDto('Product draft submitted successfully', data);
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'Filter and query available products catalog list' })
  async findAll(
    @Req() req: any,
    @Query('status') status?: 'APPROVED' | 'DRAFT' | 'PENDING_APPROVAL' | 'REJECTED' | 'ARCHIVED',
    @Query('categoryId') categoryId?: string,
    @Query('subCategoryId') subCategoryId?: string,
    @Query('farmerId') farmerId?: string,
    @Query('minPrice') minPrice?: number,
    @Query('maxPrice') maxPrice?: number,
    @Query('organic') organic?: boolean,
    @Query('featured') featured?: boolean,
    @Query('seasonal') seasonal?: boolean,
    @Query('search') search?: string,
    @Query('sortBy') sortBy?: 'price' | 'popularity' | 'newest' | 'rating' | 'sold',
    @Query('sortOrder') sortOrder?: 'asc' | 'desc',
  ) {
    // Read role from request payload if context exists
    const userRole = req.user?.role ?? 'CUSTOMER';
    const data = await this.productsService.findAll({
      status, categoryId, subCategoryId, farmerId, minPrice, maxPrice, organic, featured, seasonal, search, sortBy, sortOrder, role: userRole
    });
    return new SuccessResponseDto('Products catalog loaded successfully', data);
  }

  @Public()
  @Get('featured')
  @ApiOperation({ summary: 'Retrieve high priority featured banner products list' })
  async getFeatured() {
    const data = await this.productsService.getFeatured();
    return new SuccessResponseDto('Featured products loaded successfully', data);
  }

  @Public()
  @Get('popular')
  @ApiOperation({ summary: 'Retrieve popular highly-viewed catalog products list' })
  async getPopular() {
    const data = await this.productsService.getPopular();
    return new SuccessResponseDto('Popular products loaded successfully', data);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Retrieve specific product details by ID' })
  async findOne(@Req() req: any, @Param('id') id: string) {
    const userRole = req.user?.role ?? 'CUSTOMER';
    const data = await this.productsService.findOne(id, userRole);
    return new SuccessResponseDto('Product loaded successfully', data);
  }

  @Patch(':id')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Modify product parameters (Owner Farmer or Admin Only)' })
  async update(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: UpdateProductDto,
  ) {
    const data = await this.productsService.update(id, user.id, user.role, dto);
    return new SuccessResponseDto('Product details updated successfully', data);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Soft delete product from catalog (Owner Farmer or Admin Only)' })
  async remove(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.productsService.remove(id, user.id, user.role);
    return new SuccessResponseDto('Product catalog soft deleted successfully', data);
  }

  @Patch(':id/status')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Moderate and change product approval status (Admin Only)' })
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: 'APPROVED' | 'REJECTED' | 'DRAFT' | 'PENDING_APPROVAL' | 'ARCHIVED',
  ) {
    const data = await this.productsService.updateStatus(id, status);
    return new SuccessResponseDto('Product status moderated successfully', data);
  }

  @Patch(':id/stock')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Refill or update crop available stock quantity' })
  async updateStock(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body('stock') stock: number,
  ) {
    const data = await this.productsService.updateStock(id, user.id, user.role, stock);
    return new SuccessResponseDto('Product inventory stock updated successfully', data);
  }

  @Patch(':id/price')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Update product base and discount pricing' })
  async updatePrice(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body('price') price: number,
    @Body('discountPrice') discountPrice?: number,
  ) {
    const data = await this.productsService.updatePrice(id, user.id, user.role, price, discountPrice);
    return new SuccessResponseDto('Product pricing updated successfully', data);
  }

  @Post(':id/images')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Upload and attach display images urls to product details' })
  async addImages(
    @Param('id') id: string,
    @Body('imageUrls') imageUrls: string[],
  ) {
    const data = await this.productsService.addImages(id, imageUrls);
    return new SuccessResponseDto('Product images uploaded successfully', data);
  }

  @Delete(':id/images/:imageId')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Remove a specific image record from product details' })
  async deleteImage(
    @Param('id') id: string,
    @Param('imageId') imageId: string,
  ) {
    const data = await this.productsService.deleteImage(id, imageId);
    return new SuccessResponseDto('Product image removed successfully', data);
  }
}
