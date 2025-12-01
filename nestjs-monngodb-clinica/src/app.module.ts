import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { PatientsModule } from './patients/patients.module';
import { ClinicalrecordsModule } from './clinicalrecords/clinicalrecords.module';
import { TumortypesModule } from './tumortypes/tumortypes.module';

@Module({
  imports: [
    MongooseModule.forRoot('mongodb+srv://admin:12345@cluster0.6diwgas.mongodb.net/?appName=Cluster0'),
    ClinicalrecordsModule,
    PatientsModule,
    TumortypesModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
