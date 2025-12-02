#!/bin/bash

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "=== PRUEBAS COMPLETAS DE ENDPOINTS ==="
echo ""

# 1. Health Check
echo "1. Health Check:"
curl -s "$BASE_URL/actuator/health" | jq -r '.status'
echo ""

# 2. Login con usuario registrado
echo "2. Login (newuser / Pass1234):"
TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"newuser","password":"Pass1234"}' | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Login falló. Intentando con usuario nuevo..."
  
  # Registrar usuario si no existe
  echo ""
  echo "3. Registrando usuario testuser:"
  REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","password":"Test1234","email":"test@demo.com","fullName":"Test User"}')
  
  TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.token')
  echo "✅ Usuario registrado. Token: ${TOKEN:0:50}..."
else
  echo "✅ Token obtenido: ${TOKEN:0:50}..."
fi

echo ""
echo "=== PROBANDO ENDPOINTS PROTEGIDOS ==="
echo ""

# 4. Genes
echo "4. GET /api/genomica/v1/genes/:"
GENES_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/api/genomica/v1/genes/" \
  -H "Authorization: Bearer $TOKEN")
HTTP_STATUS=$(echo "$GENES_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
GENES_DATA=$(echo "$GENES_RESPONSE" | sed '/HTTP_STATUS/d')

echo "   Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ]; then
    COUNT=$(echo "$GENES_DATA" | jq -r '.count // 0')
    echo "   ✅ Total genes: $COUNT"
    echo "$GENES_DATA" | jq -r '.results[0] | "   Ejemplo: \(.symbol) - \(.name)"' 2>/dev/null || echo "   (Sin resultados)"
else
    echo "   ❌ Error: $GENES_DATA"
fi
echo ""

# 5. Variants
echo "5. GET /api/genomica/v1/variants/:"
VARIANTS_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/api/genomica/v1/variants/" \
  -H "Authorization: Bearer $TOKEN")
HTTP_STATUS=$(echo "$VARIANTS_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
VARIANTS_DATA=$(echo "$VARIANTS_RESPONSE" | sed '/HTTP_STATUS/d')

echo "   Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ]; then
    COUNT=$(echo "$VARIANTS_DATA" | jq -r '.count // 0')
    echo "   ✅ Total variantes: $COUNT"
    echo "$VARIANTS_DATA" | jq -r '.results[0] | "   Ejemplo: \(.variant_id) - \(.gene_symbol)"' 2>/dev/null || echo "   (Sin resultados)"
else
    echo "   ❌ Error: $VARIANTS_DATA"
fi
echo ""

# 6. Patient Reports
echo "6. GET /api/genomica/v1/patient-reports/:"
REPORTS_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/api/genomica/v1/patient-reports/" \
  -H "Authorization: Bearer $TOKEN")
HTTP_STATUS=$(echo "$REPORTS_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
REPORTS_DATA=$(echo "$REPORTS_RESPONSE" | sed '/HTTP_STATUS/d')

echo "   Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ]; then
    COUNT=$(echo "$REPORTS_DATA" | jq -r '.count // 0')
    echo "   ✅ Total reportes: $COUNT"
    echo "$REPORTS_DATA" | jq -r '.results[0] | "   Ejemplo: Paciente \(.patient_id) - \(.variants | length) variantes"' 2>/dev/null || echo "   (Sin resultados)"
else
    echo "   ❌ Error: $REPORTS_DATA"
fi
echo ""

# 7. Swagger docs
echo "7. Verificando Swagger UI:"
SWAGGER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/genomica/docs/")
SWAGGER_CT=$(curl -s -I "$BASE_URL/api/genomica/docs/" | grep -i "content-type:" | cut -d' ' -f2- | tr -d '\r')
echo "   Status: $SWAGGER_STATUS"
echo "   Content-Type: $SWAGGER_CT"
if [ "$SWAGGER_CT" = "text/html;charset=utf-8" ]; then
    echo "   ✅ Swagger UI configurado correctamente"
else
    echo "   ⚠️  Content-Type inesperado"
fi
echo ""

echo "=== RESUMEN ==="
echo "URLs disponibles:"
echo "  - API Gateway: $BASE_URL"
echo "  - Swagger Genomica: $BASE_URL/api/genomica/docs/"
echo "  - OpenAPI Schema: $BASE_URL/api/genomica/schema/"
echo "  - ReDoc: $BASE_URL/api/genomica/redoc/"
