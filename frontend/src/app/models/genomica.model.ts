export interface Gene {
  id: number | string;
  symbol: string;
  full_name: string;
  function_summary?: string;
  created_at?: string;
  updated_at?: string;
}

export interface GeneticVariant {
  id: string;
  gene_info: Gene;
  chromosome: string;
  position: number;
  reference_base: string;
  alternate_base: string;
  impact: string;
  clinical_significance?: string;
  created_at?: string;
  updated_at?: string;
}

export interface PatientVariantReport {
  id: string;
  patient_id: string;
  variant: string;
  detection_date: string;
  allele_frequency: number;
  sample_type?: string;
  notes?: string;
  variant_info?: GeneticVariant;
}
