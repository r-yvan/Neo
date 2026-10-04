import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  AddRoleDto,
  ChangePasswordDto,
  UpdateProfileDto,
  VerifyNationalIdDto,
} from './dto/users.dto.js';
import {
  paginate,
  paginatedResponse,
  PaginationDto,
} from '../common/dto/pagination.dto.js';

const PUBLIC_USER_SELECT = {
  id: true,
  fullName: true,
  profileImage: true,
  averageRating: true,
  totalReviews: true,
  roles: true,
  createdAt: true,
} as const;

const ME_SELECT = {
  id: true,
  phone: true,
  fullName: true,
  email: true,
  nationalId: true,
  roles: true,
  isVerified: true,
  profileImage: true,
  averageRating: true,
  totalReviews: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getMe(userId: string) {
    const user = await this.prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: ME_SELECT,
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async updateMe(userId: string, dto: UpdateProfileDto) {
    if (dto.email) {
      const taken = await this.prisma.user.findFirst({
        where: { email: dto.email, deletedAt: null, NOT: { id: userId } },
      });
      if (taken) {
        throw new ConflictException('Email already in use');
      }
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(dto.fullName !== undefined && { fullName: dto.fullName }),
        ...(dto.email !== undefined && { email: dto.email }),
      },
      select: ME_SELECT,
    });
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
    });
    if (!user?.passwordHash) {
      throw new BadRequestException('No password set on this account');
    }

    const valid = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!valid) {
      throw new BadRequestException('Current password is incorrect');
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, 10);
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    await this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });

    return { message: 'Password changed successfully' };
  }

  async getPublicProfile(id: string) {
    const user = await this.prisma.user.findFirst({
      where: { id, deletedAt: null, isBanned: false },
      select: PUBLIC_USER_SELECT,
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async getUserReviews(userId: string, query: PaginationDto) {
    await this.ensureUserExists(userId);

    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = {
      toUserId: userId,
      ...(query.search
        ? { comment: { contains: query.search, mode: 'insensitive' as const } }
        : {}),
    };

    const [data, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          fromUser: { select: { id: true, fullName: true, profileImage: true } },
          equipment: { select: { id: true, title: true } },
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async getUserEquipment(userId: string, query: PaginationDto) {
    await this.ensureUserExists(userId);

    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = {
      ownerId: userId,
      deletedAt: null,
      isApproved: true,
      ...(query.search
        ? {
            OR: [
              { title: { contains: query.search, mode: 'insensitive' as const } },
              {
                description: {
                  contains: query.search,
                  mode: 'insensitive' as const,
                },
              },
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

  async searchUsers(query: PaginationDto) {
    const { skip, take, page, limit } = paginate(query.page, query.limit);
    const where = {
      deletedAt: null,
      isBanned: false,
      ...(query.search
        ? { fullName: { contains: query.search, mode: 'insensitive' as const } }
        : {}),
    };

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take,
        orderBy: { fullName: 'asc' },
        select: PUBLIC_USER_SELECT,
      }),
      this.prisma.user.count({ where }),
    ]);

    return paginatedResponse(data, total, page, limit);
  }

  async addRole(userId: string, dto: AddRoleDto) {
    if (dto.role !== UserRole.OWNER && dto.role !== UserRole.RENTER) {
      throw new BadRequestException('Only OWNER or RENTER roles can be added');
    }

    const user = await this.prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.roles.includes(dto.role)) {
      return this.getMe(userId);
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { roles: { set: [...user.roles, dto.role] } },
      select: ME_SELECT,
    });
  }

  async submitNationalId(userId: string, dto: VerifyNationalIdDto) {
    const taken = await this.prisma.user.findFirst({
      where: {
        nationalId: dto.nationalId,
        deletedAt: null,
        NOT: { id: userId },
      },
    });
    if (taken) {
      throw new ConflictException('National ID already registered');
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { nationalId: dto.nationalId },
      select: ME_SELECT,
    });
  }

  async uploadAvatar(userId: string, url: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { profileImage: url },
      select: ME_SELECT,
    });
  }

  async removeAvatar(userId: string) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { profileImage: null },
      select: ME_SELECT,
    });
  }

  private async ensureUserExists(userId: string) {
    const user = await this.prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: { id: true },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
  }
}
