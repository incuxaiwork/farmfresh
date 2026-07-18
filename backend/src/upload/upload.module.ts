import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { DeliveryModule } from './delivery/delivery.module';
import { FarmerModule } from './farmer/farmer.module';
import { AdminModule } from './admin/admin.module';
import { OrdersModule } from './orders/orders.module';
import { UploadModule } from './upload/upload.module';

@Module({
  imports: [AuthModule, DeliveryModule, FarmerModule, AdminModule, OrdersModule, UploadModule],
  controllers: [],
  providers: [],
})
export class UploadModule {}