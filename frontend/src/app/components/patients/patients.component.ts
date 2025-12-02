import { Component, OnInit } from "@angular/core";
import { ClinicaService } from "../../services/clinica.service";
import { Patient } from "../../models/clinica.model";

@Component({
  selector: "app-patients",
  templateUrl: "./patients.component.html",
  styleUrls: ["./patients.component.css"],
})
export class PatientsComponent implements OnInit {
  patients: Patient[] = [];
  loading = false;
  showForm = false;
  editingId: string | null = null;

  patientForm: Partial<Patient> = {
    name: "",
    dateOfBirth: "",
    gender: "",
    status: "Active",
  };

  constructor(private clinicaService: ClinicaService) {}

  ngOnInit(): void {
    this.loadPatients();
  }

  loadPatients(): void {
    this.loading = true;
    this.clinicaService.getPatients().subscribe({
      next: (data) => {
        this.patients = data;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      },
    });
  }

  toggleForm(): void {
    this.showForm = !this.showForm;
    if (!this.showForm) {
      this.resetForm();
    }
  }

  resetForm(): void {
    this.patientForm = {
      name: "",
      dateOfBirth: "",
      gender: "",
      status: "Active",
    };
    this.editingId = null;
  }

  onSubmit(): void {
    if (this.editingId) {
      this.clinicaService
        .updatePatient(this.editingId, this.patientForm)
        .subscribe({
          next: () => {
            this.loadPatients();
            this.toggleForm();
          },
        });
    } else {
      this.clinicaService.createPatient(this.patientForm).subscribe({
        next: () => {
          this.loadPatients();
          this.toggleForm();
        },
      });
    }
  }

  editPatient(patient: Patient): void {
    this.editingId = patient._id;
    this.patientForm = {
      name: patient.name || "",
      gender: patient.gender || "",
      status: patient.status || "Active",
    };
    this.showForm = true;
  }

  deletePatient(id: string): void {
    if (confirm("¿Está seguro de eliminar este paciente?")) {
      this.clinicaService.deletePatient(id).subscribe({
        next: () => {
          this.loadPatients();
        },
      });
    }
  }
}
