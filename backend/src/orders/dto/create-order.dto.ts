import { IsNotEmpty, IsString, IsOptional, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateOrderDto {
  @ApiProperty({ example: '123 Santorini Road, Greece', description: 'Detailed shipping delivery address' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(255)
  address: string;

  @ApiProperty({ example: 'Please leave package near the garage entrance door', description: 'Additional instructions for delivery driver', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  notes?: string;
}
