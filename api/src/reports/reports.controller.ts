import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ReportsService } from './reports.service.js';
import {
  CreateDisputeDto,
  CreateReportDto,
  ReportListQueryDto,
  RespondDisputeDto,
} from './dto/report.dto.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';

@ApiTags('Reports & Disputes')
@ApiBearerAuth()
@Controller()
export class ReportsController {
  constructor(private reportsService: ReportsService) {}

  @Post('reports')
  @ApiOperation({ summary: 'Report a user, equipment, or review' })
  createReport(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateReportDto,
  ) {
    return this.reportsService.createReport(userId, dto);
  }

  @Get('reports/my')
  @ApiOperation({ summary: 'My submitted reports' })
  myReports(
    @CurrentUser('id') userId: string,
    @Query() query: ReportListQueryDto,
  ) {
    return this.reportsService.myReports(userId, query);
  }

  @Post('disputes')
  @ApiOperation({ summary: 'Open a dispute on a booking' })
  createDispute(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateDisputeDto,
  ) {
    return this.reportsService.createDispute(userId, dto);
  }

  @Get('disputes/:id')
  @ApiOperation({ summary: 'Get dispute details' })
  getDispute(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.reportsService.getDispute(userId, id);
  }

  @Patch('disputes/:id/respond')
  @ApiOperation({ summary: 'Respond to a dispute' })
  respondDispute(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RespondDisputeDto,
  ) {
    return this.reportsService.respondDispute(userId, id, dto);
  }
}
