import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { TumortypesService } from './tumortypes.service';
import { CreateTumortypeDto } from './dto/create-tumortype.dto';
import { UpdateTumortypeDto } from './dto/update-tumortype.dto';

@Controller('tumortypes')
export class TumortypesController {
  constructor(private readonly tumortypesService: TumortypesService) {}

  @Post()
  create(@Body() createTumortypeDto: CreateTumortypeDto) {
    return this.tumortypesService.create(createTumortypeDto);
  }

  @Get()
  findAll() {
    return this.tumortypesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.tumortypesService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateTumortypeDto: UpdateTumortypeDto) {
    return this.tumortypesService.update(id, updateTumortypeDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.tumortypesService.remove(id);
  }
}
