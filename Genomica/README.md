# 🧬 GenoSentinel - Microservicio de Genómica

<div align="center">

![Django](https://img.shields.io/badge/Django-4.2.7-green?logo=django)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![License](https://img.shields.io/badge/License-MIT-yellow)

**Microservicio Django REST para la gestión de información genómica oncológica**

Parte del sistema GenoSentinel de Breaze Labs

</div>

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Instalación](#-instalación)
  - [Opción 1: Docker (Recomendado)](#opción-1-docker-recomendado)
  - [Opción 2: Instalación Local](#opción-2-instalación-local)
- [Modelos de Datos](#-modelos-de-datos)
- [API Endpoints](#-api-endpoints)
- [Documentación](#-documentación)
- [Pruebas](#-pruebas)
- [Despliegue](#-despliegue)

---

## 🎯 Descripción

GenoSentinel es un microservicio especializado en la gestión de información genómica para pacientes oncológicos. Forma parte de una arquitectura de microservicios diseñada para:

### Funcionalidades Principales

1. **📚 Catálogo de Genes**
   - Gestión de genes de interés oncológico
   - Información detallada de función y relevancia clínica
   - Búsqueda y filtrado avanzado

2. **🧪 Variantes Genéticas**
   - Registro de mutaciones somáticas específicas
   - Ubicación cromosómica y efecto molecular
   - Clasificación por impacto clínico

3. **📊 Reportes de Pacientes**
   - Librería de mutaciones detectadas por paciente
   - Frecuencia alélica (VAF) y tipo de muestra
   - Integración con microservicio de Clínica

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Cliente / Frontend                        │
│                     (Angular/React)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          Microservicio de Autenticación (Gateway)            │
│                    Spring Boot + JWT                         │
└──────────────┬─────────────────────┬────────────────────────┘
               │                     │
               ▼                     ▼
    ┌──────────────────┐   ┌──────────────────────┐
    │  Microservicio   │   │   Microservicio      │
    │    Clínica       │◄──┤     Genómica         │
    │   (NestJS)       │   │     (Django)         │
    └────────┬─────────┘   └──────────┬───────────┘
             │                        │
             ▼                        ▼
    ┌─────────────────┐      ┌─────────────────┐
    │   MySQL DB      │      │   MySQL DB      │
    │   (Clínica)     │      │   (Genómica)    │
    └─────────────────┘      └─────────────────┘
```

### Características de la Arquitectura

- **✅ Desacoplamiento**: Cada microservicio es independiente
- **✅ ORM Obligatorio**: Django ORM para todas las operaciones de BD
- **✅ DTOs**: Validación mediante Serializers
- **✅ Documentación**: Swagger/OpenAPI automático
- **✅ Contenedorización**: Docker + Docker Compose
- **✅ Escalabilidad**: Preparado para Kubernetes

---

## 🚀 Tecnologías

| Categoría | Tecnología | Versión |
|-----------|-----------|---------|
| **Framework** | Django | 4.2.7 |
| **API** | Django REST Framework | 3.14.0 |
| **Base de Datos** | MySQL | 8.0 |
| **Documentación** | drf-spectacular | 0.27.0 |
| **CORS** | django-cors-headers | 4.3.1 |
| **Filtros** | django-filter | 23.5 |
| **Contenedores** | Docker + Docker Compose | latest |

---

## 💻 Instalación

### Opción 1: Docker (Recomendado)

**Requisitos:**
- Docker Desktop
- Docker Compose

**Pasos:**

```bash
# 1. Navegar al directorio
cd Genomica

# 2. Levantar los servicios
docker-compose up -d

# 3. Crear migraciones (primera vez)
docker exec genomica_service python manage.py makemigrations genomics
docker exec genomica_service python manage.py migrate

# 4. Cargar datos de ejemplo (opcional)
docker exec genomica_service python load_sample_data.py

# 5. Verificar que esté corriendo
docker ps
```

**URLs disponibles:**
- API: http://localhost:8000/api/v1/
- Swagger: http://localhost:8000/api/docs/
- ReDoc: http://localhost:8000/api/redoc/
- MySQL: localhost:3307

**Detener servicios:**
```bash
docker-compose down
```

**Reiniciar con base de datos limpia:**
```bash
docker-compose down -v
docker-compose up -d
```

---

### Opción 2: Instalación Local

**Requisitos:**
- Python 3.11+
- MySQL 8.0+
- pip

**Pasos:**

```bash
# 1. Crear entorno virtual
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar variables de entorno
copy .env.example .env
# Editar .env con tus credenciales de MySQL

# 4. Crear base de datos en MySQL
mysql -u root -p
CREATE DATABASE genomica_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# 5. Ejecutar migraciones
python manage.py makemigrations genomics
python manage.py migrate

# 6. Cargar datos de ejemplo (opcional)
python load_sample_data.py

# 7. Crear superusuario (opcional)
python manage.py createsuperuser

# 8. Ejecutar servidor
python manage.py runserver
```

---

## 📊 Modelos de Datos

### 1. Gene (Gen de Interés)

Catálogo de genes relevantes en oncología.

```python
class Gene(models.Model):
    id = AutoField(primary_key=True)
    symbol = CharField(max_length=50, unique=True)  # ej: "BRCA1"
    full_name = CharField(max_length=255)
    function_summary = TextField()
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
```

**Ejemplo de datos:**
```json
{
  "id": 1,
  "symbol": "BRCA1",
  "full_name": "Breast Cancer Type 1 Susceptibility Protein",
  "function_summary": "Gen supresor de tumores que participa en la reparación del ADN"
}
```

---

### 2. GeneticVariant (Variante Genética)

Registro de mutaciones genéticas específicas.

```python
class GeneticVariant(models.Model):
    id = UUIDField(primary_key=True, default=uuid.uuid4)
    gene = ForeignKey(Gene, on_delete=PROTECT)
    chromosome = CharField(max_length=10)  # ej: "chr17"
    position = PositiveIntegerField()
    reference_base = CharField(max_length=100)  # ej: "A"
    alternate_base = CharField(max_length=100)  # ej: "G"
    impact = CharField(max_length=50, choices=IMPACT_CHOICES)
    clinical_significance = TextField(blank=True)
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
```

**Tipos de impacto:**
- `MISSENSE` - Cambio de aminoácido
- `NONSENSE` - Codón de parada prematuro
- `FRAMESHIFT` - Cambio en marco de lectura
- `SILENT` - Sin cambio de aminoácido
- `SPLICE_SITE` - Alteración en sitio de splicing
- `INFRAME_INSERTION/DELETION` - Inserción/deleción sin cambio de marco

**Ejemplo de datos:**
```json
{
  "id": "1a75b5a7-9fdb-430d-a575-76ba3e503c64",
  "gene_info": {
    "symbol": "BRCA1",
    "full_name": "Breast Cancer Type 1"
  },
  "chromosome": "chr17",
  "position": 43044295,
  "reference_base": "C",
  "alternate_base": "T",
  "impact": "MISSENSE",
  "clinical_significance": "Variante patogénica"
}
```

---

### 3. PatientVariantReport (Reporte de Variante)

Librería de mutaciones detectadas en pacientes.

```python
class PatientVariantReport(models.Model):
    id = UUIDField(primary_key=True, default=uuid.uuid4)
    patient_id = UUIDField()  # FK al microservicio de Clínica
    variant = ForeignKey(GeneticVariant, on_delete=PROTECT)
    detection_date = DateField()
    allele_frequency = DecimalField(max_digits=5, decimal_places=4)  # VAF: 0-1
    sample_type = CharField(max_length=100, blank=True)
    notes = TextField(blank=True)
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)
```

**Ejemplo de datos:**
```json
{
  "id": "e4cf05a3-d437-49ee-a690-add0757bb935",
  "patient_id": "550e8400-e29b-41d4-a716-446655440001",
  "variant_info": {
    "gene_info": {"symbol": "BRCA1"},
    "chromosome": "chr17",
    "position": 43044295,
    "impact": "MISSENSE"
  },
  "detection_date": "2024-01-15",
  "allele_frequency": "0.4523",
  "sample_type": "Tejido tumoral"
}
```

---

## 🔗 API Endpoints

### Genes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v1/genes/` | Lista paginada de genes |
| `POST` | `/api/v1/genes/` | Crear nuevo gen |
| `GET` | `/api/v1/genes/{id}/` | Detalle de un gen |
| `PUT` | `/api/v1/genes/{id}/` | Actualizar gen completo |
| `PATCH` | `/api/v1/genes/{id}/` | Actualizar gen parcialmente |
| `DELETE` | `/api/v1/genes/{id}/` | Eliminar gen |
| `GET` | `/api/v1/genes/search_by_symbol/?symbol={symbol}` | Buscar por símbolo |

**Ejemplo de petición:**
```bash
curl -X POST http://localhost:8000/api/v1/genes/ \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "TP53",
    "full_name": "Tumor Protein P53",
    "function_summary": "Guardián del genoma"
  }'
```

---

### Variantes Genéticas

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v1/variants/` | Lista paginada de variantes |
| `POST` | `/api/v1/variants/` | Crear nueva variante |
| `GET` | `/api/v1/variants/{uuid}/` | Detalle de una variante |
| `PUT` | `/api/v1/variants/{uuid}/` | Actualizar variante completa |
| `PATCH` | `/api/v1/variants/{uuid}/` | Actualizar variante parcialmente |
| `DELETE` | `/api/v1/variants/{uuid}/` | Eliminar variante |
| `GET` | `/api/v1/variants/by_gene/?gene_id={id}` | Variantes de un gen |
| `GET` | `/api/v1/variants/by_chromosome/?chromosome={chr}` | Variantes por cromosoma |

**Ejemplo de petición:**
```bash
curl -X POST http://localhost:8000/api/v1/variants/ \
  -H "Content-Type: application/json" \
  -d '{
    "gene": 1,
    "chromosome": "chr17",
    "position": 7676154,
    "reference_base": "G",
    "alternate_base": "T",
    "impact": "MISSENSE",
    "clinical_significance": "Hotspot oncogénico"
  }'
```

---

### Reportes de Pacientes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/v1/patient-reports/` | Lista paginada de reportes |
| `POST` | `/api/v1/patient-reports/` | Crear nuevo reporte |
| `GET` | `/api/v1/patient-reports/{uuid}/` | Detalle de un reporte |
| `PUT` | `/api/v1/patient-reports/{uuid}/` | Actualizar reporte completo |
| `PATCH` | `/api/v1/patient-reports/{uuid}/` | Actualizar reporte parcialmente |
| `DELETE` | `/api/v1/patient-reports/{uuid}/` | Eliminar reporte |
| `GET` | `/api/v1/patient-reports/by_patient/?patient_id={uuid}` | Reportes de un paciente |
| `GET` | `/api/v1/patient-reports/patient_statistics/?patient_id={uuid}` | Estadísticas del paciente |

**Ejemplo de consulta por paciente:**
```bash
curl http://localhost:8000/api/v1/patient-reports/by_patient/?patient_id=550e8400-e29b-41d4-a716-446655440001
```

**Respuesta de estadísticas:**
```json
{
  "patient_id": "550e8400-e29b-41d4-a716-446655440001",
  "total_variants": 2,
  "variants_by_impact": {
    "MISSENSE": 2
  },
  "genes_affected": ["BRCA1", "TP53"],
  "latest_detection_date": "2024-01-15"
}
```

---

## 📚 Documentación

### Swagger UI (Interactivo)

Interfaz visual para probar todos los endpoints.

**URL:** http://localhost:8000/api/docs/

**Características:**
- ✅ Prueba endpoints directamente desde el navegador
- ✅ Validación automática de datos
- ✅ Ejemplos de peticiones y respuestas
- ✅ Esquemas de datos detallados

### ReDoc (Documentación Estática)

Documentación en formato limpio y profesional.

**URL:** http://localhost:8000/api/redoc/

### Schema OpenAPI

Esquema JSON descargable para integraciones.

**URL:** http://localhost:8000/api/schema/

---

## 🧪 Pruebas

### Verificar Servicios

```bash
# Ver estado de contenedores
docker ps

# Ver logs del servicio
docker-compose logs web

# Ver logs de MySQL
docker-compose logs db
```

### Probar Endpoints

```bash
# Listar genes
curl http://localhost:8000/api/v1/genes/

# Crear un gen
curl -X POST http://localhost:8000/api/v1/genes/ \
  -H "Content-Type: application/json" \
  -d '{"symbol":"EGFR","full_name":"Epidermal Growth Factor Receptor","function_summary":"Receptor de crecimiento"}'

# Obtener variantes
curl http://localhost:8000/api/v1/variants/
```

### Acceder a la Base de Datos

```bash
# Conectar a MySQL
docker exec -it genomica_mysql mysql -ugenomica_user -pgenomica_pass genomica_db

# Ver tablas
SHOW TABLES;

# Ver datos de genes
SELECT * FROM genes;
```

---

## 🚢 Despliegue

### Estructura de Archivos

```
Genomica/
├── genomica_service/        # Configuración Django
│   ├── settings.py          # Configuración principal
│   ├── urls.py              # URLs del proyecto
│   ├── wsgi.py              # WSGI para producción
│   └── asgi.py              # ASGI para async
├── genomics/                # App de genómica
│   ├── models.py            # Modelos ORM
│   ├── serializers.py       # DTOs y validación
│   ├── views.py             # ViewSets y lógica
│   ├── urls.py              # Routing de la app
│   ├── admin.py             # Panel de administración
│   └── migrations/          # Migraciones de BD
├── docker-compose.yml       # Orquestación de contenedores
├── Dockerfile               # Imagen del servicio
├── requirements.txt         # Dependencias Python
├── manage.py                # CLI de Django
├── load_sample_data.py      # Datos de ejemplo
├── .env.example             # Template de variables
├── .gitignore               # Archivos ignorados
└── README.md                # Esta documentación
```

### Variables de Entorno

Crear archivo `.env` basado en `.env.example`:

```env
# Django
SECRET_KEY=django-insecure-change-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# MySQL
DB_NAME=genomica_db
DB_USER=genomica_user
DB_PASSWORD=genomica_pass
DB_HOST=db
DB_PORT=3306

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:4200
```

### Despliegue en Kubernetes

El proyecto está preparado para despliegue en Kubernetes. Configuraciones recomendadas:

- **ConfigMaps**: Variables de entorno no sensibles
- **Secrets**: Credenciales de BD y SECRET_KEY
- **PersistentVolumeClaims**: Para datos de MySQL
- **Services**: Exposición interna del servicio
- **Ingress**: Para acceso externo (opcional)

---

## 🔒 Seguridad

### Buenas Prácticas Implementadas

✅ **ORM Exclusivo**: Todas las consultas usan Django ORM  
✅ **Validación de DTOs**: Serializers validan todos los datos  
✅ **CORS Configurado**: Solo orígenes permitidos  
✅ **Secrets en Variables**: Credenciales en archivos .env  
✅ **HTTPS Ready**: Preparado para TLS/SSL  

### Recomendaciones para Producción

1. Cambiar `SECRET_KEY` a un valor seguro
2. Establecer `DEBUG=False`
3. Configurar `ALLOWED_HOSTS` correctamente
4. Usar variables de entorno reales
5. Implementar autenticación JWT
6. Configurar límites de tasa (rate limiting)
7. Habilitar HTTPS
8. Usar base de datos en cluster

---

## 🤝 Integración con Otros Microservicios

### Microservicio de Clínica (NestJS)

El campo `patient_id` en `PatientVariantReport` referencia a pacientes gestionados por el microservicio de Clínica.

**Flujo de integración:**
1. Cliente consulta paciente en Microservicio de Clínica
2. Obtiene `patient_id` (UUID)
3. Consulta variantes genéticas en este microservicio usando ese `patient_id`

### Microservicio de Autenticación (Spring Boot)

Todas las peticiones deben pasar por el Gateway de Autenticación que:
- Valida JWT tokens
- Autoriza acceso
- Redirige a microservicios internos

---

## 📈 Próximos Pasos

- [ ] Implementar autenticación JWT
- [ ] Agregar más tests unitarios
- [ ] Configurar CI/CD pipeline
- [ ] Métricas y monitoreo (Prometheus)
- [ ] Logging centralizado
- [ ] Cache con Redis
- [ ] WebSockets para actualizaciones en tiempo real

---

## 👥 Equipo

**Proyecto**: GenoSentinel  
**Cliente**: Breaze Labs  
**Institución**: Maestría en Arquitectura de Software  

---

## 📄 Licencia

Este proyecto es parte de un trabajo académico.

---

<div align="center">

**🧬 GenoSentinel - Revolucionando la medicina genómica oncológica**

Desarrollado con ❤️ usando Django REST Framework

[Documentación](#) • [API](#) • [Soporte](#)

</div>
