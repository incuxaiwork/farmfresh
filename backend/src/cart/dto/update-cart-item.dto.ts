import { IsNotEmpty, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateCartItemDto {
  @ApiProperty({ example: 3, description: 'Updated quantity of items (must be at least 1)' })
  @IsNotEmpty()
  @IsInt()
  @Min(1, { message: 'Quantity must be at least 1' })
  quantity: number;
}
