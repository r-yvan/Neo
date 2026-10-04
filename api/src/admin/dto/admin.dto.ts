import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { DisputeStatus, ReportStatus } from '@prisma/client';
import { PaginationDto } from '../../common/dto/pagination.dto.js';

export class AdminUserListQueryDto extends PaginationDto {}

export class AdminBookingListQueryDto extends PaginationDto {}

export class AdminTransactionListQueryDto extends PaginationDto {}

export class AdminReviewListQueryDto extends PaginationDto {}

export class AdminReportListQueryDto extends PaginationDto {}

export class AdminDisputeListQueryDto extends PaginationDto {}

export class AdminEquipmentListQueryDto extends PaginationDto {}

export class ResolveReportDto {
  @ApiProperty({ enum: [ReportStatus.RESOLVED, ReportStatus.DISMISSED] })
  @IsEnum(ReportStatus)
  status: ReportStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  note?: string;
}

export class ResolveDisputeDto {
  @ApiProperty({ enum: [DisputeStatus.RESOLVED, DisputeStatus.CLOSED] })
  @IsEnum(DisputeStatus)
  status: DisputeStatus;

  @ApiProperty()
  @IsString()
  @MaxLength(2000)
  resolution: string;
}
