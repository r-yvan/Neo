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
  TransactionType,
} from '@prisma/client';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
} from '../common/dto/pagination.dto.js';
import {
  ConfirmPaymentDto,
  InitiatePaymentDto,
  MobileMoneyProvider,
  PaymentHistoryQueryDto,
  WebhookPaymentDto,
  WithdrawDto,
} from './dto/payment.dto.js';

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  async initiate(userId: string, dto: InitiatePaymentDto) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: dto.bookingId },
      include: { equipment: { select: { title: true } } },
    });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }
    if (booking.renterId !== userId) {
      throw new ForbiddenException('Only the renter can pay for this booking');
    }
    if (booking.status !== BookingStatus.ACCEPTED) {
      throw new BadRequestException(
        'Payment can only be initiated for accepted bookings',
      );
    }
    if (booking.paymentStatus === PaymentStatus.PAID) {
      throw new BadRequestException('Booking is already paid');
    }

    const paymentRef = `PAY-${randomUUID()}`;

    const transaction = await this.prisma.$transaction(async (tx) => {
      const pending = await tx.transaction.findFirst({
        where: {
          bookingId: booking.id,
          type: TransactionType.RENTAL,
          status: PaymentStatus.PENDING,
        },
      });
      if (pending) {
        return pending;
      }
      return tx.transaction.create({
        data: {
          bookingId: booking.id,
          userId,
          amount: booking.totalPrice,
          type: TransactionType.RENTAL,
          provider: dto.provider,
          providerRef: paymentRef,
          status: PaymentStatus.PENDING,
          metadata: { equipmentTitle: booking.equipment.title },
        },
      });
    });

    return {
      paymentRef: transaction.providerRef ?? paymentRef,
      transactionId: transaction.id,
      amount: Number(transaction.amount),
      provider: dto.provider,
      message: 'Mock payment initiated — use confirm or provider webhook',
    };
  }

  async confirm(userId: string, dto: ConfirmPaymentDto) {
    const transaction = await this.prisma.transaction.findFirst({
      where: {
        providerRef: dto.paymentRef,
        type: TransactionType.RENTAL,
      },
      include: { booking: true },
    });
    if (!transaction) {
      throw new NotFoundException('Payment not found');
    }
    if (transaction.userId !== userId) {
      throw new ForbiddenException('You cannot confirm this payment');
    }
    if (transaction.status === PaymentStatus.PAID) {
      return { message: 'Already confirmed', transaction };
    }

    return this.markRentalPaid(transaction.id);
  }

  private async markRentalPaid(transactionId: string) {
    const result = await this.prisma.$transaction(async (tx) => {
      const transaction = await tx.transaction.update({
        where: { id: transactionId },
        data: { status: PaymentStatus.PAID },
        include: { booking: true },
      });

      if (!transaction.bookingId || !transaction.booking) {
        throw new BadRequestException('Transaction is not linked to a booking');
      }

      await tx.booking.update({
        where: { id: transaction.bookingId },
        data: { paymentStatus: PaymentStatus.PAID },
      });

      const ownerPayout =
        Number(transaction.amount) -
        Number(transaction.booking.commissionAmount);

      await tx.transaction.create({
        data: {
          bookingId: transaction.bookingId,
          userId: transaction.booking.ownerId,
          amount: ownerPayout,
          type: TransactionType.PAYOUT,
          status: PaymentStatus.PAID,
          providerRef: `PAYOUT-${transaction.providerRef}`,
        },
      });

      await tx.transaction.create({
        data: {
          bookingId: transaction.bookingId,
          userId: transaction.booking.ownerId,
          amount: transaction.booking.commissionAmount,
          type: TransactionType.COMMISSION,
          status: PaymentStatus.PAID,
          providerRef: `COMM-${transaction.providerRef}`,
        },
      });

      await tx.notification.create({
        data: {
          userId: transaction.booking.ownerId,
          title: 'Payment received',
          body: 'Rental payment confirmed for your booking',
          type: NotificationType.PAYMENT,
          data: {
            bookingId: transaction.bookingId,
            transactionId: transaction.id,
          },
        },
      });

      return transaction;
    });

    return { message: 'Payment confirmed', transaction: result };
  }

  async history(userId: string, query: PaymentHistoryQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { userId };

    const [data, total] = await Promise.all([
      this.prisma.transaction.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          booking: {
            select: {
              id: true,
              equipmentId: true,
              status: true,
              startDate: true,
              endDate: true,
            },
          },
        },
      }),
      this.prisma.transaction.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async earnings(userId: string) {
    const aggregate = await this.prisma.transaction.aggregate({
      where: {
        userId,
        type: TransactionType.PAYOUT,
        status: PaymentStatus.PAID,
      },
      _sum: { amount: true },
    });

    return {
      totalEarnings: Number(aggregate._sum.amount ?? 0),
      currency: 'RWF',
    };
  }

  async earningsBreakdown(userId: string) {
    const payouts = await this.prisma.transaction.findMany({
      where: {
        userId,
        type: TransactionType.PAYOUT,
        status: PaymentStatus.PAID,
      },
      orderBy: { createdAt: 'desc' },
      include: {
        booking: {
          select: {
            id: true,
            startDate: true,
            endDate: true,
            equipment: { select: { id: true, title: true } },
          },
        },
      },
    });

    const byMonth = new Map<string, number>();
    for (const p of payouts) {
      const key = p.createdAt.toISOString().slice(0, 7);
      byMonth.set(key, (byMonth.get(key) ?? 0) + Number(p.amount));
    }

    return {
      totalEarnings: payouts.reduce((s, p) => s + Number(p.amount), 0),
      byMonth: Object.fromEntries(byMonth),
      payouts: payouts.map((p) => ({
        id: p.id,
        amount: Number(p.amount),
        createdAt: p.createdAt,
        booking: p.booking,
      })),
    };
  }

  async withdraw(userId: string, dto: WithdrawDto) {
    const earnings = await this.earnings(userId);
    if (dto.amount > earnings.totalEarnings) {
      throw new BadRequestException('Insufficient earnings balance');
    }

    const withdrawal = await this.prisma.$transaction(async (tx) => {
      const row = await tx.withdrawal.create({
        data: {
          userId,
          amount: dto.amount,
          phone: dto.phone,
          provider: dto.provider,
        },
      });
      await tx.transaction.create({
        data: {
          userId,
          amount: dto.amount,
          type: TransactionType.WITHDRAWAL,
          provider: dto.provider,
          providerRef: `WD-${row.id}`,
          status: PaymentStatus.PENDING,
          metadata: { withdrawalId: row.id, phone: dto.phone },
        },
      });
      return row;
    });

    return withdrawal;
  }

  listWithdrawals(userId: string, query: PaymentHistoryQueryDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { userId };

    return Promise.all([
      this.prisma.withdrawal.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.withdrawal.count({ where }),
    ]).then(([data, total]) => paginatedResponse(data, total, page, limit));
  }

  async webhookMomo(dto: WebhookPaymentDto) {
    return this.webhookByProvider(dto, MobileMoneyProvider.MOMO);
  }

  async webhookAirtel(dto: WebhookPaymentDto) {
    return this.webhookByProvider(dto, MobileMoneyProvider.AIRTEL);
  }

  private async webhookByProvider(
    dto: WebhookPaymentDto,
    provider: MobileMoneyProvider,
  ) {
    const transaction = await this.prisma.transaction.findFirst({
      where: {
        providerRef: dto.providerRef,
        type: TransactionType.RENTAL,
        provider,
      },
    });
    if (!transaction) {
      throw new NotFoundException('Transaction not found for provider reference');
    }
    if (transaction.status === PaymentStatus.PAID) {
      return { message: 'Already processed', transactionId: transaction.id };
    }

    const result = await this.markRentalPaid(transaction.id);
    return { ...result, webhookStatus: 'processed' };
  }
}
