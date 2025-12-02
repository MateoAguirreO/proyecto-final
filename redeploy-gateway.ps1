# Script para redesplegar el Gateway con la nueva imagen

Write-Host "=== Redeployando Gateway con nueva imagen ===" -ForegroundColor Cyan

# Configurar perfil AWS
$env:AWS_PROFILE = "002164174837_AWSAdministratorAccess"

# Actualizar kubeconfig
Write-Host "[1/3] Actualizando configuración de kubectl..." -ForegroundColor Yellow
aws eks update-kubeconfig --name genosentinel --region us-east-1

# Reiniciar el deployment del gateway
Write-Host "[2/3] Reiniciando deployment del gateway..." -ForegroundColor Yellow
kubectl rollout restart deployment/gateway -n genosentinel

# Esperar a que el rollout termine
Write-Host "[3/3] Esperando a que el rollout complete..." -ForegroundColor Yellow
kubectl rollout status deployment/gateway -n genosentinel

# Verificar la imagen actual
Write-Host "`nImagen actual desplegada:" -ForegroundColor Green
kubectl get deployment gateway -n genosentinel -o jsonpath='{.spec.template.spec.containers[0].image}'
Write-Host ""

# Mostrar pods del gateway
Write-Host "`nPods del Gateway:" -ForegroundColor Green
kubectl get pods -l app=gateway -n genosentinel -o wide

Write-Host "`n=== Deployment completado ===" -ForegroundColor Cyan
