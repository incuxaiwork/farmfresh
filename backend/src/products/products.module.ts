import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { FarmerProductsController } from './farmer-products.controller';

@Module({
  controllers: [ProductsController, FarmerProductsController],
  providers: [ProductsService],
  exports: [ProductsService],
})
export class ProductsModule {}
