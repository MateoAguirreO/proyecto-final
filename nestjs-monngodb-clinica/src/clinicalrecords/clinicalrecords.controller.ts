import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { ClinicalrecordsService } from './clinicalrecords.service';
import { CreateClinicalrecordDto } from './dto/create-clinicalrecord.dto';
import { UpdateClinicalrecordDto } from './dto/update-clinicalrecord.dto';

@Controller('clinicalrecords')
export class ClinicalrecordsController {
  constructor(private readonly clinicalrecordsService: ClinicalrecordsService) {}

  @Post()
  create(@Body() createClinicalrecordDto: CreateClinicalrecordDto) {
    return this.clinicalrecordsService.create(createClinicalrecordDto);
  }

  @Get()
  findAll() {
    return this.clinicalrecordsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.clinicalrecordsService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateClinicalrecordDto: UpdateClinicalrecordDto) {
    return this.clinicalrecordsService.update(id, updateClinicalrecordDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.clinicalrecordsService.remove(id);
  }
}
