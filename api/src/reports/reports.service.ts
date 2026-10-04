import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BookingStatus, DisputeStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
} from '../common/dto/pagination.dto.js';
import {
  CreateDisputeDto,
  CreateReportDto,
  ReportListQueryDto,
  RespondDisputeDto,
} from './dto/report.dto.js';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  async createReport(userId: string, dto: CreateReportDto) {
    return this.prisma.report.create({
      data: {
        reporterId: userId,
        targetType: dto.targetType,
        targetId: dto.targetId,
        reason: dto.reason,
        details: dto.details,
      },
    });
  }

  async myReports(userId: string, query: ReportListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { reporterId: userId };

    const [data, total] = await Promise.all([
      this.prisma.report.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.report.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async createDispute(userId: string, dto: CreateDisputeDto) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: dto.bookingId },
    });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }
    if (booking.renterId !== userId && booking.ownerId !== userId) {
      throw new ForbiddenException('You are not part of this booking');
    }
    if (
      !(
        [
          BookingStatus.PENDING,
          BookingStatus.ACCEPTED,
          BookingStatus.ONGOING,
          BookingStatus.COMPLETED,
        ] as BookingStatus[]
      ).includes(booking.status)
    ) {
      throw new BadRequestException('Cannot open dispute on this booking');
    }

    const existing = await this.prisma.dispute.findUnique({
      where: { bookingId: dto.bookingId },
    });
    if (existing) {
      throw new BadRequestException('A dispute already exists for this booking');
    }

    const [dispute] = await this.prisma.$transaction([
      this.prisma.dispute.create({
        data: {
          bookingId: dto.bookingId,
          openedById: userId,
          reason: dto.reason,
        },
      }),
      this.prisma.booking.update({
        where: { id: dto.bookingId },
        data: { status: BookingStatus.DISPUTED },
      }),
    ]);

    return dispute;
  }

  async getDispute(userId: string, id: string) {
    const dispute = await this.prisma.dispute.findUnique({
      where: { id },
      include: {
        booking: {
          select: {
            id: true,
            renterId: true,
            ownerId: true,
            status: true,
            equipment: { select: { id: true, title: true } },
          },
        },
        openedBy: { select: { id: true, fullName: true } },
      },
    });
    if (!dispute) {
      throw new NotFoundException('Dispute not found');
    }
    if (
      dispute.booking.renterId !== userId &&
      dispute.booking.ownerId !== userId &&
      dispute.openedById !== userId
    ) {
      throw new ForbiddenException('No access to this dispute');
    }
    return dispute;
  }

  async respondDispute(userId: string, id: string, dto: RespondDisputeDto) {
    const dispute = await this.prisma.dispute.findUnique({
      where: { id },
      include: { booking: { select: { renterId: true, ownerId: true } } },
    });
    if (!dispute) {
      throw new NotFoundException('Dispute not found');
    }
    if (
      dispute.booking.renterId !== userId &&
      dispute.booking.ownerId !== userId
    ) {
      throw new ForbiddenException('No access to this dispute');
    }
    if (dispute.status !== DisputeStatus.OPEN) {
      throw new BadRequestException('Dispute is no longer open');
    }

    return this.prisma.dispute.update({
      where: { id },
      data: {
        response: dto.response,
        status: DisputeStatus.IN_REVIEW,
      },
    });
  }
}
