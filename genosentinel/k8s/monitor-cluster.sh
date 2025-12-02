#!/bin/bash
echo "Monitoreando cluster EKS..."
while true; do
  STATUS=$(aws eks describe-cluster --name genosentinel --region us-east-1 --query 'cluster.status' --output text 2>/dev/null)
  echo "$(date '+%H:%M:%S') - Estado: $STATUS"
  
  if [ "$STATUS" = "ACTIVE" ]; then
    echo "Cluster ACTIVE! Iniciando deployment..."
    break
  fi
  
  sleep 60
done

echo "Configurando kubectl..."
aws eks update-kubeconfig --name genosentinel --region us-east-1

echo "Verificando cluster..."
kubectl get nodes

echo "Desplegando aplicación..."
cd /mnt/c/Users/USUARIO/Documents/Maestria/Arquitectura/'proyecto final'/genosentinel
bash k8s/deploy-aws.sh
