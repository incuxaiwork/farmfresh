import { Controller, Get, Patch, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { InventoryService } from './inventory.service';
import { UpdateInventoryDto } from './dto/update-inventory.dto';
import { AdjustStockDto } from './dto/adjust-stock.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';

@ApiTags('Inventory')
@Controller('inventory')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('JWT-auth')
export class InventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  @Get()
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Retrieve stock lists (Farmer owns own crops stock; Admin views all)' })
  async findAll(
    @CurrentUser() user: CurrentUserPayload,
    @Query('status') status?: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' | 'DISCONTINUED',
    @Query('farmerId') farmerId?: string,
    @Query('categoryId') categoryId?: string,
    @Query('search') search?: string,
    @Query('sortBy') sortBy?: 'stock' | 'updatedAt' | 'productName',
    @Query('sortOrder') sortOrder?: 'asc' | 'desc',
  ) {
    const data = await this.inventoryService.findAll(user.id, user.role, {
      status, farmerId, categoryId, search, sortBy, sortOrder
    });
    return new SuccessResponseDto('Inventories loaded successfully', data);
  }

  @Get('history')
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Retrieve auditable logs detailing stock additions and adjustments' })
  async getHistory(
    @CurrentUser() user: CurrentUserPayload,
    @Query('inventoryId') inventoryId?: string,
    @Query('action') action?: 'ADD' | 'REMOVE' | 'ADJUST',
  ) {
    const data = await this.inventoryService.getHistory(user.id, user.role, { inventoryId, action });
    return new SuccessResponseDto('Inventory transaction logs loaded successfully', data);
  }

  @Get('low-stock')
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Retrieve inventories containing stock sizes lower than min levels thresholds' })
  async getLowStockAlerts(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.inventoryService.getLowStockAlerts(user.id, user.role);
    return new SuccessResponseDto('Low stock alerts loaded successfully', data);
  }

  @Get(':id')
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Retrieve detailed stock information of specific inventory record' })
  async findOne(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.inventoryService.findOne(id, user.id, user.role);
    return new SuccessResponseDto('Inventory details loaded successfully', data);
  }

  @Patch(':id')
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Update parameters configurations (reorder/min levels limit)' })
  async update(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: UpdateInventoryDto,
  ) {
    const data = await this.inventoryService.update(id, user.id, user.role, dto);
    return new SuccessResponseDto('Inventory configurations updated successfully', data);
  }

  @Patch(':id/add')
  @HttpCode(HttpStatus.OK)
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Replenish or refill available crop stock' })
  async addStock(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: AdjustStockDto,
  ) {
    const data = await this.inventoryService.addStock(id, user.id, user.role, dto);
    return new SuccessResponseDto('Stock added successfully', data);
  }

  @Patch(':id/remove')
  @HttpCode(HttpStatus.OK)
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Deduct or remove stock levels manually' })
  async removeStock(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: AdjustStockDto,
  ) {
    const data = await this.inventoryService.removeStock(id, user.id, user.role, dto);
    return new SuccessResponseDto('Stock removed successfully', data);
  }

  @Patch(':id/adjust')
  @HttpCode(HttpStatus.OK)
  @Roles('FARMER', 'ADMIN')
  @ApiOperation({ summary: 'Manually adjust or overwrite stock levels to exact volumes count' })
  async adjustStock(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: AdjustStockDto,
  ) {
    const data = await this.inventoryService.adjustStock(id, user.id, user.role, dto);
    return new SuccessResponseDto('Stock adjusted successfully', data);
  }
}
