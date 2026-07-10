import { Module } from '@nestjs/common';
import { CartService } from './cart.service';
import { CartController } from './cart.controller';
import { PricingService } from './pricing.service';

@Module({
  controllers: [CartController],
  providers: [CartService, PricingService],
  exports: [CartService, PricingService],
})
export class CartModule {}
