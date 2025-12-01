from django.contrib import admin
from .models import Gene, GeneticVariant, PatientVariantReport


@admin.register(Gene)
class GeneAdmin(admin.ModelAdmin):
    list_display = ['id', 'symbol', 'full_name', 'created_at']
    search_fields = ['symbol', 'full_name']
    list_filter = ['created_at']
    ordering = ['symbol']


@admin.register(GeneticVariant)
class GeneticVariantAdmin(admin.ModelAdmin):
    list_display = ['id', 'gene', 'chromosome', 'position', 'impact', 'created_at']
    search_fields = ['gene__symbol', 'chromosome']
    list_filter = ['impact', 'chromosome', 'created_at']
    ordering = ['chromosome', 'position']
    autocomplete_fields = ['gene']


@admin.register(PatientVariantReport)
class PatientVariantReportAdmin(admin.ModelAdmin):
    list_display = ['id', 'patient_id', 'variant', 'detection_date', 'allele_frequency']
    search_fields = ['patient_id', 'variant__gene__symbol']
    list_filter = ['detection_date', 'created_at']
    ordering = ['-detection_date']
    autocomplete_fields = ['variant']
