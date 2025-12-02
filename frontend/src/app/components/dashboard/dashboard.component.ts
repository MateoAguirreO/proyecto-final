import { Component, OnInit } from "@angular/core";
import { ClinicaService } from "../../services/clinica.service";
import { GenomicaService } from "../../services/genomica.service";
import { AuthService } from "../../services/auth.service";

@Component({
  selector: "app-dashboard",
  templateUrl: "./dashboard.component.html",
  styleUrls: ["./dashboard.component.css"],
})
export class DashboardComponent implements OnInit {
  stats = {
    patients: 0,
    variants: 0,
    reports: 0,
  };
  loading = true;
  username = "";

  constructor(
    private clinicaService: ClinicaService,
    private genomicaService: GenomicaService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.username = this.authService.currentUserValue?.username || "";
    this.loadStats();
  }

  loadStats(): void {
    this.loading = true;

    this.clinicaService.getPatients().subscribe({
      next: (patients) => {
        this.stats.patients = patients.length;
      },
    });

    this.genomicaService.getVariants().subscribe({
      next: (variants) => {
        this.stats.variants = variants.length;
      },
    });

    this.genomicaService.getPatientReports().subscribe({
      next: (reports) => {
        this.stats.reports = reports.length;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      },
    });
  }
}
