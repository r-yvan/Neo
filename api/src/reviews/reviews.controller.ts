import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ReviewsService } from './reviews.service.js';
import {
  CreateReviewDto,
  ReviewListQueryDto,
  UpdateReviewDto,
} from './dto/review.dto.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { Public } from '../common/decorators/public.decorator.js';

@ApiTags('Reviews')
@Controller('reviews')
export class ReviewsController {
  constructor(private reviewsService: ReviewsService) {}

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a review for a completed booking' })
  create(@CurrentUser('id') userId: string, @Body() dto: CreateReviewDto) {
    return this.reviewsService.create(userId, dto);
  }

  @Get('my')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List my given and received reviews' })
  findMy(
    @CurrentUser('id') userId: string,
    @Query() query: ReviewListQueryDto,
  ) {
    return this.reviewsService.findMy(userId, query);
  }

  @Public()
  @Get('equipment/:equipmentId')
  @ApiOperation({ summary: 'List reviews for specific equipment' })
  findByEquipment(
    @Param('equipmentId', ParseUUIDPipe) equipmentId: string,
    @Query() query: ReviewListQueryDto,
  ) {
    return this.reviewsService.findByEquipment(equipmentId, query);
  }

  @Public()
  @Get('user/:userId')
  @ApiOperation({ summary: 'List reviews received by a user' })
  findByUser(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Query() query: ReviewListQueryDto,
  ) {
    return this.reviewsService.findByUser(userId, query);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Edit own review' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateReviewDto,
  ) {
    return this.reviewsService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete own review' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.reviewsService.remove(userId, id);
  }
}
