import { Injectable } from '@nestjs/common';
import { CreateClinicalrecordDto } from './dto/create-clinicalrecord.dto';
import { UpdateClinicalrecordDto } from './dto/update-clinicalrecord.dto';
import { InjectModel } from '@nestjs/mongoose';
import { ClinicalRecord } from './schema/clinicalrecord.schema';
import { Model } from 'mongoose';

@Injectable()
export class ClinicalrecordsService {
constructor(
@InjectModel(ClinicalRecord.name) private clinicalrecordModel: Model<ClinicalRecord>
){}


  async create(dto: CreateClinicalrecordDto) {
    const created = new this.clinicalrecordModel(dto);
    return created.save();
  }

  findAll() {
    return this.clinicalrecordModel.find().exec();

  }

  findOne(id: string) {
    return this.clinicalrecordModel.findById(id).exec();
  }

  update(id: string, updateClinicalrecordDto: UpdateClinicalrecordDto) {
    return this.clinicalrecordModel.findByIdAndUpdate(id, updateClinicalrecordDto,{new:true}).exec();
  }

  remove(id: string) {
    return this.clinicalrecordModel.findByIdAndDelete(id).exec();
  }
}
