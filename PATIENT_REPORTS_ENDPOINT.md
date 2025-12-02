# Endpoint de Patient Reports - Genomica

## ✅ Estado: FUNCIONANDO CORRECTAMENTE

### URL

```
POST /api/genomica/v1/patient-reports/
GET  /api/genomica/v1/patient-reports/
GET  /api/genomica/v1/patient-reports/{id}/
```

### Autenticación

Requiere JWT token en header:

```
Authorization: Bearer <token>
```

### Campos Requeridos (POST)

```json
{
  "patient_id": "UUID válido (formato: 550e8400-e29b-41d4-a716-446655440001)",
  "variant": "UUID de variante existente en base de datos",
  "detection_date": "Fecha en formato YYYY-MM-DD (ej: 2024-11-15)",
  "allele_frequency": "Número decimal entre 0.0 y 1.0 (ej: 0.4523)"
}
```

### Campos Opcionales

```json
{
  "sample_type": "Tipo de muestra (ej: Biopsia tumoral, Sangre periférica)",
  "notes": "Notas adicionales sobre el reporte"
}
```

### Ejemplo de Uso Exitoso

```bash
# 1. Obtener token
curl -X POST http://[GATEWAY_URL]/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"reportuser","password":"Test1234"}'

# 2. Crear report
curl -X POST http://[GATEWAY_URL]/api/genomica/v1/patient-reports/ \
  -H "Authorization: Bearer [TOKEN]" \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "550e8400-e29b-41d4-a716-446655440001",
    "variant": "2e12c909-5b79-418a-a9ac-e0c139b14637",
    "detection_date": "2024-11-15",
    "allele_frequency": 0.4523,
    "sample_type": "Biopsia tumoral",
    "notes": "Variante patogenica detectada en TP53"
  }'

# 3. Listar reports
curl http://[GATEWAY_URL]/api/genomica/v1/patient-reports/ \
  -H "Authorization: Bearer [TOKEN]"

# 4. Obtener report específico
curl http://[GATEWAY_URL]/api/genomica/v1/patient-reports/[REPORT_ID]/ \
  -H "Authorization: Bearer [TOKEN]"
```

### Respuesta Exitosa (201 Created)

```json
{
  "id": "2c0548e3-2d70-43f1-8729-c1ebe77df890",
  "patient_id": "550e8400-e29b-41d4-a716-446655440001",
  "variant": "2e12c909-5b79-418a-a9ac-e0c139b14637",
  "detection_date": "2024-11-15",
  "allele_frequency": 0.4523,
  "sample_type": "Biopsia tumoral",
  "notes": "Variante patogenica detectada en TP53",
  "created_at": "2025-12-01T22:19:08.539138-05:00",
  "updated_at": "2025-12-01T22:19:08.539164-05:00"
}
```

### GET Response con información expandida

```json
{
  "id": "2c0548e3-2d70-43f1-8729-c1ebe77df890",
  "patient_id": "550e8400-e29b-41d4-a716-446655440001",
  "variant_info": {
    "id": "2e12c909-5b79-418a-a9ac-e0c139b14637",
    "gene_info": {
      "id": 2,
      "symbol": "TP53",
      "full_name": "Tumor Protein p53"
    },
    "chromosome": "chr17",
    "position": 7676154,
    "reference_base": "G",
    "alternate_base": "T",
    "impact": "MISSENSE",
    "clinical_significance": "Hotspot oncogénico"
  },
  "detection_date": "2024-11-15",
  "allele_frequency": 0.4523,
  "sample_type": "Biopsia tumoral",
  "notes": "Variante patogenica detectada en TP53"
}
```

## Errores Comunes

### 400 Bad Request - Campos faltantes

```json
{
  "variant": ["Este campo es requerido."],
  "detection_date": ["Este campo es requerido."],
  "allele_frequency": ["Este campo es requerido."]
}
```

**Solución:** Asegúrate de incluir todos los campos requeridos.

### 400 Bad Request - UUID inválido

```json
{
  "patient_id": ["Must be a valid UUID."]
}
```

**Solución:** El `patient_id` debe ser un UUID válido (ej: 550e8400-e29b-41d4-a716-446655440001), no un ObjectId de MongoDB.

### 400 Bad Request - Variante no existe

```json
{
  "variant": ["Invalid pk \"xxx\" - object does not exist."]
}
```

**Solución:** Primero obtén las variantes disponibles con `GET /api/genomica/v1/variants/` y usa un ID válido.

### 403 Forbidden

**Solución:** Verifica que el token JWT sea válido y no haya expirado.

## Nota Importante sobre patient_id

⚠️ El campo `patient_id` en Genomica es de tipo UUID, pero los pacientes en el servicio Clinica usan MongoDB ObjectId (string).

**Recomendación:**

- Para pruebas, usa UUIDs ficticios válidos
- En producción, implementa un sistema de mapeo entre ObjectId de Clinica y UUID de Genomica
- O modifica el modelo de Genomica para aceptar strings en lugar de UUIDs estrictos

## Datos de Prueba

### Variantes disponibles (obtener con GET /api/genomica/v1/variants/)

- `2e12c909-5b79-418a-a9ac-e0c139b14637` (TP53)
- `6f8c7e3a-4b2d-4a1e-9f5c-8d6e7f8a9b0c` (BRCA1)
- Otros según datos cargados

### Patient IDs de ejemplo (UUID válidos para pruebas)

- `550e8400-e29b-41d4-a716-446655440001`
- `550e8400-e29b-41d4-a716-446655440002`
- `550e8400-e29b-41d4-a716-446655440003`
