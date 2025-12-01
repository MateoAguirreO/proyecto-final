import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle('API Clínica')
    .setDescription('Documentación de la API para la gestión clínica')
    .setVersion('1.0')
    .addTag('clinicalrecords')
    .addTag('patients')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // Set global prefix for all routes
  app.setGlobalPrefix('api');
  // Use global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true
  }))

  console.log("Hola antes del listen..");
  await app.listen(process.env.PORT ?? 3000);
  

}
bootstrap();
