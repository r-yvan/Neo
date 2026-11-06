import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module.js';
import { AllExceptionsFilter } from './common/filters/http-exception.filter.js';
import { uploadDir } from './uploads/uploads.controller.js';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const config = app.get(ConfigService);

  const prefix = config.get<string>('API_PREFIX') || 'api/v1';
  app.setGlobalPrefix(prefix);
  app.enableCors({ origin: true, credentials: true });
  // Uploaded images are served publicly (outside the API prefix).
  app.useStaticAssets(uploadDir(), { prefix: '/uploads/', maxAge: '7d' });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());

  const swagger = new DocumentBuilder()
    .setTitle(config.get('APP_NAME') || 'Neo Event Equipment Rental')
    .setDescription(
      'Peer-to-peer event equipment rental API (Rwanda) — NestJS + Prisma + PostgreSQL',
    )
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swagger);
  SwaggerModule.setup('docs', app, document);

  const port = config.get<number>('PORT') || 3000;
  // Bind on all interfaces so emulators and phones on the LAN can connect.
  await app.listen(port, '0.0.0.0');
  console.log(`Neo API running on http://localhost:${port}/${prefix}`);
  console.log(`Swagger docs: http://localhost:${port}/docs`);
}

await bootstrap();
