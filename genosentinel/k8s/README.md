# Despliegue en Kubernetes - GenoSentinel

Este directorio contiene los manifiestos de Kubernetes para desplegar la arquitectura completa de GenoSentinel.

## 📋 Arquitectura

```
┌─────────────────┐
│   LoadBalancer  │ (Puerto 8080)
│    (Gateway)    │
└────────┬────────┘
         │
    ┌────▼────┐
    │ Gateway │ (2 réplicas)
    │ Service │
    └─┬────┬──┘
      │    │
  ┌───▼──┐ └──▼────────┐
  │Clinica│  │ Genomica │ (2 réplicas cada uno)
  │Service│  │ Service  │
  └───┬───┘  └────┬─────┘
      │           │
  MongoDB      ┌──▼──────┐
  Atlas        │  MySQL  │
               │Genomica │
               └─────────┘

  ┌──────────┐
  │  MySQL   │
  │ Gateway  │
  └──────────┘
```

## 🚀 Pre-requisitos

1. **Cluster de Kubernetes** funcionando (minikube, Docker Desktop, GKE, EKS, AKS, etc.)
2. **kubectl** instalado y configurado
3. **Imágenes Docker** construidas localmente:
   ```bash
   # Desde el directorio raíz del proyecto
   docker-compose build
   ```

### Verificar pre-requisitos

```bash
# Verificar kubectl
kubectl version --client

# Verificar conexión al cluster
kubectl cluster-info

# Verificar imágenes Docker
docker images | grep genosentinel
```

Deberías ver:

- `genosentinel-gateway:latest`
- `genosentinel-genomica-service:latest`
- `genosentinel-clinica-service:latest`

## 📦 Contenido

```
k8s/
├── base/
│   ├── namespace.yaml              # Namespace genosentinel
│   ├── configmap.yaml              # ConfigMaps para cada servicio
│   ├── secrets.yaml                # Secrets (credenciales, JWT, MongoDB)
│   ├── pvc.yaml                    # PersistentVolumeClaims para MySQL
│   ├── mysql-deployments.yaml      # Deployments de bases de datos MySQL
│   ├── genomica-deployment.yaml    # Deployment del servicio Genomica
│   ├── clinica-deployment.yaml     # Deployment del servicio Clinica
│   ├── gateway-deployment.yaml     # Deployment del Gateway
│   └── services.yaml               # Services de Kubernetes
```

## 🔐 Configuración de Secrets

**⚠️ IMPORTANTE**: Antes de desplegar en producción, actualiza los secrets en `secrets.yaml`:

```yaml
# Cambia estos valores:
- JWT_SECRET: "tu-secret-jwt-seguro-de-minimo-256-bits"
- MYSQL_ROOT_PASSWORD: "contraseña-segura"
- MYSQL_PASSWORD: "contraseña-segura"
- MONGODB_URI: "tu-connection-string-de-mongodb-atlas"
```

## 🚀 Despliegue

### Opción 1: Despliegue completo (recomendado)

```bash
# Aplicar todos los manifiestos en orden
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secrets.yaml
kubectl apply -f k8s/base/pvc.yaml
kubectl apply -f k8s/base/mysql-deployments.yaml

# Esperar a que MySQL esté listo (puede tomar 1-2 minutos)
kubectl wait --for=condition=ready pod -l app=gateway-mysql -n genosentinel --timeout=300s
kubectl wait --for=condition=ready pod -l app=genomica-mysql -n genosentinel --timeout=300s

# Desplegar servicios de aplicación
kubectl apply -f k8s/base/genomica-deployment.yaml
kubectl apply -f k8s/base/clinica-deployment.yaml

# Esperar a que los servicios estén listos
kubectl wait --for=condition=ready pod -l app=genomica-service -n genosentinel --timeout=300s
kubectl wait --for=condition=ready pod -l app=clinica-service -n genosentinel --timeout=300s

# Desplegar Gateway
kubectl apply -f k8s/base/gateway-deployment.yaml

# Exponer servicios
kubectl apply -f k8s/base/services.yaml
```

### Opción 2: Script de despliegue rápido

```bash
# Crear script de despliegue
cat > deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Desplegando GenoSentinel en Kubernetes..."

echo "📦 Aplicando namespace..."
kubectl apply -f k8s/base/namespace.yaml

echo "⚙️  Aplicando configuraciones..."
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secrets.yaml
kubectl apply -f k8s/base/pvc.yaml

echo "🗄️  Desplegando bases de datos MySQL..."
kubectl apply -f k8s/base/mysql-deployments.yaml

echo "⏳ Esperando a que MySQL esté listo..."
kubectl wait --for=condition=ready pod -l app=gateway-mysql -n genosentinel --timeout=300s
kubectl wait --for=condition=ready pod -l app=genomica-mysql -n genosentinel --timeout=300s

echo "🧬 Desplegando servicios de aplicación..."
kubectl apply -f k8s/base/genomica-deployment.yaml
kubectl apply -f k8s/base/clinica-deployment.yaml

echo "⏳ Esperando a que los servicios estén listos..."
kubectl wait --for=condition=ready pod -l app=genomica-service -n genosentinel --timeout=300s
kubectl wait --for=condition=ready pod -l app=clinica-service -n genosentinel --timeout=300s

echo "🌐 Desplegando Gateway..."
kubectl apply -f k8s/base/gateway-deployment.yaml
kubectl apply -f k8s/base/services.yaml

echo "✅ Despliegue completado!"
echo ""
echo "📊 Estado del cluster:"
kubectl get pods -n genosentinel
echo ""
echo "🌐 Servicios:"
kubectl get svc -n genosentinel
EOF

chmod +x deploy.sh
./deploy.sh
```

## 🔍 Verificación del Despliegue

### Ver estado de los pods

```bash
kubectl get pods -n genosentinel
```

Esperado: Todos los pods en estado `Running` con `READY 1/1` o `2/2`

### Ver logs de un servicio

```bash
# Gateway
kubectl logs -n genosentinel -l app=gateway --tail=50 -f

# Genomica
kubectl logs -n genosentinel -l app=genomica-service --tail=50 -f

# Clinica
kubectl logs -n genosentinel -l app=clinica-service --tail=50 -f
```

### Ver servicios

```bash
kubectl get svc -n genosentinel
```

### Obtener URL del Gateway

```bash
# Para minikube
minikube service gateway -n genosentinel --url

# Para Docker Desktop
# El LoadBalancer estará disponible en localhost:8080

# Para cloud providers (GKE, EKS, AKS)
kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## 🧪 Probar el Despliegue

### 1. Health Check

```bash
GATEWAY_URL=$(kubectl get svc gateway -n genosentinel -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Si usas minikube
GATEWAY_URL=$(minikube service gateway -n genosentinel --url)

# Si usas Docker Desktop
GATEWAY_URL="http://localhost:8080"

# Probar endpoint de salud
curl $GATEWAY_URL/actuator/health
```

### 2. Registrar un usuario

```bash
curl -X POST $GATEWAY_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Test1234!",
    "fullName": "Test User",
    "email": "test@example.com"
  }'
```

### 3. Login

```bash
curl -X POST $GATEWAY_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Test1234!"
  }'
```

Guarda el token JWT de la respuesta.

### 4. Probar proxy a Clinica

```bash
TOKEN="<tu-jwt-token>"

curl -X GET $GATEWAY_URL/api/clinica/patients \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Probar proxy a Genomica

```bash
curl -X GET $GATEWAY_URL/api/genomica/genes/ \
  -H "Authorization: Bearer $TOKEN"
```

## 📊 Monitoreo

### Dashboard de Kubernetes (minikube)

```bash
minikube dashboard
```

### Ver recursos utilizados

```bash
kubectl top pods -n genosentinel
kubectl top nodes
```

### Descripción detallada de un pod

```bash
kubectl describe pod <pod-name> -n genosentinel
```

## 🔄 Escalado

### Escalar manualmente

```bash
# Escalar Gateway a 3 réplicas
kubectl scale deployment gateway -n genosentinel --replicas=3

# Escalar Genomica a 4 réplicas
kubectl scale deployment genomica-service -n genosentinel --replicas=4
```

### Ver réplicas actuales

```bash
kubectl get deployments -n genosentinel
```

## 🛠️ Troubleshooting

### Pod no inicia

```bash
# Ver eventos
kubectl get events -n genosentinel --sort-by='.lastTimestamp'

# Describir pod
kubectl describe pod <pod-name> -n genosentinel

# Ver logs
kubectl logs <pod-name> -n genosentinel
```

### Imágenes no encontradas

Si ves error `ImagePullBackOff`:

1. **Para minikube**: Carga las imágenes en minikube

   ```bash
   minikube image load genosentinel-gateway:latest
   minikube image load genosentinel-genomica-service:latest
   minikube image load genosentinel-clinica-service:latest
   ```

2. **Para Docker Desktop**: Las imágenes locales deben estar disponibles automáticamente

3. **Para cloud**: Sube las imágenes a un registry (Docker Hub, GCR, ECR, ACR)

   ```bash
   # Ejemplo con Docker Hub
   docker tag genosentinel-gateway:latest usuario/genosentinel-gateway:latest
   docker push usuario/genosentinel-gateway:latest

   # Actualiza el deployment para usar la imagen del registry
   kubectl set image deployment/gateway gateway=usuario/genosentinel-gateway:latest -n genosentinel
   ```

### Base de datos no conecta

```bash
# Verificar que MySQL esté corriendo
kubectl get pods -n genosentinel | grep mysql

# Conectar al pod de MySQL para debug
kubectl exec -it <mysql-pod-name> -n genosentinel -- mysql -u root -p
```

### MongoDB Atlas no conecta

- Verifica que la IP `0.0.0.0/0` esté en la whitelist de MongoDB Atlas
- Verifica que el connection string en `secrets.yaml` sea correcto

## 🗑️ Eliminar el Despliegue

### Eliminar todo

```bash
kubectl delete namespace genosentinel
```

### Eliminar componentes individuales

```bash
kubectl delete -f k8s/base/gateway-deployment.yaml
kubectl delete -f k8s/base/clinica-deployment.yaml
kubectl delete -f k8s/base/genomica-deployment.yaml
kubectl delete -f k8s/base/mysql-deployments.yaml
kubectl delete -f k8s/base/services.yaml
kubectl delete -f k8s/base/pvc.yaml
kubectl delete -f k8s/base/secrets.yaml
kubectl delete -f k8s/base/configmap.yaml
kubectl delete -f k8s/base/namespace.yaml
```

## 📝 Notas Adicionales

### Consideraciones de Producción

1. **Secrets Management**: Usa herramientas como Sealed Secrets, External Secrets, o Vault
2. **Ingress**: Considera usar un Ingress Controller (nginx, traefik) en lugar de LoadBalancer
3. **TLS/SSL**: Configura certificados SSL (cert-manager + Let's Encrypt)
4. **Monitoring**: Instala Prometheus + Grafana para monitoreo
5. **Logging**: Configura agregación de logs (ELK Stack, Loki)
6. **Backup**: Implementa estrategia de backup para PVCs
7. **Resource Limits**: Ajusta requests/limits según carga real
8. **High Availability**: Despliega en múltiples zonas de disponibilidad

### Almacenamiento Persistente

Los PVCs usan `storageClassName: standard`. Ajusta según tu cluster:

- **Minikube**: `standard` (hostPath)
- **GKE**: `standard` o `premium-rwo`
- **EKS**: `gp2` o `gp3`
- **AKS**: `default` o `managed-premium`

## 🆘 Soporte

Para issues o preguntas sobre el despliegue, consulta:

- Logs de los pods: `kubectl logs -n genosentinel <pod-name>`
- Eventos: `kubectl get events -n genosentinel`
- Documentación de Kubernetes: https://kubernetes.io/docs/
