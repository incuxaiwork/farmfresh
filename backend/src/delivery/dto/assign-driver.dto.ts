import { IsNotEmpty, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AssignDriverDto {
  @ApiProperty({ example: 'uuid-order-id', description: 'Order identifier' })
  @IsNotEmpty()
  @IsUUID()
  orderId: string;

  @ApiProperty({ example: 'uuid-driver-id', description: 'Rider / driver user identifier' })
  @IsNotEmpty()
  @IsUUID()
  driverId: string;
}
