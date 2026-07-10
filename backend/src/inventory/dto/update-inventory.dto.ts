import { IsOptional, IsNumber, Min, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateInventoryDto {
  @ApiProperty({ example: 5.0, description: 'Minimum stock alert threshold limit', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0.00)
  minStockLevel?: number;

  @ApiProperty({ example: 1000.0, description: 'Maximum storage limit for stock', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0.00)
  maxStockLevel?: number;

  @ApiProperty({ example: 10.0, description: 'Auto-reorder alert trigger count', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0.00)
  reorderLevel?: number;

  @ApiProperty({ example: 'IN_STOCK', enum: ['IN_STOCK', 'LOW_STOCK', 'OUT_OF_STOCK', 'DISCONTINUED'], required: false })
  @IsOptional()
  @IsEnum(['IN_STOCK', 'LOW_STOCK', 'OUT_OF_STOCK', 'DISCONTINUED'])
  status?: 'IN_STOCK' | 'LOW_STOCK' | 'OUT_OF_STOCK' | 'DISCONTINUED';
}
