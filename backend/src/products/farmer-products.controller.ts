import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';
import { ProductsService } from './products.service';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { PrismaService } from '../database/prisma.service';
import { SuccessResponseDto } from '../common/dto/api-response.dto';

@ApiTags('Products')
@Controller('farmer/products')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('FARMER')
@ApiBearerAuth('JWT-auth')
export class FarmerProductsController {
  constructor(
    private readonly productsService: ProductsService,
    private readonly prisma: PrismaService,
  ) {}

  @Get()
  async getFarmerProducts(
    @CurrentUser() user: CurrentUserPayload,
    @Query('search') search?: string,
    @Query('status') status?: any,
  ) {
    const profile = await this.prisma.farmerProfile.findUnique({
      where: { userId: user.id },
    });
    
    if (!profile) {
      return { success: true, data: [] };
    }

    const data = await this.productsService.findAll({
      farmerId: profile.id,
      search,
      status,
      role: 'FARMER',
    });

    return new SuccessResponseDto('Farmer products retrieved successfully', data);
  }
}
