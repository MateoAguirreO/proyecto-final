import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";
import { environment } from "../../environments/environment";
import {
  Gene,
  GeneticVariant,
  PatientVariantReport,
} from "../models/genomica.model";

@Injectable({
  providedIn: "root",
})
export class GenomicaService {
  private baseUrl = `${environment.apiUrl}/genomica/v1`;

  constructor(private http: HttpClient) {}

  // Genes
  getGenes(): Observable<Gene[]> {
    return this.http.get<any>(`${this.baseUrl}/genes/`).pipe(
      map((response) => {
        // Handle paginated response
        if (response && response.results) {
          return response.results;
        }
        return Array.isArray(response) ? response : [];
      })
    );
  }

  getGene(id: string): Observable<Gene> {
    return this.http.get<Gene>(`${this.baseUrl}/genes/${id}/`);
  }

  // Genetic Variants
  getVariants(): Observable<GeneticVariant[]> {
    return this.http.get<any>(`${this.baseUrl}/variants/`).pipe(
      map((response) => {
        // Handle paginated response
        if (response && response.results) {
          return response.results;
        }
        return Array.isArray(response) ? response : [];
      })
    );
  }

  getVariant(id: string): Observable<GeneticVariant> {
    return this.http.get<GeneticVariant>(`${this.baseUrl}/variants/${id}/`);
  }

  // Patient Variant Reports
  getPatientReports(): Observable<PatientVariantReport[]> {
    return this.http.get<any>(`${this.baseUrl}/patient-reports/`).pipe(
      map((response) => {
        // Handle paginated response
        if (response && response.results) {
          return response.results;
        }
        return Array.isArray(response) ? response : [];
      })
    );
  }

  getPatientReport(id: string): Observable<PatientVariantReport> {
    return this.http.get<PatientVariantReport>(
      `${this.baseUrl}/patient-reports/${id}/`
    );
  }

  createPatientReport(
    report: Partial<PatientVariantReport>
  ): Observable<PatientVariantReport> {
    return this.http.post<PatientVariantReport>(
      `${this.baseUrl}/patient-reports/`,
      report
    );
  }
}
