import { ApiProperty } from "@nestjs/swagger";
import { IsString, MaxLength } from "class-validator";

export class CreatePatientDto {
    @ApiProperty()
    @IsString()
    @MaxLength(50)
    firstName: string;
    @ApiProperty()
    @IsString()
    lastName: string;
    @ApiProperty()
    @IsString()
    dateOfBirth: string;
    @ApiProperty()
    @IsString()
    gender: string;
    @ApiProperty()
    @IsString()
    status: string;
}
