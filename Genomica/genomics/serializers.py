from rest_framework import serializers
from .models import Gene, GeneticVariant, PatientVariantReport


class GeneSerializer(serializers.ModelSerializer):
    """
    Serializer (DTO) para el modelo Gene.
    Maneja la transformación y validación de datos de genes.
    """
    class Meta:
        model = Gene
        fields = [
            'id',
            'symbol',
            'full_name',
            'function_summary',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_symbol(self, value):
        """Validar que el símbolo del gen esté en mayúsculas"""
        return value.upper()


class GeneCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer para crear y actualizar genes.
    Excluye campos de solo lectura para operaciones de escritura.
    """
    class Meta:
        model = Gene
        fields = ['symbol', 'full_name', 'function_summary']

    def validate_symbol(self, value):
        """Validar que el símbolo del gen esté en mayúsculas"""
        return value.upper()


class GeneticVariantSerializer(serializers.ModelSerializer):
    """
    Serializer (DTO) para el modelo GeneticVariant.
    Incluye información detallada del gen asociado.
    """
    gene_info = GeneSerializer(source='gene', read_only=True)
    gene_id = serializers.PrimaryKeyRelatedField(
        queryset=Gene.objects.all(),
        source='gene',
        write_only=True
    )

    class Meta:
        model = GeneticVariant
        fields = [
            'id',
            'gene_id',
            'gene_info',
            'chromosome',
            'position',
            'reference_base',
            'alternate_base',
            'impact',
            'clinical_significance',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_chromosome(self, value):
        """Validar formato del cromosoma"""
        if not value.startswith('chr'):
            raise serializers.ValidationError(
                "El cromosoma debe comenzar con 'chr' (ej: chr17, chrX)"
            )
        return value

    def validate_position(self, value):
        """Validar que la posición sea positiva"""
        if value <= 0:
            raise serializers.ValidationError(
                "La posición debe ser un número positivo"
            )
        return value

    def validate(self, data):
        """Validación general del objeto"""
        # Validar que las bases no estén vacías
        if 'reference_base' in data and not data['reference_base'].strip():
            raise serializers.ValidationError({
                'reference_base': 'La base de referencia no puede estar vacía'
            })
        if 'alternate_base' in data and not data['alternate_base'].strip():
            raise serializers.ValidationError({
                'alternate_base': 'La base alternativa no puede estar vacía'
            })
        return data


class GeneticVariantCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer para crear y actualizar variantes genéticas.
    """
    class Meta:
        model = GeneticVariant
        fields = [
            'gene',
            'chromosome',
            'position',
            'reference_base',
            'alternate_base',
            'impact',
            'clinical_significance'
        ]

    def validate_chromosome(self, value):
        """Validar formato del cromosoma"""
        if not value.startswith('chr'):
            raise serializers.ValidationError(
                "El cromosoma debe comenzar con 'chr' (ej: chr17, chrX)"
            )
        return value


class PatientVariantReportSerializer(serializers.ModelSerializer):
    """
    Serializer (DTO) para el modelo PatientVariantReport.
    Incluye información detallada de la variante y el gen.
    """
    variant_info = GeneticVariantSerializer(source='variant', read_only=True)
    variant_id = serializers.PrimaryKeyRelatedField(
        queryset=GeneticVariant.objects.all(),
        source='variant',
        write_only=True
    )

    class Meta:
        model = PatientVariantReport
        fields = [
            'id',
            'patient_id',
            'variant_id',
            'variant_info',
            'detection_date',
            'allele_frequency',
            'sample_type',
            'notes',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_allele_frequency(self, value):
        """Validar que la frecuencia alélica esté entre 0 y 1"""
        if value < 0 or value > 1:
            raise serializers.ValidationError(
                "La frecuencia alélica (VAF) debe estar entre 0 y 1"
            )
        return value

    def validate_patient_id(self, value):
        """Validar formato del UUID del paciente"""
        if not value:
            raise serializers.ValidationError(
                "El ID del paciente es obligatorio"
            )
        return value


class PatientVariantReportCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer para crear y actualizar reportes de variantes de pacientes.
    """
    class Meta:
        model = PatientVariantReport
        fields = [
            'patient_id',
            'variant',
            'detection_date',
            'allele_frequency',
            'sample_type',
            'notes'
        ]

    def validate_allele_frequency(self, value):
        """Validar que la frecuencia alélica esté entre 0 y 1"""
        if value < 0 or value > 1:
            raise serializers.ValidationError(
                "La frecuencia alélica (VAF) debe estar entre 0 y 1"
            )
        return value


class PatientVariantReportListSerializer(serializers.ModelSerializer):
    """
    Serializer simplificado para listar reportes de variantes.
    Usado para consultas de múltiples variantes de un paciente.
    """
    gene_symbol = serializers.CharField(source='variant.gene.symbol', read_only=True)
    gene_name = serializers.CharField(source='variant.gene.full_name', read_only=True)
    chromosome = serializers.CharField(source='variant.chromosome', read_only=True)
    position = serializers.IntegerField(source='variant.position', read_only=True)
    impact = serializers.CharField(source='variant.impact', read_only=True)

    class Meta:
        model = PatientVariantReport
        fields = [
            'id',
            'patient_id',
            'gene_symbol',
            'gene_name',
            'chromosome',
            'position',
            'impact',
            'detection_date',
            'allele_frequency',
            'sample_type'
        ]
