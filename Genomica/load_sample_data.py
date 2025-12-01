"""Script para cargar datos de ejemplo"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'genomica_service.settings')
django.setup()

from genomics.models import Gene, GeneticVariant, PatientVariantReport
from datetime import date
from decimal import Decimal
import uuid

print("🧬 Cargando datos de ejemplo...")

# Crear genes
genes_data = [
    {'symbol': 'BRCA1', 'full_name': 'Breast Cancer Type 1', 'function_summary': 'Gen supresor de tumores asociado con cáncer de mama'},
    {'symbol': 'TP53', 'full_name': 'Tumor Protein P53', 'function_summary': 'Guardián del genoma, regula ciclo celular'},
    {'symbol': 'KRAS', 'full_name': 'KRAS Proto-Oncogene', 'function_summary': 'Proto-oncogen en vías de señalización'}
]

genes = {}
for gdata in genes_data:
    gene, created = Gene.objects.get_or_create(symbol=gdata['symbol'], defaults=gdata)
    genes[gdata['symbol']] = gene
    print(f"  ✓ Gen: {gene.symbol}")

# Crear variantes
variant1 = GeneticVariant.objects.create(
    gene=genes['BRCA1'],
    chromosome='chr17',
    position=43044295,
    reference_base='C',
    alternate_base='T',
    impact='MISSENSE',
    clinical_significance='Patogénica'
)
print(f"  ✓ Variante: {variant1}")

variant2 = GeneticVariant.objects.create(
    gene=genes['TP53'],
    chromosome='chr17',
    position=7676154,
    reference_base='G',
    alternate_base='T',
    impact='MISSENSE',
    clinical_significance='Hotspot oncogénico'
)
print(f"  ✓ Variante: {variant2}")

# Crear reportes
patient_id = uuid.UUID('550e8400-e29b-41d4-a716-446655440001')
report1 = PatientVariantReport.objects.create(
    patient_id=patient_id,
    variant=variant1,
    detection_date=date(2024, 1, 15),
    allele_frequency=Decimal('0.4523'),
    sample_type='Tejido tumoral'
)
print(f"  ✓ Reporte: {report1}")

print(f"\n✅ Datos cargados exitosamente!")
print(f"   - Genes: {Gene.objects.count()}")
print(f"   - Variantes: {GeneticVariant.objects.count()}")
print(f"   - Reportes: {PatientVariantReport.objects.count()}")
