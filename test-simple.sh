#!/bin/bash

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "=== PRUEBAS COMPLETAS DE ENDPOINTS ==="
echo ""

# 1. Health Check
echo "1. Health Check:"
curl -s "$BASE_URL/actuator/health" | head -c 100
echo ""
echo ""

# 2. Login con usuario existente
echo "2. Login (newuser / Pass1234):"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"newuser","password":"Pass1234"}')

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Login falló. Registrando nuevo usuario..."
  echo ""
  
  # Registrar usuario
  echo "3. Registrando usuario testuser2:"
  REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser2","password":"Test1234","email":"test2@demo.com","fullName":"Test User 2"}')
  
  TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
  echo "Usuario registrado."
fi

echo "Token obtenido: ${TOKEN:0:60}..."
echo ""

echo "=== PROBANDO ENDPOINTS PROTEGIDOS ==="
echo ""

# 4. Genes
echo "4. GET /api/genomica/v1/genes/:"
echo "Response:"
curl -s "$BASE_URL/api/genomica/v1/genes/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | head -c 500
echo ""
echo ""

# 5. Variants  
echo "5. GET /api/genomica/v1/variants/:"
echo "Response:"
curl -s "$BASE_URL/api/genomica/v1/variants/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | head -c 500
echo ""
echo ""

# 6. Patient Reports
echo "6. GET /api/genomica/v1/patient-reports/:"
echo "Response:"
curl -s "$BASE_URL/api/genomica/v1/patient-reports/" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nHTTP Status: %{http_code}\n" | head -c 500
echo ""
echo ""

# 7. Swagger docs
echo "7. Verificando Swagger UI:"
SWAGGER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/genomica/docs/")
SWAGGER_CT=$(curl -s -I "$BASE_URL/api/genomica/docs/" 2>/dev/null | grep -i "content-type:" | cut -d' ' -f2- | tr -d '\r\n')
echo "Status: $SWAGGER_STATUS"
echo "Content-Type: $SWAGGER_CT"
echo ""

echo "=== URLS DISPONIBLES ==="
echo "Swagger UI: $BASE_URL/api/genomica/docs/"
echo "OpenAPI Schema: $BASE_URL/api/genomica/schema/"
echo "ReDoc: $BASE_URL/api/genomica/redoc/"
