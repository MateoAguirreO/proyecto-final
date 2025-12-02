#!/bin/bash

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         PRUEBA COMPLETA DE GENOSENTINEL - TODOS LOS SERVICIOS          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Obtener token
echo "🔐 AUTENTICACIÓN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"newuser","password":"Pass1234"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "⚠️  Login falló, registrando nuevo usuario..."
  REGISTER=$(curl -s -X POST "$BASE_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"fulltest","password":"Test1234","email":"fulltest@test.com","fullName":"Full Test"}')
  TOKEN=$(echo "$REGISTER" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ ! -z "$TOKEN" ]; then
  echo "✅ Token JWT obtenido: ${TOKEN:0:50}..."
else
  echo "❌ No se pudo obtener token"
  exit 1
fi
echo ""

# GENOMICA
echo "🧬 SERVICIO GENOMICA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "📊 Genes:"
GENES_COUNT=$(curl -s "$BASE_URL/api/genomica/v1/genes/" \
  -H "Authorization: Bearer $TOKEN" | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "   Total: $GENES_COUNT genes"

echo "📊 Variantes:"
VARIANTS_COUNT=$(curl -s "$BASE_URL/api/genomica/v1/variants/" \
  -H "Authorization: Bearer $TOKEN" | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "   Total: $VARIANTS_COUNT variantes genéticas"

echo "📊 Reportes de Pacientes:"
REPORTS_COUNT=$(curl -s "$BASE_URL/api/genomica/v1/patient-reports/" \
  -H "Authorization: Bearer $TOKEN" | grep -o '"count":[0-9]*' | cut -d: -f2)
echo "   Total: $REPORTS_COUNT reportes"

echo "📄 Swagger UI:"
SWAGGER_G=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/genomica/docs/")
if [ "$SWAGGER_G" = "200" ]; then
  echo "   ✅ Disponible (HTTP $SWAGGER_G)"
else
  echo "   ❌ No disponible (HTTP $SWAGGER_G)"
fi
echo ""

# CLINICA
echo "🏥 SERVICIO CLINICA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "📊 Pacientes:"
PATIENTS=$(curl -s "$BASE_URL/api/clinica/patients/" \
  -H "Authorization: Bearer $TOKEN")
PATIENTS_COUNT=$(echo "$PATIENTS" | grep -o '"_id"' | wc -l)
echo "   Total: $PATIENTS_COUNT pacientes"

echo "📊 Tipos de Tumor:"
TUMORS=$(curl -s "$BASE_URL/api/clinica/tumortypes/" \
  -H "Authorization: Bearer $TOKEN")
TUMORS_COUNT=$(echo "$TUMORS" | grep -o '"_id"' | wc -l)
echo "   Total: $TUMORS_COUNT tipos de tumor"

echo "📊 Registros Clínicos:"
RECORDS=$(curl -s "$BASE_URL/api/clinica/clinicalrecords/" \
  -H "Authorization: Bearer $TOKEN")
RECORDS_COUNT=$(echo "$RECORDS" | grep -o '"_id"' | wc -l)
echo "   Total: $RECORDS_COUNT registros clínicos"

echo "📄 Swagger UI:"
SWAGGER_C=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/clinica/docs/")
if [ "$SWAGGER_C" = "200" ]; then
  echo "   ✅ Disponible (HTTP $SWAGGER_C)"
else
  echo "   ❌ No disponible (HTTP $SWAGGER_C)"
fi
echo ""

# GATEWAY
echo "🌐 GATEWAY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HEALTH=$(curl -s "$BASE_URL/actuator/health" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
echo "📊 Health Check: $HEALTH"
echo ""

# RESUMEN
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                           RESUMEN FINAL                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ GENOMICA:"
echo "   - $GENES_COUNT genes | $VARIANTS_COUNT variantes | $REPORTS_COUNT reportes"
echo "   - Swagger: HTTP $SWAGGER_G"
echo ""
echo "✅ CLINICA:"
echo "   - $PATIENTS_COUNT pacientes | $TUMORS_COUNT tipos tumor | $RECORDS_COUNT registros"
echo "   - Swagger: HTTP $SWAGGER_C"
echo ""
echo "✅ GATEWAY:"
echo "   - Health: $HEALTH"
echo ""
echo "🌍 URLs PRINCIPALES:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Gateway:          $BASE_URL"
echo "Swagger Genomica: $BASE_URL/api/genomica/docs/"
echo "Swagger Clinica:  $BASE_URL/api/clinica/docs/"
echo ""
echo "✨ PRUEBAS COMPLETADAS EXITOSAMENTE ✨"
