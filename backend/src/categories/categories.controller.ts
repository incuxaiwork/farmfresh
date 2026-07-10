import { Controller, Post, Get, Patch, Delete, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { Public } from '../common/decorators/public.decorator';

@ApiTags('Categories')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Create a new category (Admin Only)' })
  @ApiResponse({ status: 201, description: 'Category created successfully' })
  async create(@Body() dto: CreateCategoryDto) {
    const data = await this.categoriesService.create(dto);
    return new SuccessResponseDto('Category created successfully', data);
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'Get all categories with dynamic filter and sort options' })
  async findAll(
    @Query('status') status?: 'ACTIVE' | 'INACTIVE' | 'ARCHIVED',
    @Query('parentId') parentId?: string,
    @Query('search') search?: string,
    @Query('sortBy') sortBy?: 'name' | 'displayOrder' | 'createdAt',
    @Query('sortOrder') sortOrder?: 'asc' | 'desc',
  ) {
    const data = await this.categoriesService.findAll({ status, parentId, search, sortBy, sortOrder });
    return new SuccessResponseDto('Categories loaded successfully', data);
  }

  @Public()
  @Get('tree')
  @ApiOperation({ summary: 'Get category list in a hierarchical tree structure' })
  async getTree() {
    const data = await this.categoriesService.getTree();
    return new SuccessResponseDto('Categories tree loaded successfully', data);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get specific category details by ID' })
  async findOne(@Param('id') id: string) {
    const data = await this.categoriesService.findOne(id);
    return new SuccessResponseDto('Category loaded successfully', data);
  }

  @Patch(':id')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Update category details by ID (Admin Only)' })
  async update(@Param('id') id: string, @Body() dto: UpdateCategoryDto) {
    const data = await this.categoriesService.update(id, dto);
    return new SuccessResponseDto('Category updated successfully', data);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Soft delete category by ID (Admin Only)' })
  async remove(@Param('id') id: string) {
    const data = await this.categoriesService.remove(id);
    return new SuccessResponseDto('Category soft deleted successfully', data);
  }

  @Patch(':id/restore')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Restore a soft-deleted category by ID (Admin Only)' })
  async restore(@Param('id') id: string) {
    const data = await this.categoriesService.restore(id);
    return new SuccessResponseDto('Category restored successfully', data);
  }

  @Patch(':id/status')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Change category active status (Admin Only)' })
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: 'ACTIVE' | 'INACTIVE' | 'ARCHIVED',
  ) {
    const data = await this.categoriesService.updateStatus(id, status);
    return new SuccessResponseDto('Category status updated successfully', data);
  }

  @Post(':id/image')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Submit new category background display image (Admin Only)' })
  async uploadImage(
    @Param('id') id: string,
    @Body('imageUrl') imageUrl: string,
  ) {
    const data = await this.categoriesService.uploadImage(id, imageUrl);
    return new SuccessResponseDto('Category image uploaded successfully', data);
  }
}
