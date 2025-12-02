#!/bin/bash
# Script de despliegue para GenoSentinel en Kubernetes

set -e

echo "Desplegando GenoSentinel en Kubernetes..."
echo ""

# Verificar que kubectl está disponible
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl no está instalado"
    exit 1
fi

# Verificar conexión al cluster
echo "Verificando conexión al cluster..."
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: No se puede conectar al cluster de Kubernetes"
    exit 1
fi

echo "Conectado al cluster"
echo ""

# Verificar que las imágenes existen
echo "Verificando imágenes Docker..."
if ! docker images | grep -q "genosentinel-gateway"; then
    echo "Advertencia: Imagen genosentinel-gateway:latest no encontrada"
    echo "   Ejecuta: docker-compose build gateway"
fi

if ! docker images | grep -q "genosentinel-genomica-service"; then
    echo "Advertencia: Imagen genosentinel-genomica-service:latest no encontrada"
    echo "   Ejecuta: docker-compose build genomica-service"
fi

if ! docker images | grep -q "genosentinel-clinica-service"; then
    echo "Advertencia: Imagen genosentinel-clinica-service:latest no encontrada"
    echo "   Ejecuta: docker-compose build clinica-service"
fi

echo ""

# Para minikube, cargar imágenes
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "Minikube detectado, cargando imágenes..."
    minikube image load genosentinel-gateway:latest 2>/dev/null || true
    minikube image load genosentinel-genomica-service:latest 2>/dev/null || true
    minikube image load genosentinel-clinica-service:latest 2>/dev/null || true
    echo "Imágenes cargadas en minikube"
    echo ""
fi

# Aplicar manifiestos
echo "Aplicando namespace..."
kubectl apply -f k8s/base/namespace.yaml

echo "Aplicando configuraciones..."
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secrets.yaml
kubectl apply -f k8s/base/pvc.yaml

echo "Desplegando bases de datos MySQL..."
kubectl apply -f k8s/base/mysql-deployments.yaml

echo "Esperando a que MySQL esté listo (puede tomar 1-2 minutos)..."
kubectl wait --for=condition=ready pod -l app=gateway-mysql -n genosentinel --timeout=300s 2>/dev/null || echo "Timeout esperando gateway-mysql"
kubectl wait --for=condition=ready pod -l app=genomica-mysql -n genosentinel --timeout=300s 2>/dev/null || echo "Timeout esperando genomica-mysql"

echo "Desplegando servicios de aplicación..."
kubectl apply -f k8s/base/genomica-deployment.yaml
kubectl apply -f k8s/base/clinica-deployment.yaml

echo "Esperando a que los servicios estén listos..."
kubectl wait --for=condition=ready pod -l app=genomica-service -n genosentinel --timeout=300s 2>/dev/null || echo "Timeout esperando genomica-service"
kubectl wait --for=condition=ready pod -l app=clinica-service -n genosentinel --timeout=300s 2>/dev/null || echo "Timeout esperando clinica-service"

echo "Desplegando Gateway..."
kubectl apply -f k8s/base/gateway-deployment.yaml

echo "Exponiendo servicios..."
kubectl apply -f k8s/base/services.yaml

echo ""
echo "Despliegue completado!"
echo ""
echo "Estado del cluster:"
kubectl get pods -n genosentinel
echo ""
echo "Servicios:"
kubectl get svc -n genosentinel
echo ""

# Intentar obtener la URL del Gateway
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "URL del Gateway (minikube):"
    minikube service gateway -n genosentinel --url
elif kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null | grep -q "."; then
    GATEWAY_IP=$(kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "URL del Gateway: http://$GATEWAY_IP:8080"
else
    echo "URL del Gateway: http://localhost:8080"
fi

echo ""
echo "Para ver los logs:"
echo "   kubectl logs -n genosentinel -l app=gateway -f"
echo ""
echo "Para eliminar todo:"
echo "   kubectl delete namespace genosentinel"
