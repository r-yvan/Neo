import { Module } from '@nestjs/common';
import { SystemService } from './system.service.js';
import { SystemController } from './system.controller.js';

@Module({
  controllers: [SystemController],
  providers: [SystemService],
  exports: [SystemService],
})
export class SystemModule {}
