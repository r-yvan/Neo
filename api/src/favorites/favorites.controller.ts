import {
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { PaginationDto } from '../common/dto/pagination.dto.js';

@ApiTags('Favorites')
@ApiBearerAuth()
@Controller('favorites')
export class FavoritesController {
  constructor(private favoritesService: FavoritesService) {}

  @Get()
  @ApiOperation({ summary: 'Get my favorite equipment' })
  findAll(
    @CurrentUser('id') userId: string,
    @Query() query: PaginationDto,
  ) {
    return this.favoritesService.findAll(userId, query);
  }

  @Post(':equipmentId')
  @ApiOperation({ summary: 'Add equipment to favorites' })
  add(
    @CurrentUser('id') userId: string,
    @Param('equipmentId', ParseUUIDPipe) equipmentId: string,
  ) {
    return this.favoritesService.add(userId, equipmentId);
  }

  @Delete(':equipmentId')
  @ApiOperation({ summary: 'Remove equipment from favorites' })
  remove(
    @CurrentUser('id') userId: string,
    @Param('equipmentId', ParseUUIDPipe) equipmentId: string,
  ) {
    return this.favoritesService.remove(userId, equipmentId);
  }
}
