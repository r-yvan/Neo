import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  paginate,
  paginatedResponse,
  PaginationDto,
} from '../common/dto/pagination.dto.js';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async add(userId: string, equipmentId: string) {
    const equipment = await this.prisma.equipment.findFirst({
      where: { id: equipmentId, deletedAt: null },
    });
    if (!equipment) {
      throw new NotFoundException('Equipment not found');
    }

    const existing = await this.prisma.favorite.findUnique({
      where: { userId_equipmentId: { userId, equipmentId } },
    });
    if (existing) {
      return existing;
    }

    return this.prisma.favorite.create({
      data: { userId, equipmentId },
      include: {
        equipment: {
          select: {
            id: true,
            title: true,
            category: true,
            pricePerDay: true,
            images: true,
            location: true,
            averageRating: true,
          },
        },
      },
    });
  }

  async remove(userId: string, equipmentId: string) {
    const existing = await this.prisma.favorite.findUnique({
      where: { userId_equipmentId: { userId, equipmentId } },
    });
    if (!existing) {
      throw new NotFoundException('Favorite not found');
    }

    await this.prisma.favorite.delete({
      where: { userId_equipmentId: { userId, equipmentId } },
    });
    return { message: 'Removed from favorites' };
  }

  async findAll(userId: string, query: PaginationDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = { userId };

    const [data, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          equipment: {
            select: {
              id: true,
              title: true,
              category: true,
              pricePerDay: true,
              images: true,
              location: true,
              averageRating: true,
              totalReviews: true,
              isAvailable: true,
              owner: {
                select: { id: true, fullName: true, profileImage: true },
              },
            },
          },
        },
      }),
      this.prisma.favorite.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }
}
