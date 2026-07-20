import { Controller, Get, Patch, UseGuards, Req, Body } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { FarmerService } from './farmer.service';
import { SuccessResponseDto } from '../common/dto/api-response.dto';

@ApiTags('Farmer')
@Controller('farmer')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@Roles('FARMER')
@ApiBearerAuth('JWT-auth')
export class FarmerController {
  constructor(private readonly farmerService: FarmerService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get farmer dashboard aggregates' })
  async getDashboard(@Req() req: any) {
    const data = await this.farmerService.getDashboard(req.user.id);
    return new SuccessResponseDto('Dashboard loaded successfully', data);
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Get farmer statistics aggregates' })
  async getStatistics(@Req() req: any) {
    const data = await this.farmerService.getStatistics(req.user.id);
    return new SuccessResponseDto('Statistics loaded successfully', data);
  }

  @Get('earnings')
  @ApiOperation({ summary: 'Get farmer earnings breakdown' })
  async getEarnings(@Req() req: any) {
    const data = await this.farmerService.getStatistics(req.user.id);
    return new SuccessResponseDto('Earnings loaded successfully', data);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get farmer transactions' })
  async getTransactions(@Req() req: any) {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const data = await this.farmerService.getTransactions(req.user.id, page, limit);
    return new SuccessResponseDto('Transactions loaded successfully', data);
  }

  @Patch('location')
  @ApiOperation({ summary: 'Update farm GPS coordinates for delivery navigation' })
  async updateLocation(@Req() req: any, @Body() body: { latitude: number; longitude: number }) {
    const data = await this.farmerService.updateLocation(req.user.id, body.latitude, body.longitude);
    return new SuccessResponseDto('Farm location updated successfully', data);
  }
}

