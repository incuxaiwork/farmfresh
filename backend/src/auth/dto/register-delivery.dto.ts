import { IsEmail, IsNotEmpty, IsString, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeliveryDto {
  @ApiProperty({ example: 'Amit', description: 'First name' })
  @IsNotEmpty()
  @IsString()
  firstName: string;

  @ApiProperty({ example: 'Rider', description: 'Last name' })
  @IsNotEmpty()
  @IsString()
  lastName: string;

  @ApiProperty({ example: 'delivery@farmfresh.com', description: 'Email address' })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({ example: '+1234567892', description: 'Contact phone number' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+?[1-9]\d{1,14}$/, { message: 'Phone must be a valid E.164 phone number format' })
  phone: string;

  @ApiProperty({ example: 'password123', description: 'Account password (minimum 8 characters)' })
  @IsNotEmpty()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'DL-US-9988231', description: 'Rider Driving License ID' })
  @IsNotEmpty()
  @IsString()
  drivingLicenseNumber: string;

  @ApiProperty({ example: 'Two-Wheeler', description: 'Type of transport vehicle' })
  @IsNotEmpty()
  @IsString()
  vehicleType: string;

  @ApiProperty({ example: 'NY-882-AB', description: 'License plate number of vehicle' })
  @IsNotEmpty()
  @IsString()
  vehicleNumber: string;
}
