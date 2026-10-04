import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { EquipmentService } from './equipment.service.js';
import {
  AddEquipmentImagesDto,
  BlockDatesDto,
  BoostEquipmentDto,
  CreateEquipmentDto,
  EquipmentFilterDto,
  SetAvailabilityDto,
  UpdateEquipmentDto,
} from './dto/equipment.dto.js';
import { Public } from '../common/decorators/public.decorator.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { PaginationDto } from '../common/dto/pagination.dto.js';
import { UserRole } from '@prisma/client';

type AuthUser = {
  id: string;
  isVerified: boolean;
  roles: UserRole[];
};

@ApiTags('Equipment')
@Controller('equipment')
export class EquipmentController {
  constructor(private equipmentService: EquipmentService) {}

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create equipment listing' })
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateEquipmentDto) {
    return this.equipmentService.create(
      user.id,
      user.isVerified,
      user.roles,
      dto,
    );
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'List equipment with filters' })
  findAll(@Query() query: EquipmentFilterDto) {
    return this.equipmentService.findAll(query);
  }

  @Get('my')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List current user equipment' })
  findMy(@CurrentUser('id') userId: string, @Query() query: PaginationDto) {
    return this.equipmentService.findMy(userId, query);
  }

  @Public()
  @Get('categories')
  @ApiOperation({ summary: 'Equipment category enum values' })
  getCategories() {
    return this.equipmentService.getCategories();
  }

  @Public()
  @Get('popular')
  @ApiOperation({ summary: 'Popular equipment by reviews and rating' })
  getPopular(@Query() query: PaginationDto) {
    return this.equipmentService.getPopular(query);
  }

  @Public()
  @Get('nearby')
  @ApiOperation({ summary: 'Nearby available equipment' })
  getNearby(@Query() query: EquipmentFilterDto) {
    return this.equipmentService.getNearby(query);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get equipment by id' })
  findOne(@Param('id') id: string) {
    return this.equipmentService.findOne(id);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update owned equipment' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateEquipmentDto,
  ) {
    return this.equipmentService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Soft-delete owned equipment' })
  softDelete(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.equipmentService.softDelete(userId, id);
  }

  @Post(':id/images')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Append image URLs to equipment' })
  addImages(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: AddEquipmentImagesDto,
  ) {
    return this.equipmentService.addImages(userId, id, dto.urls);
  }

  @Delete(':id/images/:imageId')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove image by index or URL' })
  removeImage(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Param('imageId') imageId: string,
  ) {
    return this.equipmentService.removeImage(userId, id, imageId);
  }

  @Post(':id/boost')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Boost listing visibility' })
  boost(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: BoostEquipmentDto,
  ) {
    return this.equipmentService.boost(userId, id, dto);
  }

  @Delete(':id/boost')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cancel active boost' })
  cancelBoost(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.equipmentService.cancelBoost(userId, id);
  }

  @Post(':id/availability')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Set availability for dates' })
  setAvailability(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: SetAvailabilityDto,
  ) {
    return this.equipmentService.setAvailability(userId, id, dto);
  }

  @Get(':id/availability')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get availability calendar' })
  getAvailability(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.equipmentService.getAvailability(userId, id);
  }

  @Put(':id/availability')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update availability for dates' })
  updateAvailability(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: SetAvailabilityDto,
  ) {
    return this.equipmentService.updateAvailability(userId, id, dto);
  }

  @Delete(':id/availability/:date')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove availability override for a date' })
  removeAvailabilityDate(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Param('date') date: string,
  ) {
    return this.equipmentService.removeAvailabilityDate(userId, id, date);
  }

  @Post(':id/block-dates')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Block dates from booking' })
  blockDates(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: BlockDatesDto,
  ) {
    return this.equipmentService.blockDates(userId, id, dto);
  }
}
