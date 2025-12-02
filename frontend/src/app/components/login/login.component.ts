import { Component, OnInit } from "@angular/core";
import { Router } from "@angular/router";
import { AuthService } from "../../services/auth.service";
import { LoginRequest } from "../../models/auth.model";

@Component({
  selector: "app-login",
  templateUrl: "./login.component.html",
  styleUrls: ["./login.component.css"],
})
export class LoginComponent implements OnInit {
  credentials: LoginRequest = {
    username: "",
    password: "",
  };
  errorMessage = "";
  loading = false;

  constructor(private authService: AuthService, private router: Router) {}

  ngOnInit(): void {
    if (this.authService.isLoggedIn()) {
      this.router.navigate(["/dashboard"]);
    }
  }

  onSubmit(): void {
    this.loading = true;
    this.errorMessage = "";

    this.authService.login(this.credentials).subscribe({
      next: () => {
        this.router.navigate(["/dashboard"]);
      },
      error: (error) => {
        this.errorMessage = error.error?.message || "Error al iniciar sesión";
        this.loading = false;
      },
    });
  }
}
