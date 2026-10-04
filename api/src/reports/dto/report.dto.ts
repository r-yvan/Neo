import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';
import { ReportTargetType } from '@prisma/client';
import { PaginationDto } from '../../common/dto/pagination.dto.js';

export class CreateReportDto {
  @ApiProperty({ enum: ReportTargetType })
  @IsEnum(ReportTargetType)
  targetType: ReportTargetType;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  targetId: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  reason: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  details?: string;
}

export class CreateDisputeDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  bookingId: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  reason: string;
}

export class RespondDisputeDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  response: string;
}

export class ReportListQueryDto extends PaginationDto {}
