import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BookingStatus, NotificationType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
} from '../common/dto/pagination.dto.js';
import {
  CreateReviewDto,
  ReviewListQueryDto,
  UpdateReviewDto,
} from './dto/review.dto.js';

const reviewInclude = {
  fromUser: {
    select: { id: true, fullName: true, profileImage: true },
  },
  toUser: {
    select: { id: true, fullName: true, profileImage: true },
  },
  equipment: {
    select: { id: true, title: true, images: true },
  },
  booking: {
    select: { id: true, startDate: true, endDate: true },
  },
};

@Injectable()
export class ReviewsService {
  constructor(private prisma: PrismaService) {}

  private async syncUserRating(userId: string) {
    const agg = await this.prisma.review.aggregate({
      where: { toUserId: userId },
      _avg: { rating: true },
      _count: { rating: true },
    });
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        averageRating: agg._avg.rating ?? 0,
        totalReviews: agg._count.rating,
      },
    });
  }

  private async syncEquipmentRating(equipmentId: string) {
    const agg = await this.prisma.review.aggregate({
      where: { equipmentId },
      _avg: { rating: true },
      _count: { rating: true },
    });
    await this.prisma.equipment.update({
      where: { id: equipmentId },
      data: {
        averageRating: agg._avg.rating ?? 0,
        totalReviews: agg._count.rating,
      },
    });
  }

  async create(userId: string, dto: CreateReviewDto) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: dto.bookingId },
    });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }
    if (booking.renterId !== userId) {
      throw new ForbiddenException('Only the renter can review this booking');
    }
    if (booking.status !== BookingStatus.COMPLETED) {
      throw new BadRequestException(
        'Reviews are allowed only after the booking is completed',
      );
    }

    const existing = await this.prisma.review.findUnique({
      where: { bookingId: dto.bookingId },
    });
    if (existing) {
      throw new BadRequestException('This booking already has a review');
    }

    const review = await this.prisma.$transaction(async (tx) => {
      const created = await tx.review.create({
        data: {
          bookingId: booking.id,
          fromUserId: userId,
          toUserId: booking.ownerId,
          equipmentId: booking.equipmentId,
          rating: dto.rating,
          comment: dto.comment,
        },
        include: reviewInclude,
      });

      await tx.notification.create({
        data: {
          userId: booking.ownerId,
          title: 'New review',
          body: `You received a ${dto.rating}-star review`,
          type: NotificationType.REVIEW,
          data: { reviewId: created.id, bookingId: booking.id },
        },
      });

      return created;
    });

    await this.syncUserRating(booking.ownerId);
    await this.syncEquipmentRating(booking.equipmentId);

    return review;
  }

  async findMy(userId: string, query: ReviewListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { fromUserId: userId };

    const [data, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: reviewInclude,
      }),
      this.prisma.review.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async findByEquipment(equipmentId: string, query: ReviewListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { equipmentId };

    const [data, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: reviewInclude,
      }),
      this.prisma.review.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async findByUser(targetUserId: string, query: ReviewListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { toUserId: targetUserId };

    const [data, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: reviewInclude,
      }),
      this.prisma.review.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  private async getOwnedReview(id: string, userId: string) {
    const review = await this.prisma.review.findUnique({
      where: { id },
      include: reviewInclude,
    });
    if (!review) {
      throw new NotFoundException('Review not found');
    }
    if (review.fromUserId !== userId) {
      throw new ForbiddenException('You can only modify your own reviews');
    }
    return review;
  }

  async update(userId: string, id: string, dto: UpdateReviewDto) {
    const review = await this.getOwnedReview(id, userId);
    if (dto.rating === undefined && dto.comment === undefined) {
      throw new BadRequestException('Provide rating or comment to update');
    }

    const updated = await this.prisma.review.update({
      where: { id },
      data: {
        ...(dto.rating !== undefined ? { rating: dto.rating } : {}),
        ...(dto.comment !== undefined ? { comment: dto.comment } : {}),
      },
      include: reviewInclude,
    });

    await this.syncUserRating(review.toUserId);
    if (review.equipmentId) {
      await this.syncEquipmentRating(review.equipmentId);
    }

    return updated;
  }

  async remove(userId: string, id: string) {
    const review = await this.getOwnedReview(id, userId);

    await this.prisma.review.delete({ where: { id } });

    await this.syncUserRating(review.toUserId);
    if (review.equipmentId) {
      await this.syncEquipmentRating(review.equipmentId);
    }

    return { message: 'Review deleted' };
  }
}
