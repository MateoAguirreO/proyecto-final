import { Component, OnInit } from "@angular/core";
import { GenomicaService } from "../../services/genomica.service";
import { ClinicaService } from "../../services/clinica.service";
import {
  PatientVariantReport,
  GeneticVariant,
  Gene,
} from "../../models/genomica.model";
import { Patient } from "../../models/clinica.model";

@Component({
  selector: "app-reports",
  templateUrl: "./reports.component.html",
  styleUrls: ["./reports.component.css"],
})
export class ReportsComponent implements OnInit {
  reports: PatientVariantReport[] = [];
  patients: Patient[] = [];
  variants: GeneticVariant[] = [];
  genes: Gene[] = [];
  loading = false;
  showForm = false;
  showVariantForm = false;
  selectedPatientId = "";

  reportForm: Partial<PatientVariantReport> = {
    variant: "",
    detection_date: "",
    allele_frequency: 0,
    sample_type: "",
    notes: "",
  };

  variantForm: any = {
    gene: "",
    chromosome: "",
    position: null,
    reference_base: "",
    alternate_base: "",
    impact: "",
    clinical_significance: "",
  };

  constructor(
    private genomicaService: GenomicaService,
    private clinicaService: ClinicaService
  ) {}

  ngOnInit(): void {
    this.loadReports();
    this.loadPatients();
    this.loadVariants();
    this.loadGenes();
  }

  loadReports(): void {
    this.loading = true;
    this.genomicaService.getPatientReports().subscribe({
      next: (data) => {
        this.reports = data;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      },
    });
  }

  loadPatients(): void {
    this.clinicaService.getPatients().subscribe({
      next: (data) => {
        this.patients = data;
      },
    });
  }

  loadVariants(): void {
    this.genomicaService.getVariants().subscribe({
      next: (data) => {
        this.variants = data;
      },
    });
  }

  loadGenes(): void {
    this.genomicaService.getGenes().subscribe({
      next: (data) => {
        this.genes = data;
      },
    });
  }

  toggleForm(): void {
    this.showForm = !this.showForm;
    if (!this.showForm) {
      this.resetForm();
      this.showVariantForm = false;
    }
  }

  toggleVariantForm(): void {
    this.showVariantForm = !this.showVariantForm;
    if (!this.showVariantForm) {
      this.resetVariantForm();
    }
  }

  resetVariantForm(): void {
    this.variantForm = {
      gene: "",
      chromosome: "",
      position: null,
      reference_base: "",
      alternate_base: "",
      impact: "",
      clinical_significance: "",
    };
  }

  resetForm(): void {
    this.selectedPatientId = "";
    this.reportForm = {
      variant: "",
      detection_date: "",
      allele_frequency: 0,
      sample_type: "",
      notes: "",
    };
  }

  onSubmit(): void {
    const payload = {
      ...this.reportForm,
      patient_id: this.selectedPatientId,
    };
    this.genomicaService.createPatientReport(payload).subscribe({
      next: () => {
        this.loadReports();
        this.toggleForm();
      },
      error: (error) => {
        alert(
          "Error al crear reporte: " +
            (error.error?.message || "Error desconocido")
        );
      },
    });
  }

  createVariant(): void {
    this.genomicaService.createVariant(this.variantForm).subscribe({
      next: (newVariant) => {
        this.loadVariants();
        this.reportForm.variant = newVariant.id;
        this.toggleVariantForm();
        alert("Variante creada exitosamente");
      },
      error: (error) => {
        alert(
          "Error al crear variante: " +
            (error.error?.message || "Error desconocido")
        );
      },
    });
  }

  getPatientName(patientId: string): string {
    const patient = this.patients.find((p) => p._id === patientId);
    return patient?.name || patientId;
  }
}
