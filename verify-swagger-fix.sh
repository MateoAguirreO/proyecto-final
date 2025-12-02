#!/bin/bash

echo "=== Verificando Swagger UI después de actualización ==="
echo ""

BASE_URL="http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

echo "Esperando a que el servicio esté listo..."
sleep 10

echo ""
echo "1. Verificando URL del schema en Swagger HTML:"
SCHEMA_URL=$(curl -s "$BASE_URL/api/genomica/docs/" | grep -o 'url: *"[^"]*"' | cut -d'"' -f2)
echo "   Schema URL configurada: $SCHEMA_URL"
if [ "$SCHEMA_URL" = "../schema/" ]; then
    echo "   ✅ URL relativa correcta"
elif [ "$SCHEMA_URL" = "/api/schema/" ]; then
    echo "   ⚠️  URL absoluta incorrecta - debería ser relativa"
else
    echo "   URL: $SCHEMA_URL"
fi
echo ""

echo "2. Verificando que el schema esté accesible:"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/genomica/schema/")
echo "   Status: $STATUS"
if [ "$STATUS" = "200" ]; then
    echo "   ✅ Schema accesible"
    SCHEMA_SIZE=$(curl -s "$BASE_URL/api/genomica/schema/" | wc -c)
    echo "   Tamaño del schema: $SCHEMA_SIZE bytes"
else
    echo "   ❌ Schema no accesible"
fi
echo ""

echo "3. Verificando Swagger UI:"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/genomica/docs/")
echo "   Status: $STATUS"
CONTENT_TYPE=$(curl -s -I "$BASE_URL/api/genomica/docs/" | grep -i "content-type:" | cut -d' ' -f2-)
echo "   Content-Type: $CONTENT_TYPE"
echo ""

echo "Ahora abre en tu navegador:"
echo "   $BASE_URL/api/genomica/docs/"
echo ""
echo "Swagger UI debería cargar correctamente con la definición de la API."
