import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service.js';
import {
  NotificationListQueryDto,
  UpdateNotificationSettingsDto,
} from './dto/notification.dto.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';

@ApiTags('Notifications')
@ApiBearerAuth()
@Controller('notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all notifications' })
  findAll(
    @CurrentUser('id') userId: string,
    @Query() query: NotificationListQueryDto,
  ) {
    return this.notificationsService.findAll(userId, query);
  }

  @Get('unread')
  @ApiOperation({ summary: 'Get unread notifications only' })
  findUnread(
    @CurrentUser('id') userId: string,
    @Query() query: NotificationListQueryDto,
  ) {
    return this.notificationsService.findUnread(userId, query);
  }

  @Get('settings')
  @ApiOperation({ summary: 'Get notification preferences' })
  getSettings(@CurrentUser('id') userId: string) {
    return this.notificationsService.getSettings(userId);
  }

  @Patch('settings')
  @ApiOperation({ summary: 'Update notification preferences' })
  updateSettings(
    @CurrentUser('id') userId: string,
    @Body() dto: UpdateNotificationSettingsDto,
  ) {
    return this.notificationsService.updateSettings(userId, dto);
  }

  @Patch('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  markAllRead(@CurrentUser('id') userId: string) {
    return this.notificationsService.markAllRead(userId);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark a notification as read' })
  markRead(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.markRead(userId, id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a notification' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.remove(userId, id);
  }
}
