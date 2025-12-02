#!/bin/bash

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "=== PRUEBAS DE ENDPOINTS ==="
echo ""

# 1. Health Check
echo "1. Health Check:"
curl -s "$BASE_URL/actuator/health" | head -c 200
echo ""
echo ""

# 2. Registro (usando printf para evitar problemas de encoding)
echo "2. Intentando registro:"
curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  --data-binary '{"username":"newuser","password":"Pass1234","email":"new@demo.com","fullName":"New User"}' \
  | head -c 500
echo ""
echo ""

# 3. Si el registro falla, intentar con usuario doctor existente
echo "3. Login con usuario existente (doctor / password123):"
TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"doctor","password":"password123"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Login falló. Mostrando error:"
  curl -s -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"doctor","password":"password123"}'
  echo ""
else
  echo "✅ Token obtenido: ${TOKEN:0:50}..."
  echo ""
  
  # 4. Probar endpoints protegidos
  echo "4. Probando endpoint raíz con autenticación:"
  curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/" \
    -H "Authorization: Bearer $TOKEN"
  echo ""
  
  echo "5. Probando /api/genomica/v1/:"
  curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/api/genomica/v1/" \
    -H "Authorization: Bearer $TOKEN"
  echo ""
  
  echo "6. Probando /api/clinica/v1/:"
  curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/api/clinica/v1/" \
    -H "Authorization: Bearer $TOKEN"
  echo ""
fi
