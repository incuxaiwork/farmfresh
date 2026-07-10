import { IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ResetPasswordDto {
  @ApiProperty({ example: 'reset-token-received-in-email', description: 'Verification reset token' })
  @IsNotEmpty()
  @IsString()
  token: string;

  @ApiProperty({ example: 'newPassword123', description: 'New account password (minimum 8 characters)' })
  @IsNotEmpty()
  @MinLength(8)
  newPassword: string;
}
