#!/bin/bash

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "=== PRUEBAS DE ENDPOINTS DE CLINICA ==="
echo ""

# 1. Login para obtener token
echo "1. Obteniendo token JWT..."
TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"newuser","password":"Pass1234"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "No hay token. Registrando usuario..."
  REGISTER=$(curl -s -X POST "$BASE_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"clinicatest","password":"Test1234","email":"clinica@test.com","fullName":"Clinica Test"}')
  TOKEN=$(echo "$REGISTER" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

echo "Token: ${TOKEN:0:60}..."
echo ""

echo "=== PROBANDO ENDPOINTS DE CLINICA ==="
echo ""

# 2. Health check de Clinica (endpoint raíz)
echo "2. GET /api/clinica/ (Health Check):"
curl -s "$BASE_URL/api/clinica/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n"
echo ""

# 3. Patients - List all
echo "3. GET /api/clinica/patients/ (Lista de pacientes):"
curl -s "$BASE_URL/api/clinica/patients/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | head -c 500
echo ""
echo ""

# 4. Tumor Types - List all
echo "4. GET /api/clinica/tumortypes/ (Tipos de tumor):"
curl -s "$BASE_URL/api/clinica/tumortypes/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | head -c 500
echo ""
echo ""

# 5. Clinical Records - List all
echo "5. GET /api/clinica/clinicalrecords/ (Registros clínicos):"
curl -s "$BASE_URL/api/clinica/clinicalrecords/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | head -c 500
echo ""
echo ""

# 6. Create a patient
echo "6. POST /api/clinica/patients/ (Crear paciente):"
PATIENT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/clinica/patients/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Juan",
    "lastName": "Pérez",
    "dateOfBirth": "1980-05-15",
    "gender": "M",
    "email": "juan.perez@example.com",
    "phone": "+573001234567"
  }' \
  -w "\nHTTP_STATUS:%{http_code}")

HTTP_STATUS=$(echo "$PATIENT_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
PATIENT_DATA=$(echo "$PATIENT_RESPONSE" | sed '/HTTP_STATUS/d')
PATIENT_ID=$(echo "$PATIENT_DATA" | grep -o '"id":"[^"]*' | cut -d'"' -f4 | head -1)

echo "Response: $PATIENT_DATA" | head -c 300
echo ""
echo "HTTP Status: $HTTP_STATUS"
echo "Patient ID: $PATIENT_ID"
echo ""

# 7. Get patient by ID (if created successfully)
if [ ! -z "$PATIENT_ID" ] && [ "$HTTP_STATUS" = "201" ]; then
  echo "7. GET /api/clinica/patients/$PATIENT_ID (Obtener paciente):"
  curl -s "$BASE_URL/api/clinica/patients/$PATIENT_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -w "\nHTTP Status: %{http_code}\n" | head -c 400
  echo ""
  echo ""
fi

# 8. Swagger docs de Clinica
echo "8. Verificando Swagger UI de Clinica:"
SWAGGER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/clinica/docs/")
echo "Status: $SWAGGER_STATUS"
if [ "$SWAGGER_STATUS" = "200" ]; then
  echo "✅ Swagger UI disponible en: $BASE_URL/api/clinica/docs/"
else
  echo "⚠️  Swagger UI no disponible (status: $SWAGGER_STATUS)"
fi
echo ""

echo "=== RESUMEN ==="
echo "Endpoints de Clinica disponibles:"
echo "  - Pacientes: $BASE_URL/api/clinica/patients/"
echo "  - Registros Clínicos: $BASE_URL/api/clinica/clinicalrecords/"
echo "  - Tipos de Tumor: $BASE_URL/api/clinica/tumortypes/"
echo "  - Swagger Clinica: $BASE_URL/api/clinica/docs/"
