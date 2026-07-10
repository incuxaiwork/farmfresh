import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { PrismaService } from '../database/prisma.service';
import { Public } from '../common/decorators/public.decorator';

@ApiTags('System Health Checks')
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: 'Check overall system and services status (Public Endpoint)' })
  @ApiResponse({ status: 200, description: 'System components are functional' })
  async check() {
    let dbStatus = 'HEALTHY';
    try {
      // Execute simple query to test DB connectivity
      await this.prisma.$queryRaw`SELECT 1`;
    } catch (e) {
      dbStatus = 'UNHEALTHY';
    }

    return {
      status: dbStatus === 'HEALTHY' ? 'OK' : 'DEGRADED',
      timestamp: new Date().toISOString(),
      services: {
        application: 'UP',
        database: dbStatus,
        cache: 'HEALTHY', // Redis fallback simulation status
      },
    };
  }
}
