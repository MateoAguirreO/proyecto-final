# Script para eliminar el despliegue de GenoSentinel en Kubernetes (Windows PowerShell)

Write-Host "`nEliminando despliegue de GenoSentinel...`n" -ForegroundColor Yellow

# Verificar que kubectl está disponible
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Error: kubectl no está instalado" -ForegroundColor Red
    exit 1
}

# Preguntar confirmación
$confirmation = Read-Host "¿Estás seguro que deseas eliminar todo el despliegue de GenoSentinel? (y/N)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "`nCancelado`n" -ForegroundColor Red
    exit 1
}

Write-Host "`nEliminando namespace genosentinel y todos sus recursos..." -ForegroundColor Yellow
kubectl delete namespace genosentinel

Write-Host "`nDespliegue eliminado completamente`n" -ForegroundColor Green

Write-Host "Para volver a desplegar, ejecuta:" -ForegroundColor Cyan
Write-Host "   .\k8s\deploy.ps1`n" -ForegroundColor White
