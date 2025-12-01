import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength } from 'class-validator';

export class CreateTumortypeDto {
  @ApiProperty()  
  @IsString()
  @MaxLength(50)
  tumorName: string;

  @ApiProperty()
  @IsString()
  @MaxLength(50)
  systemAffected: string;
}