import { IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LoginDto {
  @ApiPropertyOptional({ example: 'customer@farmfresh.com', description: 'User email' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ example: 'customer@farmfresh.com', description: 'User username or phone' })
  @IsOptional()
  @IsString()
  username?: string;

  @ApiProperty({ example: 'password123', description: 'Account password' })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;
}
