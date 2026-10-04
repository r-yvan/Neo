import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../common/decorators/roles.decorator.js';
import { AdminService } from './admin.service.js';
import {
  AdminBookingListQueryDto,
  AdminDisputeListQueryDto,
  AdminEquipmentListQueryDto,
  AdminReportListQueryDto,
  AdminReviewListQueryDto,
  AdminTransactionListQueryDto,
  AdminUserListQueryDto,
  ResolveDisputeDto,
  ResolveReportDto,
} from './dto/admin.dto.js';

@ApiTags('Admin')
@ApiBearerAuth()
@Roles(UserRole.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Admin platform metrics and counters' })
  dashboard() {
    return this.adminService.dashboard();
  }

  @Get('analytics')
  @ApiOperation({ summary: 'Platform analytics over the past 30 days' })
  analytics() {
    return this.adminService.analytics();
  }

  @Get('users')
  @ApiOperation({ summary: 'List all users with search and pagination' })
  listUsers(@Query() query: AdminUserListQueryDto) {
    return this.adminService.listUsers(query);
  }

  @Get('users/:id')
  @ApiOperation({ summary: 'Get details for a specific user' })
  getUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.getUser(id);
  }

  @Patch('users/:id/verify')
  @ApiOperation({ summary: 'Verify user national ID / KYC' })
  verifyUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.verifyUser(id);
  }

  @Patch('users/:id/ban')
  @ApiOperation({ summary: 'Ban a user account' })
  banUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.banUser(id);
  }

  @Patch('users/:id/unban')
  @ApiOperation({ summary: 'Unban a user account' })
  unbanUser(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.unbanUser(id);
  }

  @Get('equipment')
  @ApiOperation({ summary: 'List all equipment listings' })
  listEquipment(@Query() query: AdminEquipmentListQueryDto) {
    return this.adminService.listEquipment(query);
  }

  @Patch('equipment/:id/approve')
  @ApiOperation({ summary: 'Approve an equipment listing' })
  approveEquipment(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.approveEquipment(id);
  }

  @Patch('equipment/:id/reject')
  @ApiOperation({ summary: 'Reject or unapprove an equipment listing' })
  rejectEquipment(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.rejectEquipment(id);
  }

  @Get('bookings')
  @ApiOperation({ summary: 'List all platform bookings' })
  listBookings(@Query() query: AdminBookingListQueryDto) {
    return this.adminService.listBookings(query);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'List all platform financial transactions' })
  listTransactions(@Query() query: AdminTransactionListQueryDto) {
    return this.adminService.listTransactions(query);
  }

  @Get('reviews')
  @ApiOperation({ summary: 'List all reviews' })
  listReviews(@Query() query: AdminReviewListQueryDto) {
    return this.adminService.listReviews(query);
  }

  @Delete('reviews/:id')
  @ApiOperation({ summary: 'Moderate and delete an inappropriate review' })
  deleteReview(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminService.deleteReview(id);
  }

  @Get('reports')
  @ApiOperation({ summary: 'List reported items and users' })
  listReports(@Query() query: AdminReportListQueryDto) {
    return this.adminService.listReports(query);
  }

  @Patch('reports/:id')
  @ApiOperation({ summary: 'Resolve a report' })
  resolveReport(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ResolveReportDto,
  ) {
    return this.adminService.resolveReport(id, dto);
  }

  @Get('disputes')
  @ApiOperation({ summary: 'List all booking disputes' })
  listDisputes(@Query() query: AdminDisputeListQueryDto) {
    return this.adminService.listDisputes(query);
  }

  @Patch('disputes/:id')
  @ApiOperation({ summary: 'Resolve a booking dispute' })
  resolveDispute(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ResolveDisputeDto,
  ) {
    return this.adminService.resolveDispute(id, dto);
  }
}
