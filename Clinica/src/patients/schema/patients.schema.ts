import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument } from "mongoose";

export type PatientSchema = HydratedDocument<Patient>;

export @Schema()
class Patient {
    @Prop()
    firstName: string;
    @Prop()
    lastName: string;
    @Prop()
    dateOfBirth: string;
    @Prop()
    gender: string;
    @Prop()
    status: string
}
export const PatientSchema = SchemaFactory.createForClass(Patient);