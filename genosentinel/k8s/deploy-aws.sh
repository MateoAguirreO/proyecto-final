#!/bin/bash
set -e

echo "=== GenoSentinel AWS EKS Deployment ==="
echo ""

# Configurar kubectl para EKS
echo "[1/5] Configurando kubectl para cluster EKS..."
aws eks update-kubeconfig --name genosentinel --region us-east-1

# Verificar conexión al cluster
echo "[2/5] Verificando conexión al cluster..."
kubectl cluster-info
kubectl get nodes

# Aplicar manifiestos de Kubernetes
echo "[3/5] Aplicando manifiestos de Kubernetes..."
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/namespace.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/configmap.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/secrets.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/pvc.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/mysql-deployments.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/genomica-deployment.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/clinica-deployment.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/gateway-deployment.yaml
kubectl apply -f /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel/k8s/base/services.yaml

# Esperar a que los pods estén listos
echo "[4/5] Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=mysql-genomica -n genosentinel --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=mysql-clinica -n genosentinel --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=genomica-service -n genosentinel --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=clinica-service -n genosentinel --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=gateway -n genosentinel --timeout=300s || true

# Mostrar estado del deployment
echo "[5/5] Estado del deployment:"
kubectl get all -n genosentinel

echo ""
echo "Deployment completado!"
echo ""
echo "Para obtener la URL del servicio Gateway (LoadBalancer):"
echo "  kubectl get svc gateway-service -n genosentinel"
echo ""
echo "Para ver los logs:"
echo "  kubectl logs -f -l app=gateway -n genosentinel"
echo "  kubectl logs -f -l app=genomica-service -n genosentinel"
echo "  kubectl logs -f -l app=clinica-service -n genosentinel"
