import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { OrderPricingService } from './pricing.service';

@Module({
  controllers: [OrdersController],
  providers: [OrdersService, OrderPricingService],
  exports: [OrdersService, OrderPricingService],
})
export class OrdersModule {}
