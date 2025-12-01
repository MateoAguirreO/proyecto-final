import { Module } from '@nestjs/common';
import { ClinicalrecordsService } from './clinicalrecords.service';
import { ClinicalrecordsController } from './clinicalrecords.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { ClinicalRecord, ClinicalRecordSchema } from './schema/clinicalrecord.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: ClinicalRecord.name, schema: ClinicalRecordSchema }]) ],
  controllers: [ClinicalrecordsController],
  providers: [ClinicalrecordsService],
})
export class ClinicalrecordsModule {}
