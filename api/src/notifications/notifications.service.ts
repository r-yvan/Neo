import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
} from '../common/dto/pagination.dto.js';
import {
  NotificationListQueryDto,
  UpdateNotificationSettingsDto,
} from './dto/notification.dto.js';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userId: string, query: NotificationListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { userId };

    const [data, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async findUnread(userId: string, query: NotificationListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { userId, isRead: false };

    const [data, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async markRead(userId: string, id: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id, userId },
    });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    return this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }

  async markAllRead(userId: string) {
    const result = await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
    return { updated: result.count };
  }

  async remove(userId: string, id: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id, userId },
    });
    if (!notification) {
      throw new NotFoundException('Notification not found');
    }

    await this.prisma.notification.delete({ where: { id } });
    return { message: 'Notification deleted' };
  }

  async getSettings(userId: string) {
    let settings = await this.prisma.notificationSetting.findUnique({
      where: { userId },
    });
    if (!settings) {
      settings = await this.prisma.notificationSetting.create({
        data: { userId },
      });
    }
    return settings;
  }

  async updateSettings(userId: string, dto: UpdateNotificationSettingsDto) {
    const data: Record<string, boolean> = {};
    if (dto.bookingAlerts !== undefined) data.bookingAlerts = dto.bookingAlerts;
    if (dto.paymentAlerts !== undefined) data.paymentAlerts = dto.paymentAlerts;
    if (dto.chatAlerts !== undefined) data.chatAlerts = dto.chatAlerts;
    if (dto.marketingAlerts !== undefined) data.marketingAlerts = dto.marketingAlerts;

    return this.prisma.notificationSetting.upsert({
      where: { userId },
      create: { userId, ...data },
      update: data,
    });
  }
}
