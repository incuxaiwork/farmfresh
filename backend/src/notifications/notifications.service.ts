import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async getUserNotifications(userId: string, page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.notification.count({ where: { userId } }),
    ]);

    const unreadCount = await this.prisma.notification.count({
      where: { userId, isRead: false },
    });

    return {
      notifications: notifications.map(n => ({
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: n.isRead,
        createdAt: n.createdAt,
        data: null // Since schema doesn't have a data field, returning null or parsing from somewhere if needed
      })),
      total,
      unreadCount,
      hasMore: skip + notifications.length < total,
    };
  }

  async markAsRead(userId: string, notificationId: string) {
    return this.prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId: string) {
    return this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }
}
