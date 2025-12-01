import { PartialType } from '@nestjs/swagger';
import { CreateTumortypeDto } from './create-tumortype.dto';

export class UpdateTumortypeDto extends PartialType(CreateTumortypeDto) {}
