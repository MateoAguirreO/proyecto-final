# Ejemplos de Uso - GenoSentinel en Kubernetes

## 🌐 Obtener URL del Gateway

### Minikube

```bash
export GATEWAY_URL=$(minikube service gateway -n genosentinel --url)
echo $GATEWAY_URL
```

### Docker Desktop

```bash
export GATEWAY_URL="http://localhost:8080"
```

### Cloud Providers

```bash
export GATEWAY_URL="http://$(kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8080"
```

## 🔐 Autenticación

### 1. Registrar Usuario

```bash
curl -X POST $GATEWAY_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Test1234!",
    "fullName": "Test User",
    "email": "test@example.com"
  }'
```

**Respuesta esperada:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "testuser",
  "fullName": "Test User",
  "email": "test@example.com",
  "role": "USER",
  "expiresIn": 86400000
}
```

### 2. Login

```bash
TOKEN=$(curl -X POST $GATEWAY_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Test1234!"
  }' | jq -r '.token')

echo "Token: $TOKEN"
```

## 🧬 Microservicio Genomica

### Listar Genes

```bash
curl -X GET $GATEWAY_URL/api/genomica/genes/ \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Crear Gen

```bash
curl -X POST $GATEWAY_URL/api/genomica/genes/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "EGFR",
    "full_name": "Epidermal Growth Factor Receptor",
    "function_summary": "Receptor de factor de crecimiento epidérmico"
  }' | jq
```

### Buscar Gen por Símbolo

```bash
curl -X GET "$GATEWAY_URL/api/genomica/genes/search_by_symbol/?symbol=BRCA1" \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Listar Variantes Genéticas

```bash
curl -X GET $GATEWAY_URL/api/genomica/variants/ \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Crear Variante Genética

```bash
curl -X POST $GATEWAY_URL/api/genomica/variants/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "gene": 1,
    "chromosome": "chr17",
    "position": 43044295,
    "reference_base": "C",
    "alternate_base": "T",
    "impact": "MISSENSE",
    "clinical_significance": "Patogénica"
  }' | jq
```

### Reportes de Pacientes

```bash
curl -X GET $GATEWAY_URL/api/genomica/patient-reports/ \
  -H "Authorization: Bearer $TOKEN" | jq
```

## 🏥 Microservicio Clinica

### Listar Pacientes

```bash
curl -X GET $GATEWAY_URL/api/clinica/patients \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Crear Paciente

```bash
curl -X POST $GATEWAY_URL/api/clinica/patients \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Juan",
    "lastName": "Perez",
    "dateOfBirth": "15 May 1985",
    "gender": "M",
    "status": "Active"
  }' | jq
```

### Obtener Paciente por ID

```bash
PATIENT_ID="<patient-id>"
curl -X GET $GATEWAY_URL/api/clinica/patients/$PATIENT_ID \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Actualizar Paciente

```bash
curl -X PATCH $GATEWAY_URL/api/clinica/patients/$PATIENT_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "Inactive"
  }' | jq
```

### Listar Tipos de Tumores

```bash
curl -X GET $GATEWAY_URL/api/clinica/tumortypes \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Crear Tipo de Tumor

```bash
curl -X POST $GATEWAY_URL/api/clinica/tumortypes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tumorName": "Melanoma",
    "systemAffected": "Skin"
  }' | jq
```

### Listar Registros Clínicos

```bash
curl -X GET $GATEWAY_URL/api/clinica/clinicalrecords \
  -H "Authorization: Bearer $TOKEN" | jq
```

## 📊 Monitoreo y Salud

### Health Check del Gateway

```bash
curl -X GET $GATEWAY_URL/actuator/health | jq
```

### Health Check de Genomica (directo)

```bash
# Desde dentro del cluster
kubectl exec -it -n genosentinel deployment/gateway -- \
  curl http://genomica-service:8000/api/v1/ | jq
```

### Health Check de Clinica (directo)

```bash
# Desde dentro del cluster
kubectl exec -it -n genosentinel deployment/gateway -- \
  curl http://clinica-service:3000/api
```

## 🔄 PowerShell (Windows)

### Registrar y Login

```powershell
# Registrar
$register = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/auth/register" `
  -Method POST `
  -Body (@{
    username="testuser"
    password="Test1234!"
    fullName="Test User"
    email="test@example.com"
  } | ConvertTo-Json) `
  -ContentType "application/json"

# Login
$login = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/auth/login" `
  -Method POST `
  -Body (@{username="testuser"; password="Test1234!"} | ConvertTo-Json) `
  -ContentType "application/json"

$token = $login.token
$headers = @{Authorization = "Bearer $token"}
```

### Consultar Genes

```powershell
Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/genomica/genes/" `
  -Headers $headers | ConvertTo-Json
```

### Consultar Pacientes

```powershell
Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/clinica/patients" `
  -Headers $headers | ConvertTo-Json
```

### Crear Paciente

```powershell
$patient = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/clinica/patients" `
  -Method POST `
  -Headers $headers `
  -Body (@{
    firstName="Maria"
    lastName="Garcia"
    dateOfBirth="20 Jun 1990"
    gender="F"
    status="Active"
  } | ConvertTo-Json) `
  -ContentType "application/json"

$patient | ConvertTo-Json
```

## 🧪 Script de Prueba Completo

### Bash

```bash
#!/bin/bash
set -e

# Configurar URL
export GATEWAY_URL=$(minikube service gateway -n genosentinel --url 2>/dev/null || echo "http://localhost:8080")

echo "🔗 Gateway URL: $GATEWAY_URL"

# Registrar usuario
echo "📝 Registrando usuario..."
curl -X POST $GATEWAY_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testk8s","password":"Test1234!","fullName":"Test K8s","email":"testk8s@example.com"}' \
  -s | jq

# Login
echo "🔐 Haciendo login..."
TOKEN=$(curl -X POST $GATEWAY_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testk8s","password":"Test1234!"}' \
  -s | jq -r '.token')

echo "✅ Token obtenido: ${TOKEN:0:50}..."

# Probar Genomica
echo "🧬 Consultando genes..."
curl -X GET $GATEWAY_URL/api/genomica/genes/ \
  -H "Authorization: Bearer $TOKEN" \
  -s | jq '.results[] | {symbol, full_name}'

# Probar Clinica
echo "🏥 Consultando pacientes..."
curl -X GET $GATEWAY_URL/api/clinica/patients \
  -H "Authorization: Bearer $TOKEN" \
  -s | jq '.[] | {firstName, lastName, status}'

echo "✅ Pruebas completadas!"
```

### PowerShell

```powershell
# Configurar URL
if (Get-Command minikube -ErrorAction SilentlyContinue) {
    $env:GATEWAY_URL = minikube service gateway -n genosentinel --url 2>$null
} else {
    $env:GATEWAY_URL = "http://localhost:8080"
}

Write-Host "🔗 Gateway URL: $env:GATEWAY_URL" -ForegroundColor Cyan

# Registrar usuario
Write-Host "📝 Registrando usuario..." -ForegroundColor Yellow
$register = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/auth/register" `
  -Method POST `
  -Body (@{username="testk8s"; password="Test1234!"; fullName="Test K8s"; email="testk8s@example.com"} | ConvertTo-Json) `
  -ContentType "application/json"

# Login
Write-Host "🔐 Haciendo login..." -ForegroundColor Yellow
$login = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/auth/login" `
  -Method POST `
  -Body (@{username="testk8s"; password="Test1234!"} | ConvertTo-Json) `
  -ContentType "application/json"

$token = $login.token
$headers = @{Authorization = "Bearer $token"}
Write-Host "✅ Token obtenido: $($token.Substring(0,50))..." -ForegroundColor Green

# Probar Genomica
Write-Host "🧬 Consultando genes..." -ForegroundColor Yellow
$genes = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/genomica/genes/" -Headers $headers
$genes.results | Select-Object symbol, full_name | Format-Table

# Probar Clinica
Write-Host "🏥 Consultando pacientes..." -ForegroundColor Yellow
$patients = Invoke-RestMethod -Uri "$env:GATEWAY_URL/api/clinica/patients" -Headers $headers
$patients | Select-Object firstName, lastName, status | Format-Table

Write-Host "✅ Pruebas completadas!" -ForegroundColor Green
```

## 🚀 Escenarios Avanzados

### Port-Forward para debug

```bash
# Gateway
kubectl port-forward -n genosentinel svc/gateway 8080:8080

# Genomica
kubectl port-forward -n genosentinel svc/genomica-service 8000:8000

# Clinica
kubectl port-forward -n genosentinel svc/clinica-service 3000:3000
```

### Ejecutar comando en pod

```bash
kubectl exec -it -n genosentinel deployment/gateway -- /bin/sh
```

### Ver variables de entorno

```bash
kubectl exec -it -n genosentinel deployment/gateway -- env | grep MICROSERVICES
```

### Reiniciar deployment

```bash
kubectl rollout restart deployment/gateway -n genosentinel
kubectl rollout restart deployment/genomica-service -n genosentinel
kubectl rollout restart deployment/clinica-service -n genosentinel
```
