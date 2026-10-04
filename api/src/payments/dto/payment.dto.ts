import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  Matches,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationDto } from '../../common/dto/pagination.dto.js';

export enum MobileMoneyProvider {
  MOMO = 'MOMO',
  AIRTEL = 'AIRTEL',
}

export class InitiatePaymentDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  bookingId: string;

  @ApiProperty({ enum: MobileMoneyProvider })
  @IsEnum(MobileMoneyProvider)
  provider: MobileMoneyProvider;
}

export class ConfirmPaymentDto {
  @ApiProperty({ description: 'Payment reference from initiate step' })
  @IsString()
  paymentRef: string;
}

export class WithdrawDto {
  @ApiProperty({ example: 50000 })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;

  @ApiProperty({ example: '0780000000' })
  @IsString()
  @Matches(/^(07|2507|\+2507)\d{8}$/, {
    message: 'Phone must be a valid Rwandan number',
  })
  phone: string;

  @ApiProperty({ enum: MobileMoneyProvider })
  @IsEnum(MobileMoneyProvider)
  provider: MobileMoneyProvider;
}

export class WebhookPaymentDto {
  @ApiProperty()
  @IsString()
  providerRef: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  amount?: number;
}

export class PaymentHistoryQueryDto extends PaginationDto {}
