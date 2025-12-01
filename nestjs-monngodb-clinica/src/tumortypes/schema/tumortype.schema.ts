import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { HydratedDocument } from "mongoose";


export type TumortypeSchema = HydratedDocument<Tumortype>;

export @Schema()
class Tumortype {
    @Prop()
    tumorName: string;
    @Prop()
    systemAffected: string
}
export const TumortypeSchema = SchemaFactory.createForClass(Tumortype);