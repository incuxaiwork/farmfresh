import { IsNotEmpty, IsString, IsOptional, IsBoolean, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAddressDto {
  @ApiProperty({ example: 'Home', description: 'Address label (e.g., Home, Work)' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  label: string;

  @ApiProperty({ example: 'House No. 12, Main Street', description: 'Street address' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(255)
  street: string;

  @ApiProperty({ example: 'Hyderabad', description: 'City name' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  city: string;

  @ApiProperty({ example: 'Telangana', description: 'State name' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  state: string;

  @ApiProperty({ example: '500001', description: '6-digit Indian PIN code / postal code' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(20)
  zipCode: string;

  @ApiProperty({ example: 'India', description: 'Country name', default: 'India', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  country?: string;

  @ApiProperty({ example: '+919876543210', description: 'Contact phone number', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  contactPhone?: string;

  @ApiProperty({ example: false, description: 'Set as default address', default: false, required: false })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;
}
