import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType, Logger } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as helmet from 'helmet';
import * as compression from 'compression';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

async function bootstrap() {
  const logger = new Logger('NestBootstrap');
  const app = await NestFactory.create(AppModule);

  // Apply Config properties
  const config = app.get(ConfigService);
  const port = config.get<number>('port') || 3000;

  // Global Route Prefix & API Versioning
  app.setGlobalPrefix('api');
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // Global Guards & Interceptors
  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalInterceptors(new TransformInterceptor());

  // Global Input Validation Configurations
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Security Middleware - CORS
  const corsOrigins = config.get<string[]>('cors.origins') || ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:8080'];
  app.enableCors({
    origin: (origin, callback) => {
      // Allow non-browser / server-to-server calls (origin is undefined)
      if (!origin) return callback(null, true);
      // Allow explicitly configured origins
      if (corsOrigins.includes(origin)) return callback(null, true);
      // Allow any localhost / 127.0.0.1 origin on any port (covers Flutter web dev server, admin, api)
      if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
        return callback(null, true);
      }
      callback(null, false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
  });
  
  // Security headers
  app.use((helmet.default || helmet)({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", 'data:', 'https:'],
        scriptSrc: ["'self'"],
        connectSrc: ["'self'", 'ws:', 'wss:'],
      },
    },
    crossOriginEmbedderPolicy: false,
  }));
  app.use((compression as any)());

  // Swagger OpenAPI Documentation Initialization
  const swaggerConfig = new DocumentBuilder()
    .setTitle('FarmFresh Multi-Vendor API')
    .setDescription('Production API documentation for the FarmFresh multi-vendor marketplace core platform.')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter your JWT access token below to authorize API calls',
        in: 'header',
      },
      'JWT-auth',
    )
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document);

  // Boot server
  await app.listen(port, '0.0.0.0');
  logger.log(`Server successfully started, listening on http://localhost:${port}/api/v1/`);
  logger.log(`OpenAPI Documentation ready at http://localhost:${port}/api/docs/`);
}

bootstrap();
