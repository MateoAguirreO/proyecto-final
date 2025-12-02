import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";
import { environment } from "../../environments/environment";
import { Patient, ClinicalRecord, TumorType } from "../models/clinica.model";

@Injectable({ providedIn: "root" })
export class ClinicaService {
  private baseUrl = `${environment.apiUrl}/clinica`;

  constructor(private http: HttpClient) {}

  // Normalize possible backend shapes to our view model
  private toViewPatient(raw: any): Patient {
    const name =
      raw?.name ??
      raw?.fullName ??
      (raw?.firstName || raw?.lastName
        ? `${raw?.firstName ?? ""} ${raw?.lastName ?? ""}`.trim()
        : undefined) ??
      raw?.nombre ??
      "";

    const age = Number(
      raw?.age ?? raw?.edad ?? raw?.ageInYears ?? raw?.years ?? 0
    );

    const gender = (raw?.gender ?? raw?.genero ?? raw?.sexo ?? "").toString();

    const medicalHistory =
      raw?.medicalHistory ?? raw?.historiaMedica ?? raw?.historia ?? undefined;

    return {
      _id: raw?._id ?? raw?.id ?? raw?.uuid ?? "",
      name,
      age,
      gender,
      medicalHistory,
      status: raw?.status ?? raw?.estado,
      dateOfBirth: raw?.dateOfBirth,
      firstName: raw?.firstName,
      lastName: raw?.lastName,
      createdAt: raw?.createdAt ?? raw?.created_at,
      updatedAt: raw?.updatedAt ?? raw?.updated_at,
    } as Patient;
  }

  // Patients
  getPatients(): Observable<Patient[]> {
    return this.http
      .get<any[]>(`${this.baseUrl}/patients`)
      .pipe(
        map((items) =>
          Array.isArray(items) ? items.map((i) => this.toViewPatient(i)) : []
        )
      );
  }

  getPatient(id: string): Observable<Patient> {
    return this.http
      .get<any>(`${this.baseUrl}/patients/${id}`)
      .pipe(map((raw) => this.toViewPatient(raw)));
  }

  createPatient(patient: Partial<Patient>): Observable<Patient> {
    const payload = this.buildCreatePayload(patient);
    return this.http.post<Patient>(`${this.baseUrl}/patients`, payload);
  }

  updatePatient(id: string, patient: Partial<Patient>): Observable<Patient> {
    const payload = this.buildPatchPayload(patient);
    return this.http.patch<Patient>(`${this.baseUrl}/patients/${id}`, payload);
  }

  deletePatient(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/patients/${id}`);
  }

  // Clinical Records
  getClinicalRecords(): Observable<ClinicalRecord[]> {
    return this.http.get<ClinicalRecord[]>(`${this.baseUrl}/clinicalrecords`);
  }

  getClinicalRecord(id: string): Observable<ClinicalRecord> {
    return this.http.get<ClinicalRecord>(
      `${this.baseUrl}/clinicalrecords/${id}`
    );
  }

  createClinicalRecord(
    record: Partial<ClinicalRecord>
  ): Observable<ClinicalRecord> {
    return this.http.post<ClinicalRecord>(
      `${this.baseUrl}/clinicalrecords`,
      record
    );
  }

  // Tumor Types
  getTumorTypes(): Observable<TumorType[]> {
    return this.http.get<TumorType[]>(`${this.baseUrl}/tumortypes`);
  }

  private buildCreatePayload(view: Partial<Patient>): any {
    // Backend POST DTO: { firstName, lastName, dateOfBirth, gender, status }
    const nameParts = (view.name ?? "").trim().split(/\s+/);
    const candidate: Record<string, any> = {
      firstName: view.firstName ?? nameParts[0] ?? "",
      lastName:
        view.lastName ?? (nameParts.slice(1).join(" ") || nameParts[0] || ""),
      dateOfBirth: view.dateOfBirth ?? "01 Jan 2000",
      gender: view.gender ?? "",
      status: view.status ?? "Active",
    };
    Object.keys(candidate).forEach(
      (k) => candidate[k] === undefined && delete candidate[k]
    );
    return candidate;
  }

  private buildPatchPayload(view: Partial<Patient>): any {
    // Backend PATCH appears to only accept { status }
    const candidate: Record<string, any> = {
      status: view.status ?? undefined,
    };
    Object.keys(candidate).forEach(
      (k) => candidate[k] === undefined && delete candidate[k]
    );
    return candidate;
  }
}
