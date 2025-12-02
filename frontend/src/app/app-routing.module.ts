import { NgModule } from "@angular/core";
import { RouterModule, Routes } from "@angular/router";
import { LoginComponent } from "./components/login/login.component";
import { DashboardComponent } from "./components/dashboard/dashboard.component";
import { PatientsComponent } from "./components/patients/patients.component";
import { VariantsComponent } from "./components/variants/variants.component";
import { ReportsComponent } from "./components/reports/reports.component";
import { AuthGuard } from "./guards/auth.guard";

const routes: Routes = [
  { path: "", redirectTo: "/dashboard", pathMatch: "full" },
  { path: "login", component: LoginComponent },
  {
    path: "dashboard",
    component: DashboardComponent,
    canActivate: [AuthGuard],
  },
  { path: "patients", component: PatientsComponent, canActivate: [AuthGuard] },
  { path: "variants", component: VariantsComponent, canActivate: [AuthGuard] },
  { path: "reports", component: ReportsComponent, canActivate: [AuthGuard] },
  { path: "**", redirectTo: "/dashboard" },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
