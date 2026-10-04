import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';
import { UserRole } from '@prisma/client';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Jean Uwimana' })
  @IsOptional()
  @IsString()
  @MinLength(2)
  fullName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsEmail()
  email?: string;
}

export class ChangePasswordDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  currentPassword: string;

  @ApiProperty({ minLength: 6 })
  @IsString()
  @MinLength(6)
  newPassword: string;
}

export class VerifyNationalIdDto {
  @ApiProperty({ example: '1199880012345678' })
  @IsString()
  @IsNotEmpty()
  nationalId: string;
}

export class AddRoleDto {
  @ApiProperty({ enum: [UserRole.OWNER, UserRole.RENTER] })
  @IsEnum(UserRole)
  role: UserRole.OWNER | UserRole.RENTER;
}

export class UploadAvatarDto {
  @ApiProperty({ description: 'Public URL of the uploaded avatar image' })
  @IsString()
  @IsNotEmpty()
  url: string;
}
