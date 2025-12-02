import { Component, OnInit } from "@angular/core";
import { GenomicaService } from "../../services/genomica.service";
import { GeneticVariant } from "../../models/genomica.model";

@Component({
  selector: "app-variants",
  templateUrl: "./variants.component.html",
  styleUrls: ["./variants.component.css"],
})
export class VariantsComponent implements OnInit {
  variants: GeneticVariant[] = [];
  loading = false;

  constructor(private genomicaService: GenomicaService) {}

  ngOnInit(): void {
    this.loadVariants();
  }

  loadVariants(): void {
    this.loading = true;
    this.genomicaService.getVariants().subscribe({
      next: (data) => {
        this.variants = data;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
      },
    });
  }
}
