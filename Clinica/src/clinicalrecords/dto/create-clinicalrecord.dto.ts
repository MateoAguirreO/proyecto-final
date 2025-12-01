import { ApiProperty } from "@nestjs/swagger";
import { IsString, MaxLength } from "class-validator";


export class CreateClinicalrecordDto {
    @ApiProperty()
    @IsString()
    @MaxLength(50)
    patientid: string;
    @ApiProperty()
    @IsString()
    tumortypeid: string;
    @ApiProperty()
    @IsString()
    diagnosisdate: string;
    @ApiProperty()
    @IsString()
    treatmentprotocol: string;


}
