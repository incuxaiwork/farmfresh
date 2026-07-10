import { IsNotEmpty, IsUUID, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddCartItemDto {
  @ApiProperty({ example: 'uuid-product-id', description: 'Product identifier' })
  @IsNotEmpty()
  @IsUUID()
  productId: string;

  @ApiProperty({ example: 2, description: 'Quantity of items to purchase (must be at least 1)' })
  @IsNotEmpty()
  @IsInt()
  @Min(1, { message: 'Quantity must be at least 1' })
  quantity: number;
}
