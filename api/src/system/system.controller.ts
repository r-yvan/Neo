import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator.js';
import { SystemService } from './system.service.js';

@ApiTags('System')
@Controller('system')
export class SystemController {
  constructor(private readonly systemService: SystemService) {}

  @Public()
  @Get('health')
  @ApiOperation({ summary: 'Platform health status and database connectivity' })
  health() {
    return this.systemService.getHealth();
  }

  @Public()
  @Get('config')
  @ApiOperation({ summary: 'Public platform configuration (commission rates, boost pricing, payment methods)' })
  config() {
    return this.systemService.getConfig();
  }

  @Public()
  @Get('locations')
  @ApiOperation({ summary: 'Supported Rwandan provinces and districts' })
  locations() {
    return this.systemService.getLocations();
  }

  @Public()
  @Get('categories')
  @ApiOperation({ summary: 'List of equipment categories with human-readable labels' })
  categories() {
    return this.systemService.getCategories();
  }
}
