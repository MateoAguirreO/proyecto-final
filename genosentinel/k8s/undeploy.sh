#!/bin/bash
# Script para eliminar el despliegue de GenoSentinel en Kubernetes

set -e

echo "Eliminando despliegue de GenoSentinel..."
echo ""

# Verificar que kubectl está disponible
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl no está instalado"
    exit 1
fi

# Preguntar confirmación
read -p "¿Estás seguro que deseas eliminar todo el despliegue de GenoSentinel? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelado"
    exit 1
fi

echo "Eliminando namespace genosentinel y todos sus recursos..."
kubectl delete namespace genosentinel

echo ""
echo "Despliegue eliminado completamente"
echo ""
echo "Para volver a desplegar, ejecuta:"
echo "   ./k8s/deploy.sh"
