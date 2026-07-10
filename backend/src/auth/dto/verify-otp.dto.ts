import { IsNotEmpty, IsString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({ example: '+1234567890', description: 'Contact phone number' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+?[1-9]\d{1,14}$/, { message: 'Phone must be a valid E.164 phone number format' })
  phone: string;

  @ApiProperty({ example: '123456', description: '6-digit OTP verification code' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\d{6}$/, { message: 'OTP must be a 6-digit numeric string' })
  code: string;
}
export class SendOtpDto {
  @ApiProperty({ example: '+1234567890', description: 'Contact phone number to send OTP to' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+?[1-9]\d{1,14}$/, { message: 'Phone must be a valid E.164 phone number format' })
  phone: string;
}
