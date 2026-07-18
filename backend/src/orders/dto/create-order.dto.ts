import { IsNotEmpty, IsString, IsOptional, MaxLength, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateOrderDto {
  @ApiProperty({ example: '123 Santorini Road, Greece', description: 'Detailed shipping delivery address', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  address?: string;

  @ApiProperty({ example: 16.5062, description: 'Customer delivery latitude', required: false })
  @IsOptional()
  @IsNumber()
  @Min(-90)
  @Max(90)
  customerLatitude?: number;

  @ApiProperty({ example: 80.6480, description: 'Customer delivery longitude', required: false })
  @IsOptional()
  @IsNumber()
  @Min(-180)
  @Max(180)
  customerLongitude?: number;

  @ApiProperty({ example: 'Please leave package near the garage entrance door', description: 'Additional instructions for delivery driver', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  notes?: string;
}
