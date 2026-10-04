import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  BookingStatus,
  DisputeStatus,
  PaymentStatus,
  ReportStatus,
  TransactionType,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
} from '../common/dto/pagination.dto.js';
import {
  AdminBookingListQueryDto,
  AdminDisputeListQueryDto,
  AdminEquipmentListQueryDto,
  AdminReportListQueryDto,
  AdminReviewListQueryDto,
  AdminTransactionListQueryDto,
  AdminUserListQueryDto,
  ResolveDisputeDto,
  ResolveReportDto,
} from './dto/admin.dto.js';

const USER_SELECT = {
  id: true,
  phone: true,
  fullName: true,
  email: true,
  nationalId: true,
  roles: true,
  isVerified: true,
  isBanned: true,
  profileImage: true,
  averageRating: true,
  totalReviews: true,
  deletedAt: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async dashboard() {
    const [
      totalUsers,
      totalEquipment,
      totalBookings,
      pendingBookings,
      completedBookings,
      totalRevenue,
      openReports,
      openDisputes,
    ] = await Promise.all([
      this.prisma.user.count({ where: { deletedAt: null } }),
      this.prisma.equipment.count({ where: { deletedAt: null } }),
      this.prisma.booking.count(),
      this.prisma.booking.count({ where: { status: BookingStatus.PENDING } }),
      this.prisma.booking.count({ where: { status: BookingStatus.COMPLETED } }),
      this.prisma.transaction.aggregate({
        where: { type: TransactionType.COMMISSION, status: PaymentStatus.PAID },
        _sum: { amount: true },
      }),
      this.prisma.report.count({ where: { status: ReportStatus.OPEN } }),
      this.prisma.dispute.count({ where: { status: DisputeStatus.OPEN } }),
    ]);

    return {
      totalUsers,
      totalEquipment,
      totalBookings,
      pendingBookings,
      completedBookings,
      totalRevenue: Number(totalRevenue._sum.amount ?? 0),
      openReports,
      openDisputes,
    };
  }

  async analytics() {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60_000);

    const [newUsers, newBookings, revenueLastMonth] = await Promise.all([
      this.prisma.user.count({
        where: { createdAt: { gte: thirtyDaysAgo }, deletedAt: null },
      }),
      this.prisma.booking.count({
        where: { createdAt: { gte: thirtyDaysAgo } },
      }),
      this.prisma.transaction.aggregate({
        where: {
          type: TransactionType.COMMISSION,
          status: PaymentStatus.PAID,
          createdAt: { gte: thirtyDaysAgo },
        },
        _sum: { amount: true },
      }),
    ]);

    const topEquipment = await this.prisma.equipment.findMany({
      where: { deletedAt: null },
      orderBy: { totalReviews: 'desc' },
      take: 10,
      select: {
        id: true,
        title: true,
        category: true,
        totalReviews: true,
        averageRating: true,
      },
    });

    return {
      period: '30d',
      newUsers,
      newBookings,
      revenueLastMonth: Number(revenueLastMonth._sum.amount ?? 0),
      topEquipment,
    };
  }

  async listUsers(query: AdminUserListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = {
      ...(query.search
        ? {
            OR: [
              { fullName: { contains: query.search, mode: 'insensitive' as const } },
              { phone: { contains: query.search, mode: 'insensitive' as const } },
              { email: { contains: query.search, mode: 'insensitive' as const } },
            ],
          }
        : {}),
    };

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        select: USER_SELECT,
      }),
      this.prisma.user.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async getUser(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        ...USER_SELECT,
        _count: {
          select: {
            equipment: true,
            bookingsAsRenter: true,
            bookingsAsOwner: true,
            reviewsGiven: true,
            reviewsReceived: true,
          },
        },
      },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async verifyUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    if (!user.nationalId) {
      throw new BadRequestException('User has not submitted a National ID');
    }

    return this.prisma.user.update({
      where: { id },
      data: { isVerified: true },
      select: USER_SELECT,
    });
  }

  async banUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.prisma.user.update({
      where: { id },
      data: { isBanned: true },
      select: USER_SELECT,
    });
  }

  async unbanUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.prisma.user.update({
      where: { id },
      data: { isBanned: false },
      select: USER_SELECT,
    });
  }

  async listEquipment(query: AdminEquipmentListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = {
      ...(query.search
        ? {
            OR: [
              { title: { contains: query.search, mode: 'insensitive' as const } },
              { location: { contains: query.search, mode: 'insensitive' as const } },
            ],
          }
        : {}),
    };

    const [data, total] = await Promise.all([
      this.prisma.equipment.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          owner: { select: { id: true, fullName: true, phone: true } },
        },
      }),
      this.prisma.equipment.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async approveEquipment(id: string) {
    const eq = await this.prisma.equipment.findUnique({ where: { id } });
    if (!eq) {
      throw new NotFoundException('Equipment not found');
    }
    return this.prisma.equipment.update({
      where: { id },
      data: { isApproved: true },
    });
  }

  async rejectEquipment(id: string) {
    const eq = await this.prisma.equipment.findUnique({ where: { id } });
    if (!eq) {
      throw new NotFoundException('Equipment not found');
    }
    return this.prisma.equipment.update({
      where: { id },
      data: { isApproved: false },
    });
  }

  async listBookings(query: AdminBookingListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.prisma.booking.findMany({
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          equipment: { select: { id: true, title: true } },
          renter: { select: { id: true, fullName: true, phone: true } },
          owner: { select: { id: true, fullName: true, phone: true } },
        },
      }),
      this.prisma.booking.count(),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async listTransactions(query: AdminTransactionListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.prisma.transaction.findMany({
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, fullName: true, phone: true } },
          booking: { select: { id: true, status: true } },
        },
      }),
      this.prisma.transaction.count(),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async listReviews(query: AdminReviewListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.prisma.review.findMany({
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          fromUser: { select: { id: true, fullName: true } },
          toUser: { select: { id: true, fullName: true } },
          equipment: { select: { id: true, title: true } },
        },
      }),
      this.prisma.review.count(),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async deleteReview(id: string) {
    const review = await this.prisma.review.findUnique({ where: { id } });
    if (!review) {
      throw new NotFoundException('Review not found');
    }

    await this.prisma.review.delete({ where: { id } });

    // Resync ratings
    if (review.toUserId) {
      const userAgg = await this.prisma.review.aggregate({
        where: { toUserId: review.toUserId },
        _avg: { rating: true },
        _count: { rating: true },
      });
      await this.prisma.user.update({
        where: { id: review.toUserId },
        data: {
          averageRating: userAgg._avg.rating ?? 0,
          totalReviews: userAgg._count.rating,
        },
      });
    }
    if (review.equipmentId) {
      const eqAgg = await this.prisma.review.aggregate({
        where: { equipmentId: review.equipmentId },
        _avg: { rating: true },
        _count: { rating: true },
      });
      await this.prisma.equipment.update({
        where: { id: review.equipmentId },
        data: {
          averageRating: eqAgg._avg.rating ?? 0,
          totalReviews: eqAgg._count.rating,
        },
      });
    }

    return { message: 'Review deleted' };
  }

  async listReports(query: AdminReportListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.prisma.report.findMany({
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          reporter: { select: { id: true, fullName: true, phone: true } },
        },
      }),
      this.prisma.report.count(),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async resolveReport(id: string, dto: ResolveReportDto) {
    const report = await this.prisma.report.findUnique({ where: { id } });
    if (!report) {
      throw new NotFoundException('Report not found');
    }
    if (report.status !== ReportStatus.OPEN) {
      throw new BadRequestException('Report is already resolved');
    }

    return this.prisma.report.update({
      where: { id },
      data: {
        status: dto.status,
        resolvedAt: new Date(),
      },
    });
  }

  async listDisputes(query: AdminDisputeListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.prisma.dispute.findMany({
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          booking: {
            select: {
              id: true,
              status: true,
              renter: { select: { id: true, fullName: true } },
              owner: { select: { id: true, fullName: true } },
            },
          },
          openedBy: { select: { id: true, fullName: true } },
        },
      }),
      this.prisma.dispute.count(),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async resolveDispute(id: string, dto: ResolveDisputeDto) {
    const dispute = await this.prisma.dispute.findUnique({ where: { id } });
    if (!dispute) {
      throw new NotFoundException('Dispute not found');
    }
    if (
      dispute.status === DisputeStatus.RESOLVED ||
      dispute.status === DisputeStatus.CLOSED
    ) {
      throw new BadRequestException('Dispute is already resolved');
    }

    return this.prisma.dispute.update({
      where: { id },
      data: {
        status: dto.status,
        resolution: dto.resolution,
      },
    });
  }
}
