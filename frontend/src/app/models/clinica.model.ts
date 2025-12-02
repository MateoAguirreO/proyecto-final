export interface Patient {
  _id: string;
  name: string;
  age: number;
  gender: string;
  medicalHistory?: string;
  status?: string;
  dateOfBirth?: string;
  firstName?: string;
  lastName?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface ClinicalRecord {
  _id: string;
  patient: string;
  diagnosis: string;
  treatment: string;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface TumorType {
  _id: string;
  name: string;
  description: string;
  prevalence?: number;
}
