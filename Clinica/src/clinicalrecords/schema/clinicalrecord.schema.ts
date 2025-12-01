import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument } from "mongoose";

export type ClinicalRecordSchema = HydratedDocument<ClinicalRecord>;

@Schema()
export class ClinicalRecord {
    @Prop()
    patientid:string
    
    @Prop()
    tumortypeid:string

    @Prop()
    diagnosisdate:string

    @Prop()
    treatmentprotocol:string
    
}

export const ClinicalRecordSchema = SchemaFactory.createForClass(ClinicalRecord);