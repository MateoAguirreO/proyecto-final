from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import GeneViewSet, GeneticVariantViewSet, PatientVariantReportViewSet

# Router para endpoints RESTful
router = DefaultRouter()
router.register(r'genes', GeneViewSet, basename='gene')
router.register(r'variants', GeneticVariantViewSet, basename='genetic-variant')
router.register(r'patient-reports', PatientVariantReportViewSet, basename='patient-variant-report')

urlpatterns = [
    path('', include(router.urls)),
]
