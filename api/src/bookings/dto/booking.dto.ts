import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
} from 'class-validator';
import { BookingStatus } from '@prisma/client';
import { PaginationDto } from '../../common/dto/pagination.dto.js';

export class CreateBookingDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  equipmentId: string;

  @ApiProperty({ example: '2026-10-10' })
  @IsDateString()
  startDate: string;

  @ApiProperty({ example: '2026-10-12' })
  @IsDateString()
  endDate: string;

  @ApiProperty({ minimum: 1 })
  @IsInt()
  @Min(1)
  quantity: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;
}

export class ExtendBookingDto {
  @ApiProperty({ example: '2026-10-15' })
  @IsDateString()
  newEndDate: string;
}

export class BookingListQueryDto extends PaginationDto {
  @ApiPropertyOptional({ enum: ['renter', 'owner'] })
  @IsOptional()
  @IsIn(['renter', 'owner'])
  role?: 'renter' | 'owner';

  @ApiPropertyOptional({ enum: BookingStatus })
  @IsOptional()
  @IsEnum(BookingStatus)
  status?: BookingStatus;
}
