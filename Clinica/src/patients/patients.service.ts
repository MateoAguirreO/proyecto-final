import { Injectable } from '@nestjs/common';
import { CreatePatientDto } from './dto/create-patient.dto';
import { UpdatePatientDto } from './dto/update-patient.dto';
import { Patient } from './schema/patients.schema';
import { Model } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class PatientsService {
  constructor(
    @InjectModel(Patient.name) private patientModel: Model<Patient>
  ) {}

  async create(dto2: CreatePatientDto) {
    const created = new this.patientModel(dto2);
    return created.save();
  }

  findAll() {
    return this.patientModel.find().exec();
  }

  findOne(id: string) {
    return this.patientModel.findById(id).exec();
  }

  update(id: string, updatePatientDto: UpdatePatientDto) {
    return this.patientModel.findByIdAndUpdate(id, updatePatientDto,{new:true}).exec();
  }

  remove(id: string) {
    return this.patientModel.findByIdAndDelete(id).exec();
  }
}
