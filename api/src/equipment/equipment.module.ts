import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EquipmentService } from './equipment.service.js';
import { EquipmentController } from './equipment.controller.js';

@Module({
  imports: [ConfigModule],
  controllers: [EquipmentController],
  providers: [EquipmentService],
  exports: [EquipmentService],
})
export class EquipmentModule {}
