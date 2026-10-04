import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsEmail,
  MinLength,
  Matches,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: '0780000000' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(07|2507|\+2507)\d{8}$/, {
    message: 'Phone must be a valid Rwandan number',
  })
  phone: string;

  @ApiProperty({ example: 'Jean Uwimana' })
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  fullName: string;

  @ApiPropertyOptional({ example: '1199880012345678' })
  @IsOptional()
  @IsString()
  nationalId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ minLength: 6 })
  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;
}

export class LoginDto {
  @ApiProperty({ example: '0780000000' })
  @IsString()
  @IsNotEmpty()
  phone: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  password?: string;

  @ApiPropertyOptional({ description: 'OTP code as alternative to password' })
  @IsOptional()
  @IsString()
  otp?: string;
}

export class SendOtpDto {
  @ApiProperty({ example: '0780000000' })
  @IsString()
  @IsNotEmpty()
  phone: string;
}

export class VerifyOtpDto {
  @ApiProperty({ example: '0780000000' })
  @IsString()
  @IsNotEmpty()
  phone: string;

  @ApiProperty({ example: '123456' })
  @IsString()
  @IsNotEmpty()
  otp: string;
}

export class RefreshTokenDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  refreshToken: string;
}

export class ForgotPasswordDto {
  @ApiProperty({ example: '0780000000' })
  @IsString()
  @IsNotEmpty()
  phone: string;
}

export class ResetPasswordDto {
  @ApiProperty({ example: '0780000000' })
  @IsString()
  @IsNotEmpty()
  phone: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  otp: string;

  @ApiProperty({ minLength: 6 })
  @IsString()
  @MinLength(6)
  newPassword: string;
}
