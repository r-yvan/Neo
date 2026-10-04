import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  BookingStatus,
  NotificationType,
  PaymentStatus,
  Prisma,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
} from '../common/dto/pagination.dto.js';
import {
  BookingListQueryDto,
  CreateBookingDto,
  ExtendBookingDto,
} from './dto/booking.dto.js';

const DEFAULT_COMMISSION_RATE = 0.1;

const bookingInclude = {
  equipment: {
    select: {
      id: true,
      title: true,
      category: true,
      images: true,
      location: true,
      pricePerDay: true,
    },
  },
  renter: {
    select: { id: true, fullName: true, phone: true, profileImage: true },
  },
  owner: {
    select: { id: true, fullName: true, phone: true, profileImage: true },
  },
} satisfies Prisma.BookingInclude;

@Injectable()
export class BookingsService {
  constructor(private prisma: PrismaService) {}

  private commissionRate(): number {
    const env = process.env.COMMISSION_RATE;
    const rate = env ? Number(env) : DEFAULT_COMMISSION_RATE;
    return Number.isFinite(rate) ? rate : DEFAULT_COMMISSION_RATE;
  }

  private parseDate(value: string, field: string): Date {
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) {
      throw new BadRequestException(`Invalid ${field}`);
    }
    return d;
  }

  private rentalDays(start: Date, end: Date): number {
    const startUtc = Date.UTC(
      start.getUTCFullYear(),
      start.getUTCMonth(),
      start.getUTCDate(),
    );
    const endUtc = Date.UTC(
      end.getUTCFullYear(),
      end.getUTCMonth(),
      end.getUTCDate(),
    );
    const diff = Math.floor((endUtc - startUtc) / (1000 * 60 * 60 * 24));
    return Math.max(1, diff + 1);
  }

  private calcPricing(
    pricePerDay: Prisma.Decimal,
    start: Date,
    end: Date,
    quantity: number,
  ) {
    const days = this.rentalDays(start, end);
    const unit = Number(pricePerDay);
    const totalPrice = days * unit * quantity;
    const commissionAmount = totalPrice * this.commissionRate();
    return { days, totalPrice, commissionAmount };
  }

  private async assertQuantityAvailable(
    equipmentId: string,
    equipmentQty: number,
    start: Date,
    end: Date,
    requestedQty: number,
    excludeBookingId?: string,
  ) {
    const overlapping = await this.prisma.booking.findMany({
      where: {
        equipmentId,
        id: excludeBookingId ? { not: excludeBookingId } : undefined,
        status: { in: [BookingStatus.ACCEPTED, BookingStatus.ONGOING] },
        startDate: { lte: end },
        endDate: { gte: start },
      },
      select: { quantity: true },
    });
    const booked = overlapping.reduce((sum, b) => sum + b.quantity, 0);
    if (booked + requestedQty > equipmentQty) {
      throw new BadRequestException(
        'Not enough equipment quantity available for these dates',
      );
    }
  }

  private async notifyStatusChange(
    booking: { id: string; renterId: string; ownerId: string },
    status: BookingStatus,
    actorId: string,
  ) {
    const title = `Booking ${status.toLowerCase()}`;
    const body = `Booking status changed to ${status}`;
    const data = { bookingId: booking.id, status };
    const recipients = new Set<string>([booking.renterId, booking.ownerId]);
    recipients.delete(actorId);

    await Promise.all(
      [...recipients].map((userId) =>
        this.prisma.notification.create({
          data: {
            userId,
            title,
            body,
            type: NotificationType.BOOKING,
            data,
          },
        }),
      ),
    );
  }

  private async addTimeline(
    bookingId: string,
    status: BookingStatus,
    actorId: string,
    note?: string,
  ) {
    await this.prisma.bookingTimeline.create({
      data: { bookingId, status, actorId, note },
    });
  }

  private async getBookingForUser(id: string, userId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id },
      include: bookingInclude,
    });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }
    if (booking.renterId !== userId && booking.ownerId !== userId) {
      throw new ForbiddenException('You do not have access to this booking');
    }
    return booking;
  }

  async create(userId: string, dto: CreateBookingDto) {
    const start = this.parseDate(dto.startDate, 'startDate');
    const end = this.parseDate(dto.endDate, 'endDate');
    if (end < start) {
      throw new BadRequestException('endDate must be on or after startDate');
    }

    const equipment = await this.prisma.equipment.findFirst({
      where: { id: dto.equipmentId, deletedAt: null, isAvailable: true },
    });
    if (!equipment) {
      throw new NotFoundException('Equipment not found or unavailable');
    }
    if (equipment.ownerId === userId) {
      throw new BadRequestException('You cannot book your own equipment');
    }
    if (dto.quantity > equipment.quantity) {
      throw new BadRequestException('Requested quantity exceeds stock');
    }

    await this.assertQuantityAvailable(
      equipment.id,
      equipment.quantity,
      start,
      end,
      dto.quantity,
    );

    const { totalPrice, commissionAmount } = this.calcPricing(
      equipment.pricePerDay,
      start,
      end,
      dto.quantity,
    );
    const depositAmount = equipment.depositAmount
      ? Number(equipment.depositAmount)
      : 0;

    const booking = await this.prisma.$transaction(async (tx) => {
      const created = await tx.booking.create({
        data: {
          equipmentId: equipment.id,
          renterId: userId,
          ownerId: equipment.ownerId,
          startDate: start,
          endDate: end,
          quantity: dto.quantity,
          totalPrice,
          commissionAmount,
          depositAmount,
          status: BookingStatus.PENDING,
          paymentStatus: PaymentStatus.PENDING,
          notes: dto.notes,
        },
        include: bookingInclude,
      });
      await tx.bookingTimeline.create({
        data: {
          bookingId: created.id,
          status: BookingStatus.PENDING,
          actorId: userId,
          note: 'Booking created',
        },
      });
      await tx.notification.create({
        data: {
          userId: equipment.ownerId,
          title: 'New booking request',
          body: 'You have a new equipment rental request',
          type: NotificationType.BOOKING,
          data: { bookingId: created.id, status: BookingStatus.PENDING },
        },
      });
      return created;
    });

    return booking;
  }

  async findMy(userId: string, query: BookingListQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where: Prisma.BookingWhereInput = {
      ...(query.status ? { status: query.status } : {}),
    };

    if (query.role === 'renter') {
      where.renterId = userId;
    } else if (query.role === 'owner') {
      where.ownerId = userId;
    } else {
      where.OR = [{ renterId: userId }, { ownerId: userId }];
    }

    const [data, total] = await Promise.all([
      this.prisma.booking.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: bookingInclude,
      }),
      this.prisma.booking.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  findMyAsRenter(userId: string, query: BookingListQueryDto) {
    return this.findMy(userId, { ...query, role: 'renter' });
  }

  findMyAsOwner(userId: string, query: BookingListQueryDto) {
    return this.findMy(userId, { ...query, role: 'owner' });
  }

  findOne(userId: string, id: string) {
    return this.getBookingForUser(id, userId);
  }

  async transitionStatus(
    id: string,
    userId: string,
    next: BookingStatus,
    opts: {
      allowedAs: 'owner' | 'renter' | 'either';
      from: BookingStatus[];
      note?: string;
    },
  ) {
    const booking = await this.prisma.booking.findUnique({ where: { id } });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (opts.allowedAs === 'owner' && booking.ownerId !== userId) {
      throw new ForbiddenException('Only the equipment owner can perform this action');
    }
    if (opts.allowedAs === 'renter' && booking.renterId !== userId) {
      throw new ForbiddenException('Only the renter can perform this action');
    }
    if (
      opts.allowedAs === 'either' &&
      booking.ownerId !== userId &&
      booking.renterId !== userId
    ) {
      throw new ForbiddenException('You do not have access to this booking');
    }
    if (!opts.from.includes(booking.status)) {
      throw new BadRequestException(
        `Cannot change status from ${booking.status} to ${next}`,
      );
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      const row = await tx.booking.update({
        where: { id },
        data: { status: next },
        include: bookingInclude,
      });
      await tx.bookingTimeline.create({
        data: {
          bookingId: id,
          status: next,
          actorId: userId,
          note: opts.note,
        },
      });
      await this.notifyStatusChange(booking, next, userId);
      return row;
    });

    return updated;
  }

  accept(userId: string, id: string) {
    return this.transitionStatus(id, userId, BookingStatus.ACCEPTED, {
      allowedAs: 'owner',
      from: [BookingStatus.PENDING],
      note: 'Booking accepted',
    });
  }

  reject(userId: string, id: string) {
    return this.transitionStatus(id, userId, BookingStatus.REJECTED, {
      allowedAs: 'owner',
      from: [BookingStatus.PENDING],
      note: 'Booking rejected',
    });
  }

  cancel(userId: string, id: string) {
    return this.transitionStatus(id, userId, BookingStatus.CANCELLED, {
      allowedAs: 'either',
      from: [
        BookingStatus.PENDING,
        BookingStatus.ACCEPTED,
        BookingStatus.ONGOING,
      ],
      note: 'Booking cancelled',
    });
  }

  start(userId: string, id: string) {
    return this.transitionStatus(id, userId, BookingStatus.ONGOING, {
      allowedAs: 'owner',
      from: [BookingStatus.ACCEPTED],
      note: 'Rental started',
    });
  }

  complete(userId: string, id: string) {
    return this.transitionStatus(id, userId, BookingStatus.COMPLETED, {
      allowedAs: 'either',
      from: [BookingStatus.ONGOING],
      note: 'Rental completed',
    });
  }

  dispute(userId: string, id: string) {
    return this.transitionStatus(id, userId, BookingStatus.DISPUTED, {
      allowedAs: 'either',
      from: [
        BookingStatus.PENDING,
        BookingStatus.ACCEPTED,
        BookingStatus.ONGOING,
        BookingStatus.COMPLETED,
      ],
      note: 'Dispute opened',
    });
  }

  async extend(userId: string, id: string, dto: ExtendBookingDto) {
    const booking = await this.getBookingForUser(id, userId);
    if (booking.renterId !== userId && booking.ownerId !== userId) {
      throw new ForbiddenException('You cannot extend this booking');
    }
    if (
      ![BookingStatus.ACCEPTED, BookingStatus.ONGOING].includes(booking.status)
    ) {
      throw new BadRequestException(
        'Only accepted or ongoing bookings can be extended',
      );
    }

    const newEnd = this.parseDate(dto.newEndDate, 'newEndDate');
    if (newEnd <= booking.endDate) {
      throw new BadRequestException('newEndDate must be after current endDate');
    }

    const equipment = await this.prisma.equipment.findUniqueOrThrow({
      where: { id: booking.equipmentId },
    });

    await this.assertQuantityAvailable(
      booking.equipmentId,
      equipment.quantity,
      booking.startDate,
      newEnd,
      booking.quantity,
      booking.id,
    );

    let totalPrice = Number(booking.totalPrice);
    let commissionAmount = Number(booking.commissionAmount);
    if (newEnd > booking.endDate) {
      const pricing = this.calcPricing(
        equipment.pricePerDay,
        booking.startDate,
        newEnd,
        booking.quantity,
      );
      totalPrice = pricing.totalPrice;
      commissionAmount = pricing.commissionAmount;
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      const row = await tx.booking.update({
        where: { id },
        data: { endDate: newEnd, totalPrice, commissionAmount },
        include: bookingInclude,
      });
      await tx.bookingTimeline.create({
        data: {
          bookingId: id,
          status: booking.status,
          actorId: userId,
          note: `Extended until ${dto.newEndDate}`,
        },
      });
      return row;
    });

    return updated;
  }

  async timeline(userId: string, id: string) {
    await this.getBookingForUser(id, userId);
    return this.prisma.bookingTimeline.findMany({
      where: { bookingId: id },
      orderBy: { createdAt: 'asc' },
      include: {
        actor: {
          select: { id: true, fullName: true, profileImage: true },
        },
      },
    });
  }
}
