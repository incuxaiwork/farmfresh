import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { DatabaseModule } from './database/database.module';
import { DeliveryModule } from './delivery/delivery.module';
import { FarmerModule } from './farmer/farmer.module';
import { AdminModule } from './admin/admin.module';
import { OrdersModule } from './orders/orders.module';
import { UploadModule } from './upload/upload.module';
import { UserRepository } from './user/user.repository';
import { CloudinaryService } from './common/services/cloudinary.service';

@Module({
  imports: [
    AuthModule,
    DatabaseModule,
    DeliveryModule,
    FarmerModule,
    AdminModule,
    OrdersModule,
    UploadModule,
  ],
  controllers: [AppController],
  providers: [AppService, UserRepository, CloudinaryService],
})
export class AppModule {}