import { Module } from '@nestjs/common';
import { TumortypesService } from './tumortypes.service';
import { TumortypesController } from './tumortypes.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { Tumortype, TumortypeSchema } from './schema/tumortype.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: Tumortype.name, schema: TumortypeSchema }]) ],
  controllers: [TumortypesController],
  providers: [TumortypesService],
})
export class TumortypesModule {}
