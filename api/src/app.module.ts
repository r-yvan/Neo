import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { UsersModule } from './users/users.module.js';
import { EquipmentModule } from './equipment/equipment.module.js';
import { BookingsModule } from './bookings/bookings.module.js';
import { PaymentsModule } from './payments/payments.module.js';
import { ReviewsModule } from './reviews/reviews.module.js';
import { ChatModule } from './chat/chat.module.js';
import { NotificationsModule } from './notifications/notifications.module.js';
import { FavoritesModule } from './favorites/favorites.module.js';
import { ReportsModule } from './reports/reports.module.js';
import { AdminModule } from './admin/admin.module.js';
import { SystemModule } from './system/system.module.js';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard.js';
import { RolesGuard } from './common/guards/roles.guard.js';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ThrottlerModule.forRoot([
      {
        ttl: Number(process.env.THROTTLE_TTL || 60) * 1000,
        limit: Number(process.env.THROTTLE_LIMIT || 100),
      },
    ]),
    PrismaModule,
    AuthModule,
    UsersModule,
    EquipmentModule,
    BookingsModule,
    PaymentsModule,
    ReviewsModule,
    ChatModule,
    NotificationsModule,
    FavoritesModule,
    ReportsModule,
    AdminModule,
    SystemModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
