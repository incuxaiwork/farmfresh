import { IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'customer@farmfresh.com', description: 'User login identity (either email or phone number)' })
  @IsNotEmpty()
  @IsString()
  username: string; // Accepts email or phone

  @ApiProperty({ example: 'password123', description: 'Account password' })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;
}
