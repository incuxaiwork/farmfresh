import { IsNotEmpty, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateOrderStatusDto {
  @ApiProperty({ example: 'CONFIRMED', enum: ['PENDING', 'CONFIRMED', 'ACCEPTED', 'REJECTED', 'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'COMPLETED'] })
  @IsNotEmpty()
  @IsEnum(['PENDING', 'CONFIRMED', 'ACCEPTED', 'REJECTED', 'PREPARING', 'READY_FOR_PICKUP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED', 'COMPLETED'])
  status: 'PENDING' | 'CONFIRMED' | 'ACCEPTED' | 'REJECTED' | 'PREPARING' | 'READY_FOR_PICKUP' | 'OUT_FOR_DELIVERY' | 'DELIVERED' | 'CANCELLED' | 'COMPLETED';
}
