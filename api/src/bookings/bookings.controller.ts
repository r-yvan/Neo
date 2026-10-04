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
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { BookingsService } from './bookings.service.js';
import {
  BookingListQueryDto,
  CreateBookingDto,
  ExtendBookingDto,
} from './dto/booking.dto.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';

@ApiTags('Bookings')
@ApiBearerAuth()
@Controller('bookings')
export class BookingsController {
  constructor(private bookingsService: BookingsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a rental booking' })
  create(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateBookingDto,
  ) {
    return this.bookingsService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List my bookings (optional role filter)' })
  findMy(
    @CurrentUser('id') userId: string,
    @Query() query: BookingListQueryDto,
  ) {
    return this.bookingsService.findMy(userId, query);
  }

  @Get('renter')
  @ApiOperation({ summary: 'List bookings as renter' })
  findAsRenter(
    @CurrentUser('id') userId: string,
    @Query() query: BookingListQueryDto,
  ) {
    return this.bookingsService.findMyAsRenter(userId, query);
  }

  @Get('owner')
  @ApiOperation({ summary: 'List bookings as equipment owner' })
  findAsOwner(
    @CurrentUser('id') userId: string,
    @Query() query: BookingListQueryDto,
  ) {
    return this.bookingsService.findMyAsOwner(userId, query);
  }

  @Get(':id/timeline')
  @ApiOperation({ summary: 'Booking status timeline' })
  timeline(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.timeline(userId, id);
  }

  @Post(':id/extend')
  @ApiOperation({ summary: 'Extend booking end date' })
  extend(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ExtendBookingDto,
  ) {
    return this.bookingsService.extend(userId, id, dto);
  }

  @Patch(':id/accept')
  @ApiOperation({ summary: 'Accept booking (owner)' })
  accept(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.accept(userId, id);
  }

  @Patch(':id/reject')
  @ApiOperation({ summary: 'Reject booking (owner)' })
  reject(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.reject(userId, id);
  }

  @Patch(':id/cancel')
  @ApiOperation({ summary: 'Cancel booking (renter or owner)' })
  cancel(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.cancel(userId, id);
  }

  @Patch(':id/start')
  @ApiOperation({ summary: 'Start rental (owner)' })
  start(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.start(userId, id);
  }

  @Patch(':id/complete')
  @ApiOperation({ summary: 'Complete rental (owner or renter)' })
  complete(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.complete(userId, id);
  }

  @Patch(':id/dispute')
  @ApiOperation({ summary: 'Mark booking as disputed' })
  dispute(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.dispute(userId, id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get booking by id' })
  findOne(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.findOne(userId, id);
  }
}
