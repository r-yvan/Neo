import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  EquipmentCategory,
  PaymentStatus,
  Prisma,
  TransactionType,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  BlockDatesDto,
  BoostEquipmentDto,
  CreateEquipmentDto,
  EquipmentFilterDto,
  SetAvailabilityDto,
  UpdateEquipmentDto,
} from './dto/equipment.dto.js';
import {
  paginate,
  paginatedResponse,
  PaginationDto,
} from '../common/dto/pagination.dto.js';

function parseDateOnly(value: string): Date {
  const [y, m, d] = value.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

function haversineKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function isActivelyBoosted(
  item: { isBoosted: boolean; boostedUntil: Date | null },
  now = new Date(),
): boolean {
  return Boolean(item.isBoosted && item.boostedUntil && item.boostedUntil > now);
}

@Injectable()
export class EquipmentService {
  constructor(
    private prisma: PrismaService,
    private config: ConfigService,
  ) {}

  async create(userId: string, isVerified: boolean, roles: UserRole[], dto: CreateEquipmentDto) {
    if (!isVerified) {
      throw new ForbiddenException('Verify your account before listing equipment');
    }

    const freeLimit = Number(this.config.get('FREE_LISTING_LIMIT') ?? 5);
    if (!roles.includes(UserRole.OWNER)) {
      const listingCount = await this.prisma.equipment.count({
        where: { ownerId: userId, deletedAt: null },
      });
      if (listingCount >= freeLimit) {
        throw new BadRequestException(
          `Free listing limit (${freeLimit}) reached. Add OWNER role to list more.`,
        );
      }
    }

    return this.prisma.equipment.create({
      data: {
        ownerId: userId,
        title: dto.title,
        description: dto.description,
        category: dto.category,
        quantity: dto.quantity,
        pricePerDay: dto.pricePerDay,
        depositAmount: dto.depositAmount,
        location: dto.location,
        latitude: dto.latitude,
        longitude: dto.longitude,
        images: dto.images ?? [],
      },
      include: { owner: { select: { id: true, fullName: true, profileImage: true } } },
    });
  }

  async findAll(query: EquipmentFilterDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const now = new Date();

    const where: Prisma.EquipmentWhereInput = {
      deletedAt: null,
      isApproved: true,
      ...(query.category && { category: query.category }),
      ...(query.location && {
        location: { contains: query.location, mode: 'insensitive' },
      }),
      ...(query.minPrice !== undefined || query.maxPrice !== undefined
        ? {
            pricePerDay: {
              ...(query.minPrice !== undefined && { gte: query.minPrice }),
              ...(query.maxPrice !== undefined && { lte: query.maxPrice }),
            },
          }
        : {}),
      ...(query.search
        ? {
            OR: [
              { title: { contains: query.search, mode: 'insensitive' } },
              { description: { contains: query.search, mode: 'insensitive' } },
              { location: { contains: query.search, mode: 'insensitive' } },
            ],
          }
        : {}),
      ...(query.date
        ? {
            AND: [
              {
                OR: [
                  {
                    availability: {
                      none: { date: parseDateOnly(query.date) },
                    },
                  },
                  {
                    availability: {
                      some: {
                        date: parseDateOnly(query.date),
                        isAvailable: true,
                      },
                    },
                  },
                ],
              },
            ],
          }
        : {}),
    };

    const [rows, total] = await Promise.all([
      this.prisma.equipment.findMany({
        where,
        include: {
          owner: { select: { id: true, fullName: true, profileImage: true } },
        },
      }),
      this.prisma.equipment.count({ where }),
    ]);

    let data = rows.sort((a, b) => {
      const aBoost = isActivelyBoosted(a, now) ? 1 : 0;
      const bBoost = isActivelyBoosted(b, now) ? 1 : 0;
      if (bBoost !== aBoost) return bBoost - aBoost;
      return b.createdAt.getTime() - a.createdAt.getTime();
    });

    if (query.latitude !== undefined && query.longitude !== undefined) {
      const radius = query.radiusKm ?? 25;
      data = data.filter((item) => {
        if (item.latitude == null || item.longitude == null) return true;
        return (
          haversineKm(
            query.latitude!,
            query.longitude!,
            item.latitude,
            item.longitude,
          ) <= radius
        );
      });
    }

    const paged = data.slice(skip, skip + take);
    const filteredTotal =
      query.latitude !== undefined && query.longitude !== undefined
        ? data.length
        : total;

    return paginatedResponse(paged, filteredTotal, page, limit);
  }

  async findMy(userId: string, query: PaginationDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where: Prisma.EquipmentWhereInput = {
      ownerId: userId,
      deletedAt: null,
      ...(query.search
        ? {
            OR: [
              { title: { contains: query.search, mode: 'insensitive' } },
              { description: { contains: query.search, mode: 'insensitive' } },
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
      }),
      this.prisma.equipment.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async findOne(id: string) {
    const equipment = await this.prisma.equipment.findFirst({
      where: { id, deletedAt: null, isApproved: true },
      include: {
        owner: {
          select: {
            id: true,
            fullName: true,
            profileImage: true,
            averageRating: true,
            totalReviews: true,
          },
        },
        availability: { orderBy: { date: 'asc' } },
      },
    });
    if (!equipment) {
      throw new NotFoundException('Equipment not found');
    }
    return equipment;
  }

  async update(userId: string, id: string, dto: UpdateEquipmentDto) {
    const equipment = await this.getOwnedEquipment(id, userId);
    return this.prisma.equipment.update({
      where: { id: equipment.id },
      data: {
        ...(dto.title !== undefined && { title: dto.title }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.category !== undefined && { category: dto.category }),
        ...(dto.quantity !== undefined && { quantity: dto.quantity }),
        ...(dto.pricePerDay !== undefined && { pricePerDay: dto.pricePerDay }),
        ...(dto.depositAmount !== undefined && {
          depositAmount: dto.depositAmount,
        }),
        ...(dto.location !== undefined && { location: dto.location }),
        ...(dto.latitude !== undefined && { latitude: dto.latitude }),
        ...(dto.longitude !== undefined && { longitude: dto.longitude }),
        ...(dto.isAvailable !== undefined && { isAvailable: dto.isAvailable }),
      },
    });
  }

  async softDelete(userId: string, id: string) {
    await this.getOwnedEquipment(id, userId);
    await this.prisma.equipment.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
    return { message: 'Equipment deleted successfully' };
  }

  async addImages(userId: string, id: string, urls: string[]) {
    const equipment = await this.getOwnedEquipment(id, userId);
    return this.prisma.equipment.update({
      where: { id: equipment.id },
      data: { images: { set: [...equipment.images, ...urls] } },
    });
  }

  async removeImage(userId: string, id: string, imageId: string) {
    const equipment = await this.getOwnedEquipment(id, userId);
    const decoded = decodeURIComponent(imageId);
    let images = [...equipment.images];

    const index = Number.parseInt(decoded, 10);
    if (!Number.isNaN(index) && index >= 0 && index < images.length) {
      images.splice(index, 1);
    } else {
      const urlIndex = images.indexOf(decoded);
      if (urlIndex === -1) {
        throw new NotFoundException('Image not found');
      }
      images.splice(urlIndex, 1);
    }

    return this.prisma.equipment.update({
      where: { id: equipment.id },
      data: { images },
    });
  }

  async boost(userId: string, id: string, dto: BoostEquipmentDto) {
    await this.getOwnedEquipment(id, userId);

    const defaultDays = Number(this.config.get('BOOST_DURATION_DAYS') ?? 7);
    const days = dto.days ?? defaultDays;
    const fee = Number(this.config.get('BOOST_FEE_RWF') ?? 3000);
    const boostedUntil = new Date(Date.now() + days * 24 * 60 * 60_000);

    const [equipment] = await this.prisma.$transaction([
      this.prisma.equipment.update({
        where: { id },
        data: { isBoosted: true, boostedUntil },
      }),
      this.prisma.transaction.create({
        data: {
          userId,
          amount: fee,
          type: TransactionType.BOOST,
          status: PaymentStatus.PAID,
          metadata: { equipmentId: id, days, feeRwf: fee },
        },
      }),
    ]);

    return equipment;
  }

  async cancelBoost(userId: string, id: string) {
    await this.getOwnedEquipment(id, userId);
    return this.prisma.equipment.update({
      where: { id },
      data: { isBoosted: false, boostedUntil: null },
    });
  }

  getCategories() {
    return { categories: Object.values(EquipmentCategory) };
  }

  async getPopular(query: PaginationDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where: Prisma.EquipmentWhereInput = {
      deletedAt: null,
      isApproved: true,
    };

    const [data, total] = await Promise.all([
      this.prisma.equipment.findMany({
        where,
        skip,
        take,
        orderBy: [{ totalReviews: 'desc' }, { averageRating: 'desc' }],
        include: {
          owner: { select: { id: true, fullName: true, profileImage: true } },
        },
      }),
      this.prisma.equipment.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async getNearby(query: EquipmentFilterDto) {
    if (query.latitude === undefined || query.longitude === undefined) {
      const { skip, take, page, limit } = paginate(query.page, query.limit);
      const where: Prisma.EquipmentWhereInput = {
        deletedAt: null,
        isApproved: true,
        isAvailable: true,
      };
      const [data, total] = await Promise.all([
        this.prisma.equipment.findMany({
          where,
          skip,
          take,
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.equipment.count({ where }),
      ]);
      return paginatedResponse(data, total, page, limit);
    }

    return this.findAll({
      ...query,
      latitude: query.latitude,
      longitude: query.longitude,
      radiusKm: query.radiusKm ?? 25,
    });
  }

  async setAvailability(userId: string, id: string, dto: SetAvailabilityDto) {
    await this.getOwnedEquipment(id, userId);
    await this.upsertAvailability(id, dto.dates, dto.isAvailable);
    return this.getAvailability(userId, id);
  }

  async getAvailability(userId: string, id: string) {
    await this.getOwnedEquipment(id, userId);
    const rows = await this.prisma.availability.findMany({
      where: { equipmentId: id },
      orderBy: { date: 'asc' },
    });
    return { data: rows };
  }

  async updateAvailability(userId: string, id: string, dto: SetAvailabilityDto) {
    return this.setAvailability(userId, id, dto);
  }

  async removeAvailabilityDate(userId: string, id: string, date: string) {
    await this.getOwnedEquipment(id, userId);
    const parsed = parseDateOnly(date);
    await this.prisma.availability.deleteMany({
      where: { equipmentId: id, date: parsed },
    });
    return { message: 'Availability date removed' };
  }

  async blockDates(userId: string, id: string, dto: BlockDatesDto) {
    await this.getOwnedEquipment(id, userId);
    await this.upsertAvailability(id, dto.dates, false);
    return this.getAvailability(userId, id);
  }

  private async upsertAvailability(
    equipmentId: string,
    dates: string[],
    isAvailable: boolean,
  ) {
    await Promise.all(
      dates.map((dateStr) =>
        this.prisma.availability.upsert({
          where: {
            equipmentId_date: {
              equipmentId,
              date: parseDateOnly(dateStr),
            },
          },
          create: {
            equipmentId,
            date: parseDateOnly(dateStr),
            isAvailable,
          },
          update: { isAvailable },
        }),
      ),
    );
  }

  private async getOwnedEquipment(id: string, userId: string) {
    const equipment = await this.prisma.equipment.findFirst({
      where: { id, deletedAt: null },
    });
    if (!equipment) {
      throw new NotFoundException('Equipment not found');
    }
    if (equipment.ownerId !== userId) {
      throw new ForbiddenException('You do not own this equipment');
    }
    return equipment;
  }
}
