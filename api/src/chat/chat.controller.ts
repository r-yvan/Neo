import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ChatService } from './chat.service.js';
import { SendMessageDto } from './dto/chat.dto.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { PaginationDto } from '../common/dto/pagination.dto.js';

@ApiTags('Chat')
@ApiBearerAuth()
@Controller('chat')
export class ChatController {
  constructor(private chatService: ChatService) {}

  @Get('conversations')
  @ApiOperation({ summary: 'List all conversations with last message' })
  listConversations(@CurrentUser('id') userId: string) {
    return this.chatService.listConversations(userId);
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Get total unread message count' })
  unreadCount(@CurrentUser('id') userId: string) {
    return this.chatService.unreadCount(userId);
  }

  @Get('conversations/:userId')
  @ApiOperation({ summary: 'Get messages with a specific user' })
  getMessages(
    @CurrentUser('id') currentUserId: string,
    @Param('userId', ParseUUIDPipe) otherUserId: string,
    @Query() query: PaginationDto,
  ) {
    return this.chatService.getMessages(currentUserId, otherUserId, query);
  }

  @Post('send')
  @ApiOperation({ summary: 'Send a message' })
  send(@CurrentUser('id') senderId: string, @Body() dto: SendMessageDto) {
    return this.chatService.send(senderId, dto);
  }

  @Patch('messages/:id/read')
  @ApiOperation({ summary: 'Mark a single message as read' })
  markRead(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.chatService.markRead(userId, id);
  }

  @Patch('conversations/:userId/read')
  @ApiOperation({ summary: 'Mark entire conversation as read' })
  markConversationRead(
    @CurrentUser('id') currentUserId: string,
    @Param('userId', ParseUUIDPipe) otherUserId: string,
  ) {
    return this.chatService.markConversationRead(currentUserId, otherUserId);
  }

  @Delete('messages/:id')
  @ApiOperation({ summary: 'Soft-delete a sent message' })
  deleteMessage(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.chatService.deleteMessage(userId, id);
  }
}
