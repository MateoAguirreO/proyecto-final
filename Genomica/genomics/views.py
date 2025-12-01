from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from drf_spectacular.utils import extend_schema, extend_schema_view, OpenApiParameter, OpenApiResponse

from .models import Gene, GeneticVariant, PatientVariantReport
from .serializers import (
    GeneSerializer,
    GeneCreateUpdateSerializer,
    GeneticVariantSerializer,
    GeneticVariantCreateUpdateSerializer,
    PatientVariantReportSerializer,
    PatientVariantReportCreateUpdateSerializer,
    PatientVariantReportListSerializer
)


@extend_schema_view(
    list=extend_schema(
        summary="Listar todos los genes",
        description="Obtiene una lista paginada de todos los genes de interés oncológico catalogados",
        tags=["Genes"]
    ),
    retrieve=extend_schema(
        summary="Obtener un gen específico",
        description="Obtiene los detalles de un gen específico por su ID",
        tags=["Genes"]
    ),
    create=extend_schema(
        summary="Crear un nuevo gen",
        description="Registra un nuevo gen de interés oncológico en el catálogo",
        tags=["Genes"]
    ),
    update=extend_schema(
        summary="Actualizar un gen completo",
        description="Actualiza todos los campos de un gen existente",
        tags=["Genes"]
    ),
    partial_update=extend_schema(
        summary="Actualizar parcialmente un gen",
        description="Actualiza uno o más campos de un gen existente",
        tags=["Genes"]
    ),
    destroy=extend_schema(
        summary="Eliminar un gen",
        description="Elimina un gen del catálogo (solo si no tiene variantes asociadas)",
        tags=["Genes"]
    )
)
class GeneViewSet(viewsets.ModelViewSet):
    """
    ViewSet para gestión de genes de interés oncológico.
    
    Proporciona operaciones CRUD completas para catalogar genes.
    """
    queryset = Gene.objects.all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['symbol', 'full_name', 'function_summary']
    ordering_fields = ['symbol', 'created_at']
    ordering = ['symbol']

    def get_serializer_class(self):
        """Retorna el serializer apropiado según la acción"""
        if self.action in ['create', 'update', 'partial_update']:
            return GeneCreateUpdateSerializer
        return GeneSerializer

    @extend_schema(
        summary="Buscar genes por símbolo",
        description="Busca genes que coincidan con el símbolo proporcionado",
        parameters=[
            OpenApiParameter(
                name='symbol',
                type=str,
                location=OpenApiParameter.QUERY,
                description='Símbolo del gen a buscar (ej: BRCA1)'
            )
        ],
        tags=["Genes"]
    )
    @action(detail=False, methods=['get'])
    def search_by_symbol(self, request):
        """Buscar genes por símbolo"""
        symbol = request.query_params.get('symbol', '')
        genes = self.queryset.filter(symbol__icontains=symbol)
        serializer = self.get_serializer(genes, many=True)
        return Response(serializer.data)


@extend_schema_view(
    list=extend_schema(
        summary="Listar todas las variantes genéticas",
        description="Obtiene una lista paginada de todas las variantes genéticas registradas",
        tags=["Variantes Genéticas"]
    ),
    retrieve=extend_schema(
        summary="Obtener una variante genética específica",
        description="Obtiene los detalles de una variante genética por su UUID",
        tags=["Variantes Genéticas"]
    ),
    create=extend_schema(
        summary="Crear una nueva variante genética",
        description="Registra una nueva mutación genética en el sistema",
        tags=["Variantes Genéticas"]
    ),
    update=extend_schema(
        summary="Actualizar una variante genética completa",
        description="Actualiza todos los campos de una variante genética existente",
        tags=["Variantes Genéticas"]
    ),
    partial_update=extend_schema(
        summary="Actualizar parcialmente una variante genética",
        description="Actualiza uno o más campos de una variante genética existente",
        tags=["Variantes Genéticas"]
    ),
    destroy=extend_schema(
        summary="Eliminar una variante genética",
        description="Elimina una variante genética del sistema",
        tags=["Variantes Genéticas"]
    )
)
class GeneticVariantViewSet(viewsets.ModelViewSet):
    """
    ViewSet para gestión de variantes genéticas.
    
    Proporciona operaciones CRUD para registrar mutaciones específicas.
    """
    queryset = GeneticVariant.objects.select_related('gene').all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['gene', 'chromosome', 'impact']
    search_fields = ['gene__symbol', 'chromosome', 'clinical_significance']
    ordering_fields = ['chromosome', 'position', 'created_at']
    ordering = ['chromosome', 'position']

    def get_serializer_class(self):
        """Retorna el serializer apropiado según la acción"""
        if self.action in ['create', 'update', 'partial_update']:
            return GeneticVariantCreateUpdateSerializer
        return GeneticVariantSerializer

    @extend_schema(
        summary="Obtener variantes por gen",
        description="Lista todas las variantes asociadas a un gen específico",
        parameters=[
            OpenApiParameter(
                name='gene_id',
                type=int,
                location=OpenApiParameter.QUERY,
                description='ID del gen',
                required=True
            )
        ],
        tags=["Variantes Genéticas"]
    )
    @action(detail=False, methods=['get'])
    def by_gene(self, request):
        """Obtener variantes por gen"""
        gene_id = request.query_params.get('gene_id')
        if not gene_id:
            return Response(
                {'error': 'Se requiere el parámetro gene_id'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        variants = self.queryset.filter(gene_id=gene_id)
        serializer = self.get_serializer(variants, many=True)
        return Response(serializer.data)

    @extend_schema(
        summary="Obtener variantes por cromosoma",
        description="Lista todas las variantes de un cromosoma específico",
        parameters=[
            OpenApiParameter(
                name='chromosome',
                type=str,
                location=OpenApiParameter.QUERY,
                description='Nombre del cromosoma (ej: chr17)',
                required=True
            )
        ],
        tags=["Variantes Genéticas"]
    )
    @action(detail=False, methods=['get'])
    def by_chromosome(self, request):
        """Obtener variantes por cromosoma"""
        chromosome = request.query_params.get('chromosome')
        if not chromosome:
            return Response(
                {'error': 'Se requiere el parámetro chromosome'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        variants = self.queryset.filter(chromosome=chromosome)
        serializer = self.get_serializer(variants, many=True)
        return Response(serializer.data)


@extend_schema_view(
    list=extend_schema(
        summary="Listar todos los reportes de variantes",
        description="Obtiene una lista paginada de todos los reportes de variantes de pacientes",
        tags=["Reportes de Pacientes"]
    ),
    retrieve=extend_schema(
        summary="Obtener un reporte específico",
        description="Obtiene los detalles de un reporte de variante por su UUID",
        tags=["Reportes de Pacientes"]
    ),
    create=extend_schema(
        summary="Crear un nuevo reporte de variante",
        description="Registra una nueva variante detectada en un paciente",
        tags=["Reportes de Pacientes"]
    ),
    update=extend_schema(
        summary="Actualizar un reporte completo",
        description="Actualiza todos los campos de un reporte existente",
        tags=["Reportes de Pacientes"]
    ),
    partial_update=extend_schema(
        summary="Actualizar parcialmente un reporte",
        description="Actualiza uno o más campos de un reporte existente",
        tags=["Reportes de Pacientes"]
    ),
    destroy=extend_schema(
        summary="Eliminar un reporte",
        description="Elimina un reporte de variante del sistema",
        tags=["Reportes de Pacientes"]
    )
)
class PatientVariantReportViewSet(viewsets.ModelViewSet):
    """
    ViewSet para gestión de reportes de variantes de pacientes.
    
    Asocia variantes genéticas a pacientes específicos y gestiona
    la librería de mutaciones encontradas.
    """
    queryset = PatientVariantReport.objects.select_related(
        'variant', 'variant__gene'
    ).all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['patient_id', 'variant', 'detection_date']
    search_fields = ['variant__gene__symbol', 'notes']
    ordering_fields = ['detection_date', 'allele_frequency', 'created_at']
    ordering = ['-detection_date']

    def get_serializer_class(self):
        """Retorna el serializer apropiado según la acción"""
        if self.action in ['create', 'update', 'partial_update']:
            return PatientVariantReportCreateUpdateSerializer
        elif self.action == 'by_patient':
            return PatientVariantReportListSerializer
        return PatientVariantReportSerializer

    @extend_schema(
        summary="Obtener reportes por paciente",
        description="Lista todos los reportes de variantes de un paciente específico",
        parameters=[
            OpenApiParameter(
                name='patient_id',
                type=str,
                location=OpenApiParameter.QUERY,
                description='UUID del paciente',
                required=True
            )
        ],
        responses={
            200: PatientVariantReportListSerializer(many=True),
            400: OpenApiResponse(description='Parámetro patient_id requerido')
        },
        tags=["Reportes de Pacientes"]
    )
    @action(detail=False, methods=['get'])
    def by_patient(self, request):
        """
        Obtener todos los reportes de variantes de un paciente.
        Endpoint principal para consultar las mutaciones de un paciente.
        """
        patient_id = request.query_params.get('patient_id')
        if not patient_id:
            return Response(
                {'error': 'Se requiere el parámetro patient_id'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        reports = self.queryset.filter(patient_id=patient_id)
        serializer = self.get_serializer(reports, many=True)
        return Response(serializer.data)

    @extend_schema(
        summary="Estadísticas de variantes por paciente",
        description="Obtiene estadísticas resumidas de las variantes de un paciente",
        parameters=[
            OpenApiParameter(
                name='patient_id',
                type=str,
                location=OpenApiParameter.QUERY,
                description='UUID del paciente',
                required=True
            )
        ],
        tags=["Reportes de Pacientes"]
    )
    @action(detail=False, methods=['get'])
    def patient_statistics(self, request):
        """Obtener estadísticas de variantes por paciente"""
        patient_id = request.query_params.get('patient_id')
        if not patient_id:
            return Response(
                {'error': 'Se requiere el parámetro patient_id'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        reports = self.queryset.filter(patient_id=patient_id)
        
        stats = {
            'patient_id': patient_id,
            'total_variants': reports.count(),
            'variants_by_impact': {},
            'genes_affected': list(
                reports.values_list('variant__gene__symbol', flat=True).distinct()
            ),
            'latest_detection_date': reports.first().detection_date if reports.exists() else None
        }
        
        # Contar por tipo de impacto
        for report in reports:
            impact = report.variant.impact
            stats['variants_by_impact'][impact] = stats['variants_by_impact'].get(impact, 0) + 1
        
        return Response(stats)
