#!/bin/bash

# Script de prueba de integración entre microservicios
# GenoSentinel Gateway + Genómica

echo "========================================"
echo "  PRUEBA DE INTEGRACIÓN - GenoSentinel"
echo "========================================"
echo ""

BASE_URL="http://localhost:8080"

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir resultados
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

echo "${YELLOW}1. Verificando estado del Gateway...${NC}"
curl -s "$BASE_URL/api/status" > /dev/null
print_result $? "Gateway está activo"
echo ""

echo "${YELLOW}2. Verificando health check completo...${NC}"
curl -s "$BASE_URL/api/health" | jq '.'
echo ""

echo "${YELLOW}3. Registrando nuevo usuario...${NC}"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user",
    "password": "test123",
    "fullName": "Usuario de Prueba",
    "email": "test@test.com"
  }')

echo "$REGISTER_RESPONSE" | jq '.'
TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.token')
print_result $? "Usuario registrado correctamente"
echo "Token: ${TOKEN:0:50}..."
echo ""

echo "${YELLOW}4. Login con usuario existente...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "password123"
  }')

echo "$LOGIN_RESPONSE" | jq '.'
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')
print_result $? "Login exitoso"
echo ""

echo "${YELLOW}5. Accediendo a microservicio de Genómica vía Gateway...${NC}"
echo "GET /api/gateway/genomica/api/v1/genes/"
curl -s "$BASE_URL/api/gateway/genomica/api/v1/genes/" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
print_result $? "Acceso a Genómica exitoso"
echo ""

echo "${YELLOW}6. Creando un gen vía Gateway...${NC}"
CREATE_GENE=$(curl -s -X POST "$BASE_URL/api/gateway/genomica/api/v1/genes/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "EGFR",
    "full_name": "Epidermal Growth Factor Receptor",
    "function_summary": "Receptor de tirosina quinasa que regula el crecimiento celular"
  }')

echo "$CREATE_GENE" | jq '.'
print_result $? "Gen creado exitosamente"
echo ""

echo "${YELLOW}7. Obteniendo variantes genéticas vía Gateway...${NC}"
curl -s "$BASE_URL/api/gateway/genomica/api/v1/variants/" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
print_result $? "Variantes obtenidas exitosamente"
echo ""

echo "${YELLOW}8. Obteniendo reportes de pacientes vía Gateway...${NC}"
curl -s "$BASE_URL/api/gateway/genomica/api/v1/patient-reports/" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
print_result $? "Reportes obtenidos exitosamente"
echo ""

echo "${YELLOW}9. Probando endpoint sin autenticación (debe fallar)...${NC}"
UNAUTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/api/gateway/genomica/api/v1/genes/")
HTTP_CODE=$(echo "$UNAUTH_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "403" ] || [ "$HTTP_CODE" = "401" ]; then
    print_result 0 "Autenticación requerida (como se esperaba)"
else
    print_result 1 "Seguridad no está funcionando correctamente"
fi
echo ""

echo "========================================"
echo -e "${GREEN}  PRUEBAS COMPLETADAS${NC}"
echo "========================================"
