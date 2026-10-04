import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { randomInt, createHash } from 'crypto';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  RegisterDto,
  LoginDto,
  VerifyOtpDto,
  ResetPasswordDto,
} from './dto/auth.dto.js';
import { UserRole } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
    private config: ConfigService,
  ) {}

  normalizePhone(phone: string): string {
    const digits = phone.replace(/\D/g, '');
    if (digits.startsWith('250')) return digits;
    if (digits.startsWith('0')) return `250${digits.slice(1)}`;
    return digits;
  }

  private sanitizeUser<T extends { passwordHash?: string | null }>(user: T) {
    const { passwordHash: _, ...safe } = user;
    return safe;
  }

  async register(dto: RegisterDto) {
    const phone = this.normalizePhone(dto.phone);
    const existing = await this.prisma.user.findUnique({ where: { phone } });
    if (existing) {
      throw new ConflictException('Phone number already registered');
    }

    if (dto.nationalId) {
      const idTaken = await this.prisma.user.findUnique({
        where: { nationalId: dto.nationalId },
      });
      if (idTaken) {
        throw new ConflictException('National ID already registered');
      }
    }

    const passwordHash = dto.password
      ? await bcrypt.hash(dto.password, 10)
      : null;

    const user = await this.prisma.user.create({
      data: {
        phone,
        fullName: dto.fullName,
        nationalId: dto.nationalId,
        email: dto.email,
        passwordHash,
        roles: [UserRole.RENTER],
        notificationSetting: { create: {} },
      },
    });

    await this.sendOtp(phone);
    const tokens = await this.issueTokens(user.id, user.phone, user.roles);

    return {
      message: 'Registered successfully. OTP sent for verification.',
      user: this.sanitizeUser(user),
      ...tokens,
    };
  }

  async login(dto: LoginDto) {
    const phone = this.normalizePhone(dto.phone);
    const user = await this.prisma.user.findFirst({
      where: { phone, deletedAt: null },
    });

    if (!user || user.isBanned) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (dto.otp) {
      await this.verifyOtpCode(phone, dto.otp);
    } else if (dto.password) {
      if (!user.passwordHash) {
        throw new BadRequestException(
          'No password set. Login with OTP instead.',
        );
      }
      const valid = await bcrypt.compare(dto.password, user.passwordHash);
      if (!valid) {
        throw new UnauthorizedException('Invalid credentials');
      }
    } else {
      throw new BadRequestException('Provide password or OTP');
    }

    const tokens = await this.issueTokens(user.id, user.phone, user.roles);
    return { user: this.sanitizeUser(user), ...tokens };
  }

  async sendOtp(phoneInput: string) {
    const phone = this.normalizePhone(phoneInput);
    const length = Number(this.config.get('OTP_LENGTH') || 6);
    const expiresMinutes = Number(this.config.get('OTP_EXPIRES_MINUTES') || 10);
    const code = String(randomInt(0, 10 ** length)).padStart(length, '0');

    await this.prisma.otpCode.create({
      data: {
        phone,
        code,
        expiresAt: new Date(Date.now() + expiresMinutes * 60_000),
      },
    });

    // Dev: log OTP. Replace with SMS provider in production.
    this.logger.log(`[DEV OTP] ${phone} => ${code}`);

    return {
      message: 'OTP sent successfully',
      expiresInMinutes: expiresMinutes,
      ...(this.config.get('NODE_ENV') !== 'production' ? { devOtp: code } : {}),
    };
  }

  private async verifyOtpCode(phone: string, otp: string) {
    const record = await this.prisma.otpCode.findFirst({
      where: {
        phone,
        code: otp,
        used: false,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!record) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    await this.prisma.otpCode.update({
      where: { id: record.id },
      data: { used: true },
    });
  }

  async verifyOtp(dto: VerifyOtpDto) {
    const phone = this.normalizePhone(dto.phone);
    await this.verifyOtpCode(phone, dto.otp);

    const user = await this.prisma.user.findUnique({ where: { phone } });
    if (!user) {
      throw new BadRequestException('User not found. Register first.');
    }

    const updated = await this.prisma.user.update({
      where: { id: user.id },
      data: { isVerified: true },
    });

    const tokens = await this.issueTokens(
      updated.id,
      updated.phone,
      updated.roles,
    );
    return {
      message: 'Phone verified successfully',
      user: this.sanitizeUser(updated),
      ...tokens,
    };
  }

  async refresh(refreshToken: string) {
    const hashed = this.hashToken(refreshToken);
    const stored = await this.prisma.refreshToken.findUnique({
      where: { token: hashed },
      include: { user: true },
    });

    if (
      !stored ||
      stored.revokedAt ||
      stored.expiresAt < new Date() ||
      stored.user.isBanned ||
      stored.user.deletedAt
    ) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });

    return this.issueTokens(
      stored.user.id,
      stored.user.phone,
      stored.user.roles,
    );
  }

  async logout(refreshToken?: string, userId?: string) {
    if (refreshToken) {
      const hashed = this.hashToken(refreshToken);
      await this.prisma.refreshToken.updateMany({
        where: { token: hashed, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    } else if (userId) {
      await this.prisma.refreshToken.updateMany({
        where: { userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
    return { message: 'Logged out successfully' };
  }

  async forgotPassword(phoneInput: string) {
    const phone = this.normalizePhone(phoneInput);
    const user = await this.prisma.user.findUnique({ where: { phone } });
    if (!user) {
      // Do not leak existence
      return { message: 'If the account exists, an OTP was sent' };
    }
    await this.sendOtp(phone);
    return { message: 'If the account exists, an OTP was sent' };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const phone = this.normalizePhone(dto.phone);
    await this.verifyOtpCode(phone, dto.otp);
    const passwordHash = await bcrypt.hash(dto.newPassword, 10);
    await this.prisma.user.update({
      where: { phone },
      data: { passwordHash },
    });
    await this.prisma.refreshToken.updateMany({
      where: { user: { phone }, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { message: 'Password reset successfully' };
  }

  async me(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: userId },
      select: {
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
      },
    });
    return user;
  }

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }

  private async issueTokens(userId: string, phone: string, roles: UserRole[]) {
    const payload = { sub: userId, phone, roles };
    const accessExpires =
      this.config.get<string>('JWT_ACCESS_EXPIRES_IN') || '15m';
    const refreshExpires =
      this.config.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d';

    const accessToken = await this.jwt.signAsync(payload, {
      secret: this.config.getOrThrow('JWT_ACCESS_SECRET'),
      expiresIn: accessExpires as `${number}${'s' | 'm' | 'h' | 'd'}`,
    });
    const refreshToken = await this.jwt.signAsync(payload, {
      secret: this.config.getOrThrow('JWT_REFRESH_SECRET'),
      expiresIn: refreshExpires as `${number}${'s' | 'm' | 'h' | 'd'}`,
    });

    const days = refreshExpires.endsWith('d')
      ? Number(refreshExpires.replace('d', ''))
      : 7;

    await this.prisma.refreshToken.create({
      data: {
        token: this.hashToken(refreshToken),
        userId,
        expiresAt: new Date(Date.now() + days * 24 * 60 * 60_000),
      },
    });

    return { accessToken, refreshToken };
  }
}
