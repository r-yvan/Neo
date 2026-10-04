import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class SendMessageDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  receiverId: string;

  @ApiProperty({ example: 'Hello, is this still available?' })
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  bookingId?: string;
}
