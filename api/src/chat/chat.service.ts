import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { SendMessageDto } from './dto/chat.dto.js';
import {
  paginate,
  paginatedResponse,
  PaginationDto,
} from '../common/dto/pagination.dto.js';

const USER_PREVIEW = {
  id: true,
  fullName: true,
  profileImage: true,
} as const;

@Injectable()
export class ChatService {
  constructor(private prisma: PrismaService) {}

  async listConversations(userId: string) {
    const unreadBySender = await this.prisma.message.groupBy({
      by: ['senderId'],
      where: {
        receiverId: userId,
        isRead: false,
        deletedAt: null,
      },
      _count: { _all: true },
    });
    const unreadMap = new Map(
      unreadBySender.map((row) => [row.senderId, row._count._all]),
    );

    const recent = await this.prisma.message.findMany({
      where: {
        deletedAt: null,
        OR: [{ senderId: userId }, { receiverId: userId }],
      },
      orderBy: { createdAt: 'desc' },
      include: {
        sender: { select: USER_PREVIEW },
        receiver: { select: USER_PREVIEW },
      },
    });

    const seen = new Set<string>();
    const conversations: Array<{
      user: (typeof recent)[0]['sender'];
      lastMessage: {
        id: string;
        content: string;
        createdAt: Date;
        senderId: string;
        isRead: boolean;
        bookingId: string | null;
      };
      unreadCount: number;
    }> = [];

    for (const msg of recent) {
      const otherId =
        msg.senderId === userId ? msg.receiverId : msg.senderId;
      if (seen.has(otherId)) continue;
      seen.add(otherId);
      const otherUser =
        msg.senderId === userId ? msg.receiver : msg.sender;
      conversations.push({
        user: otherUser,
        lastMessage: {
          id: msg.id,
          content: msg.content,
          createdAt: msg.createdAt,
          senderId: msg.senderId,
          isRead: msg.isRead,
          bookingId: msg.bookingId,
        },
        unreadCount: unreadMap.get(otherId) ?? 0,
      });
    }

    return conversations;
  }

  async getMessages(
    userId: string,
    otherUserId: string,
    query: PaginationDto,
  ) {
    await this.ensureParticipant(otherUserId);

    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = {
      deletedAt: null,
      OR: [
        { senderId: userId, receiverId: otherUserId },
        { senderId: otherUserId, receiverId: userId },
      ],
    };

    const [data, total] = await Promise.all([
      this.prisma.message.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          sender: { select: USER_PREVIEW },
          receiver: { select: USER_PREVIEW },
        },
      }),
      this.prisma.message.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async send(senderId: string, dto: SendMessageDto) {
    const receiver = await this.prisma.user.findFirst({
      where: {
        id: dto.receiverId,
        deletedAt: null,
        isBanned: false,
      },
    });
    if (!receiver) {
      throw new NotFoundException('Receiver not found');
    }
    if (receiver.id === senderId) {
      throw new ForbiddenException('Cannot message yourself');
    }

    if (dto.bookingId) {
      const booking = await this.prisma.booking.findFirst({
        where: {
          id: dto.bookingId,
          OR: [{ renterId: senderId }, { ownerId: senderId }],
        },
      });
      if (!booking) {
        throw new NotFoundException('Booking not found');
      }
    }

    return this.prisma.message.create({
      data: {
        senderId,
        receiverId: dto.receiverId,
        content: dto.content,
        bookingId: dto.bookingId,
      },
      include: {
        sender: { select: USER_PREVIEW },
        receiver: { select: USER_PREVIEW },
      },
    });
  }

  async markRead(userId: string, messageId: string) {
    const message = await this.prisma.message.findFirst({
      where: { id: messageId, deletedAt: null },
    });
    if (!message) {
      throw new NotFoundException('Message not found');
    }
    if (message.receiverId !== userId) {
      throw new ForbiddenException('Only the receiver can mark as read');
    }

    return this.prisma.message.update({
      where: { id: messageId },
      data: { isRead: true },
    });
  }

  async markConversationRead(userId: string, otherUserId: string) {
    await this.ensureParticipant(otherUserId);

    const result = await this.prisma.message.updateMany({
      where: {
        senderId: otherUserId,
        receiverId: userId,
        isRead: false,
        deletedAt: null,
      },
      data: { isRead: true },
    });

    return { updated: result.count };
  }

  async deleteMessage(userId: string, messageId: string) {
    const message = await this.prisma.message.findFirst({
      where: { id: messageId, deletedAt: null },
    });
    if (!message) {
      throw new NotFoundException('Message not found');
    }
    if (message.senderId !== userId) {
      throw new ForbiddenException('Only the sender can delete this message');
    }

    return this.prisma.message.update({
      where: { id: messageId },
      data: { deletedAt: new Date() },
    });
  }

  async unreadCount(userId: string) {
    const count = await this.prisma.message.count({
      where: {
        receiverId: userId,
        isRead: false,
        deletedAt: null,
      },
    });
    return { count };
  }

  private async ensureParticipant(userId: string) {
    const user = await this.prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: { id: true },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
  }
}
