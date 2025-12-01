import { Injectable } from '@nestjs/common';
import { CreateTumortypeDto } from './dto/create-tumortype.dto';
import { UpdateTumortypeDto } from './dto/update-tumortype.dto';
import { Tumortype } from './schema/tumortype.schema';
import { Model } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class TumortypesService {
  constructor(
    @InjectModel(Tumortype.name) private tumortypeModel: Model<Tumortype>
  ) {}

  async create(dto3: CreateTumortypeDto) {
    const created = new this.tumortypeModel(dto3);
    return created.save();
  }

  findAll() {
    return this.tumortypeModel.find().exec();
  }

  findOne(id: string) {
    return this.tumortypeModel.findById(id).exec();
  }

  update(id: string, updateTumortypeDto: UpdateTumortypeDto) {
    return this.tumortypeModel.findByIdAndUpdate(id, updateTumortypeDto,{new:true}).exec();
  }

  remove(id: string) {
    return this.tumortypeModel.findByIdAndDelete(id).exec();
  }
}
