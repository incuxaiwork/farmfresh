import { Module } from '@nestjs/common';
import { DeliveryService } from './delivery.service';
import { DeliveryController } from './delivery.controller';
import { DeliveryGateway } from './delivery.gateway';

@Module({
  controllers: [DeliveryController],
  providers: [DeliveryService, DeliveryGateway],
  exports: [DeliveryService, DeliveryGateway],
})
export class DeliveryModule {}
