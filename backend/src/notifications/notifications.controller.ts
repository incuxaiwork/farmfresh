import { Controller, Get, Patch, Param, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { NotificationsService } from './notifications.service';
import { SuccessResponseDto } from '../common/dto/api-response.dto';

@ApiTags('Notifications')
@Controller('notifications')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get user notifications' })
  async getNotifications(@Req() req: any, @Query('page') page: string, @Query('limit') limit: string) {
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 20;
    const data = await this.notificationsService.getUserNotifications(req.user.id, pageNum, limitNum);
    return new SuccessResponseDto('Notifications loaded successfully', data);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  async markAllAsRead(@Req() req: any) {
    await this.notificationsService.markAllAsRead(req.user.id);
    return new SuccessResponseDto('All notifications marked as read', null);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark a notification as read' })
  async markAsRead(@Req() req: any, @Param('id') id: string) {
    await this.notificationsService.markAsRead(req.user.id, id);
    return new SuccessResponseDto('Notification marked as read', null);
  }
}
