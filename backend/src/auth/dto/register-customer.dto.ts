import { IsEmail, IsNotEmpty, IsString, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterCustomerDto {
  @ApiProperty({ example: 'Jane', description: 'First name' })
  @IsNotEmpty()
  @IsString()
  firstName: string;

  @ApiProperty({ example: 'Doe', description: 'Last name' })
  @IsNotEmpty()
  @IsString()
  lastName: string;

  @ApiProperty({ example: 'customer@farmfresh.com', description: 'Email address' })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({ example: '+911234567890', description: 'Contact phone number' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+91\d{10}$/, { message: 'Phone must be a valid Indian mobile number with +91 prefix and 10 digits (e.g., +911234567890)' })
  phone: string;

  @ApiProperty({ example: 'password123', description: 'Account password (minimum 8 characters)' })
  @IsNotEmpty()
  @MinLength(8)
  password: string;
}
