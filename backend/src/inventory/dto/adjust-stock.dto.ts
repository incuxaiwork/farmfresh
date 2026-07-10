import { IsNotEmpty, IsNumber, Min, IsString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AdjustStockDto {
  @ApiProperty({ example: 25.5, description: 'Stock quantity amount to adjust (must be greater than zero)' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0.01, { message: 'Quantity must be greater than zero' })
  quantity: number;

  @ApiProperty({ example: 'Weekly harvest inventory replenishment', description: 'Auditable explanation for inventory update' })
  @IsNotEmpty()
  @IsString()
  @MaxLength(255)
  reason: string;
}
