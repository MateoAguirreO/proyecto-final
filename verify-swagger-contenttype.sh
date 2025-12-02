#!/bin/bash

echo "=== Verificando Content-Type de endpoints Swagger ==="
echo ""

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "1. Verificando /api/genomica/docs/ (Swagger UI):"
CONTENT_TYPE=$(curl -s -I "$BASE_URL/api/genomica/docs/" | grep -i "content-type:" | cut -d' ' -f2-)
echo "   Content-Type: $CONTENT_TYPE"
if echo "$CONTENT_TYPE" | grep -q "text/html"; then
    echo "   ✅ CORRECTO - Es text/html"
else
    echo "   ❌ INCORRECTO - Debería ser text/html"
fi
echo ""

echo "2. Verificando /api/genomica/schema/ (OpenAPI Schema):"
CONTENT_TYPE=$(curl -s -I "$BASE_URL/api/genomica/schema/" | grep -i "content-type:" | cut -d' ' -f2-)
echo "   Content-Type: $CONTENT_TYPE"
if echo "$CONTENT_TYPE" | grep -q "application/"; then
    echo "   ✅ CORRECTO - Es application/vnd.oai.openapi o similar"
else
    echo "   ⚠️  Content-Type: $CONTENT_TYPE"
fi
echo ""

echo "3. Verificando /api/genomica/v1/genes/ (API JSON):"
CONTENT_TYPE=$(curl -s -I "$BASE_URL/api/genomica/v1/genes/" | grep -i "content-type:" | cut -d' ' -f2-)
echo "   Content-Type: $CONTENT_TYPE"
if echo "$CONTENT_TYPE" | grep -q "application/json"; then
    echo "   ✅ CORRECTO - Es application/json"
else
    echo "   ❌ INCORRECTO - Debería ser application/json"
fi
echo ""

echo "4. Probando el contenido HTML de Swagger:"
CONTENT=$(curl -s "$BASE_URL/api/genomica/docs/" | head -c 200)
if echo "$CONTENT" | grep -q "<!doctype html>"; then
    echo "   ✅ Respuesta contiene HTML válido"
else
    echo "   ⚠️  Respuesta: $CONTENT"
fi
