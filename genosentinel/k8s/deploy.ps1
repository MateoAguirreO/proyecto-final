# Script de despliegue para GenoSentinel en Kubernetes (Windows PowerShell)

Write-Host "`nDesplegando GenoSentinel en Kubernetes...`n" -ForegroundColor Cyan

# Verificar que kubectl está disponible
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "Error: kubectl no está instalado" -ForegroundColor Red
    exit 1
}

# Verificar conexión al cluster
Write-Host "Verificando conexión al cluster..." -ForegroundColor Yellow
try {
    kubectl cluster-info | Out-Null
    Write-Host "Conectado al cluster`n" -ForegroundColor Green
} catch {
    Write-Host "Error: No se puede conectar al cluster de Kubernetes" -ForegroundColor Red
    exit 1
}

# Verificar que las imágenes existen
Write-Host "Verificando imágenes Docker..." -ForegroundColor Yellow
$images = docker images --format "{{.Repository}}"

if ($images -notcontains "genosentinel-gateway") {
    Write-Host "Advertencia: Imagen genosentinel-gateway:latest no encontrada" -ForegroundColor Yellow
    Write-Host "   Ejecuta: docker-compose build gateway" -ForegroundColor Yellow
}

if ($images -notcontains "genosentinel-genomica-service") {
    Write-Host "Advertencia: Imagen genosentinel-genomica-service:latest no encontrada" -ForegroundColor Yellow
    Write-Host "   Ejecuta: docker-compose build genomica-service" -ForegroundColor Yellow
}

if ($images -notcontains "genosentinel-clinica-service") {
    Write-Host "Advertencia: Imagen genosentinel-clinica-service:latest no encontrada" -ForegroundColor Yellow
    Write-Host "   Ejecuta: docker-compose build clinica-service" -ForegroundColor Yellow
}

Write-Host ""

# Para minikube, cargar imágenes
if (Get-Command minikube -ErrorAction SilentlyContinue) {
    try {
        $minikubeStatus = minikube status 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Minikube detectado, cargando imágenes..." -ForegroundColor Cyan
            minikube image load genosentinel-gateway:latest 2>$null
            minikube image load genosentinel-genomica-service:latest 2>$null
            minikube image load genosentinel-clinica-service:latest 2>$null
            Write-Host "Imágenes cargadas en minikube`n" -ForegroundColor Green
        }
    } catch {
        # Minikube no está corriendo, continuar
    }
}

# Aplicar manifiestos
Write-Host "Aplicando namespace..." -ForegroundColor Cyan
kubectl apply -f k8s/base/namespace.yaml

Write-Host "Aplicando configuraciones..." -ForegroundColor Cyan
kubectl apply -f k8s/base/storageclass.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secrets.yaml
kubectl apply -f k8s/base/pvc.yaml

Write-Host "Desplegando bases de datos MySQL..." -ForegroundColor Cyan
kubectl apply -f k8s/base/mysql-deployments.yaml

Write-Host "Esperando a que MySQL esté listo (puede tomar 1-2 minutos)..." -ForegroundColor Yellow
try {
    kubectl wait --for=condition=ready pod -l app=gateway-mysql -n genosentinel --timeout=300s 2>$null
} catch {
    Write-Host "Timeout esperando gateway-mysql" -ForegroundColor Yellow
}

try {
    kubectl wait --for=condition=ready pod -l app=genomica-mysql -n genosentinel --timeout=300s 2>$null
} catch {
    Write-Host "Timeout esperando genomica-mysql" -ForegroundColor Yellow
}

Write-Host "Desplegando servicios de aplicación..." -ForegroundColor Cyan
kubectl apply -f k8s/base/genomica-deployment.yaml
kubectl apply -f k8s/base/clinica-deployment.yaml

Write-Host "Esperando a que los servicios estén listos..." -ForegroundColor Yellow
try {
    kubectl wait --for=condition=ready pod -l app=genomica-service -n genosentinel --timeout=300s 2>$null
} catch {
    Write-Host "Timeout esperando genomica-service" -ForegroundColor Yellow
}

try {
    kubectl wait --for=condition=ready pod -l app=clinica-service -n genosentinel --timeout=300s 2>$null
} catch {
    Write-Host "Timeout esperando clinica-service" -ForegroundColor Yellow
}

Write-Host "Desplegando Gateway..." -ForegroundColor Cyan
kubectl apply -f k8s/base/gateway-deployment.yaml

Write-Host "Exponiendo servicios..." -ForegroundColor Cyan
kubectl apply -f k8s/base/services.yaml

Write-Host "`nDespliegue completado!`n" -ForegroundColor Green

Write-Host "Estado del cluster:" -ForegroundColor Cyan
kubectl get pods -n genosentinel

Write-Host "`nServicios:" -ForegroundColor Cyan
kubectl get svc -n genosentinel

Write-Host ""

# Intentar obtener la URL del Gateway
if (Get-Command minikube -ErrorAction SilentlyContinue) {
    try {
        $minikubeStatus = minikube status 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "URL del Gateway (minikube):" -ForegroundColor Green
            minikube service gateway -n genosentinel --url
        }
    } catch {
        Write-Host "URL del Gateway: http://localhost:8080" -ForegroundColor Green
    }
} else {
    # Esperar a que el LoadBalancer del gateway tenga endpoint
    Write-Host "Esperando LoadBalancer del Gateway..." -ForegroundColor Yellow
    try {
        # Espera hasta 5 minutos a que el servicio tenga ingress
        $null = kubectl wait svc gateway -n genosentinel --for=jsonpath='{.status.loadBalancer.ingress[0]}' --timeout=300s 2>$null
    } catch {
        Write-Host "Timeout esperando el LoadBalancer del Gateway" -ForegroundColor Yellow
    }

    $gatewayHostname = kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    $gatewayIP = kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null

    if ($gatewayHostname) {
        Write-Host "URL del Gateway: http://$gatewayHostname:8080" -ForegroundColor Green
    } elseif ($gatewayIP) {
        Write-Host "URL del Gateway: http://$gatewayIP:8080" -ForegroundColor Green
    } else {
        Write-Host "URL del Gateway: http://localhost:8080" -ForegroundColor Green
    }
}

Write-Host "`nPara ver los logs:" -ForegroundColor Yellow
Write-Host "   kubectl logs -n genosentinel -l app=gateway -f" -ForegroundColor White

Write-Host "`nPara eliminar todo:" -ForegroundColor Yellow
Write-Host "   kubectl delete namespace genosentinel`n" -ForegroundColor White
