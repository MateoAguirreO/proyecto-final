import { PartialType } from '@nestjs/swagger';
import { CreateClinicalrecordDto } from './create-clinicalrecord.dto';

export class UpdateClinicalrecordDto extends PartialType(CreateClinicalrecordDto) {}
