import uuid
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class Gene(models.Model):
    """
    Modelo para catálogo de genes relevantes en oncología.
    """
    id = models.AutoField(primary_key=True)
    symbol = models.CharField(
        max_length=50,
        unique=True,
        help_text="Símbolo del gen (ej: BRCA1, TP53)"
    )
    full_name = models.CharField(
        max_length=255,
        help_text="Nombre completo del gen"
    )
    function_summary = models.TextField(
        help_text="Resumen de la función del gen en oncología"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'genes'
        ordering = ['symbol']
        verbose_name = 'Gen de Interés'
        verbose_name_plural = 'Genes de Interés'

    def __str__(self):
        return f"{self.symbol} - {self.full_name}"


class GeneticVariant(models.Model):
    """
    Modelo para registro de mutaciones genéticas específicas.
    """
    IMPACT_CHOICES = [
        ('MISSENSE', 'Missense'),
        ('NONSENSE', 'Nonsense'),
        ('FRAMESHIFT', 'Frameshift'),
        ('SILENT', 'Silent'),
        ('SPLICE_SITE', 'Splice Site'),
        ('INFRAME_INSERTION', 'Inframe Insertion'),
        ('INFRAME_DELETION', 'Inframe Deletion'),
        ('OTHER', 'Other'),
    ]

    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    gene = models.ForeignKey(
        Gene,
        on_delete=models.PROTECT,
        related_name='variants',
        help_text="Gen asociado a esta variante"
    )
    chromosome = models.CharField(
        max_length=10,
        help_text="Cromosoma (ej: chr17, chrX)"
    )
    position = models.PositiveIntegerField(
        help_text="Posición en el cromosoma"
    )
    reference_base = models.CharField(
        max_length=100,
        help_text="Base(s) de referencia (ej: A, ATG)"
    )
    alternate_base = models.CharField(
        max_length=100,
        help_text="Base(s) alternativa(s) (ej: G, T)"
    )
    impact = models.CharField(
        max_length=50,
        choices=IMPACT_CHOICES,
        help_text="Tipo de impacto de la mutación"
    )
    clinical_significance = models.TextField(
        blank=True,
        null=True,
        help_text="Significancia clínica de la variante"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'genetic_variants'
        ordering = ['chromosome', 'position']
        verbose_name = 'Variante Genética'
        verbose_name_plural = 'Variantes Genéticas'
        indexes = [
            models.Index(fields=['chromosome', 'position']),
            models.Index(fields=['gene']),
        ]

    def __str__(self):
        return f"{self.gene.symbol} - {self.chromosome}:{self.position} {self.reference_base}>{self.alternate_base}"


class PatientVariantReport(models.Model):
    """
    Modelo para librería de mutaciones encontradas en un paciente.
    Asocia variantes genéticas a pacientes específicos.
    """
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    patient_id = models.UUIDField(
        help_text="ID del paciente (consultable en Microservicio Clínica)"
    )
    variant = models.ForeignKey(
        GeneticVariant,
        on_delete=models.PROTECT,
        related_name='patient_reports',
        help_text="Variante genética detectada"
    )
    detection_date = models.DateField(
        help_text="Fecha de detección de la variante"
    )
    allele_frequency = models.DecimalField(
        max_digits=5,
        decimal_places=4,
        validators=[MinValueValidator(0.0), MaxValueValidator(1.0)],
        help_text="Frecuencia alélica (VAF - Variant Allele Frequency), valor entre 0 y 1"
    )
    sample_type = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        help_text="Tipo de muestra (ej: sangre, tejido tumoral)"
    )
    notes = models.TextField(
        blank=True,
        null=True,
        help_text="Notas adicionales sobre el reporte"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'patient_variant_reports'
        ordering = ['-detection_date']
        verbose_name = 'Reporte de Variante del Paciente'
        verbose_name_plural = 'Reportes de Variantes de Pacientes'
        indexes = [
            models.Index(fields=['patient_id']),
            models.Index(fields=['detection_date']),
        ]

    def __str__(self):
        return f"Reporte {self.id} - Paciente {self.patient_id} - {self.variant.gene.symbol}"
