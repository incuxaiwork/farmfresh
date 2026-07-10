import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import configuration from './config/configuration';
import { configValidationSchema } from './config/validation.schema';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './auth/auth.module';
import { CategoriesModule } from './categories/categories.module';
import { ProductsModule } from './products/products.module';
import { InventoryModule } from './inventory/inventory.module';
import { CartModule } from './cart/cart.module';
import { OrdersModule } from './orders/orders.module';
import { DeliveryModule } from './delivery/delivery.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    // Global environment variables profile config loading
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: configValidationSchema,
    }),
    
    // API Rate-limiting configuration
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => [
        {
          ttl: config.get<number>('rateLimit.ttl') || 60,
          limit: config.get<number>('rateLimit.limit') || 100,
        },
      ],
    }),

    DatabaseModule,
    AuthModule,
    CategoriesModule,
    ProductsModule,
    InventoryModule,
    CartModule,
    OrdersModule,
    DeliveryModule,
    HealthModule,
  ],
  providers: [
    // Wire up global API Throttler limiter
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
