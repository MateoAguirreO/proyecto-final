# ✅ GenoSentinel - Configuración Kubernetes Completada

## 📦 Archivos Creados

Se han creado **17 archivos** para el despliegue en Kubernetes:

### 📁 Estructura

```
genosentinel/
└── k8s/
    ├── base/                              # Manifiestos de Kubernetes
    │   ├── namespace.yaml                 # Namespace genosentinel
    │   ├── configmap.yaml                 # ConfigMaps (3 servicios)
    │   ├── secrets.yaml                   # Secrets (5 secrets)
    │   ├── pvc.yaml                       # PersistentVolumeClaims (2)
    │   ├── mysql-deployments.yaml         # MySQL deployments (2)
    │   ├── genomica-deployment.yaml       # Genomica deployment (2 replicas)
    │   ├── clinica-deployment.yaml        # Clinica deployment (2 replicas)
    │   ├── gateway-deployment.yaml        # Gateway deployment (2 replicas)
    │   ├── services.yaml                  # Services (5)
    │   └── kustomization.yaml             # Kustomize config
    │
    ├── deploy.ps1                         # Script de despliegue (Windows)
    ├── deploy.sh                          # Script de despliegue (Linux/Mac)
    ├── undeploy.ps1                       # Script de eliminación (Windows)
    ├── undeploy.sh                        # Script de eliminación (Linux/Mac)
    │
    ├── README.md                          # Documentación completa (11.5 KB)
    ├── QUICKSTART.md                      # Guía rápida (5.3 KB)
    └── EXAMPLES.md                        # Ejemplos de uso (9.4 KB)
```

## 🚀 Pasos para Desplegar

### 1. Pre-requisitos

✅ Cluster de Kubernetes funcionando:

- **Minikube**: `minikube start`
- **Docker Desktop**: Habilitar Kubernetes en Settings
- **Cloud**: GKE, EKS, AKS configurado

✅ `kubectl` instalado y configurado:

```bash
kubectl version --client
kubectl cluster-info
```

✅ Imágenes Docker construidas:

```bash
# Desde genosentinel/
docker-compose build
```

### 2. Desplegar

**Windows PowerShell:**

```powershell
cd genosentinel
.\k8s\deploy.ps1
```

**Linux/Mac:**

```bash
cd genosentinel
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

**O manualmente con kubectl:**

```bash
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/secrets.yaml
kubectl apply -f k8s/base/pvc.yaml
kubectl apply -f k8s/base/mysql-deployments.yaml
kubectl apply -f k8s/base/genomica-deployment.yaml
kubectl apply -f k8s/base/clinica-deployment.yaml
kubectl apply -f k8s/base/gateway-deployment.yaml
kubectl apply -f k8s/base/services.yaml
```

**O usando Kustomize:**

```bash
kubectl apply -k k8s/base/
```

### 3. Verificar

```bash
# Ver todos los recursos
kubectl get all -n genosentinel

# Ver pods
kubectl get pods -n genosentinel

# Ver servicios
kubectl get svc -n genosentinel

# Ver logs del Gateway
kubectl logs -n genosentinel -l app=gateway -f
```

### 4. Acceder al Gateway

**Minikube:**

```bash
minikube service gateway -n genosentinel --url
```

**Docker Desktop:**

```
http://localhost:8080
```

**Cloud Providers:**

```bash
kubectl get svc gateway -n genosentinel
# Usar la EXTERNAL-IP mostrada
```

### 5. Probar

```bash
# Health check
curl http://<GATEWAY_URL>/actuator/health

# Registrar usuario
curl -X POST http://<GATEWAY_URL>/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "Test1234!",
    "fullName": "Test User",
    "email": "test@example.com"
  }'

# Login y obtener token
curl -X POST http://<GATEWAY_URL>/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test1234!"}'
```

Ver [`k8s/EXAMPLES.md`](k8s/EXAMPLES.md) para más ejemplos.

## 📊 Recursos Desplegados

| Recurso         | Cantidad | Descripción                                          |
| --------------- | -------- | ---------------------------------------------------- |
| **Namespace**   | 1        | `genosentinel`                                       |
| **ConfigMaps**  | 3        | gateway-config, genomica-config, clinica-config      |
| **Secrets**     | 5        | Credenciales de BD, JWT, MongoDB                     |
| **PVCs**        | 2        | 5Gi para cada MySQL                                  |
| **Deployments** | 5        | Gateway (2), Genomica (2), Clinica (2), MySQL x2 (1) |
| **Services**    | 5        | Gateway (LoadBalancer), 4x ClusterIP                 |
| **Pods**        | ~7-9     | Dependiendo de réplicas                              |

### Asignación de Recursos por Pod

| Servicio       | Requests            | Limits               |
| -------------- | ------------------- | -------------------- |
| Gateway        | 500m CPU, 768Mi RAM | 1000m CPU, 1.5Gi RAM |
| Genomica       | 250m CPU, 512Mi RAM | 1000m CPU, 1Gi RAM   |
| Clinica        | 200m CPU, 256Mi RAM | 500m CPU, 512Mi RAM  |
| MySQL Gateway  | 250m CPU, 512Mi RAM | 500m CPU, 1Gi RAM    |
| MySQL Genomica | 250m CPU, 512Mi RAM | 500m CPU, 1Gi RAM    |

**Total estimado (con 2 réplicas):**

- CPU Requests: ~2.7 cores
- CPU Limits: ~6.5 cores
- RAM Requests: ~4.3 GB
- RAM Limits: ~8.5 GB

## 🔧 Configuración Importante

### ⚠️ Secrets de Producción

**Antes de desplegar en producción**, actualiza estos valores en `k8s/base/secrets.yaml`:

```yaml
# JWT Secret (mínimo 256 bits)
JWT_SECRET: "CAMBIAR-POR-UN-SECRET-SUPER-SEGURO-DE-MINIMO-256-BITS"

# Contraseñas MySQL
MYSQL_ROOT_PASSWORD: "contraseña-root-segura"
MYSQL_PASSWORD: "contraseña-usuario-segura"

# MongoDB Atlas
MONGODB_URI: "tu-connection-string-de-mongodb-atlas"
```

### 🔒 Aplicar secrets actualizados

```bash
kubectl apply -f k8s/base/secrets.yaml
kubectl rollout restart deployment -n genosentinel
```

## 📚 Documentación

| Archivo                                  | Contenido                           |
| ---------------------------------------- | ----------------------------------- |
| [`k8s/README.md`](k8s/README.md)         | Documentación completa (11 KB)      |
| [`k8s/QUICKSTART.md`](k8s/QUICKSTART.md) | Guía rápida y comandos esenciales   |
| [`k8s/EXAMPLES.md`](k8s/EXAMPLES.md)     | Ejemplos de uso y scripts de prueba |

## 🎯 Características Clave

✅ **Alta Disponibilidad**

- 2 réplicas de Gateway, Genomica y Clinica
- Health checks (liveness + readiness)
- Init containers para esperar dependencias

✅ **Almacenamiento Persistente**

- PersistentVolumeClaims (5Gi cada uno)
- Datos MySQL persisten entre reinicios

✅ **Seguridad**

- Secrets de Kubernetes para credenciales
- JWT con 256-bit secret
- Network policies ready

✅ **Escalabilidad**

- Fácil escalado horizontal: `kubectl scale`
- Resource limits configurados
- Ready para HPA (Horizontal Pod Autoscaler)

✅ **Observabilidad**

- Health checks en todos los servicios
- Logs centralizados con `kubectl logs`
- Ready para Prometheus/Grafana

## 🔄 Operaciones Comunes

### Escalar servicios

```bash
kubectl scale deployment gateway -n genosentinel --replicas=3
kubectl scale deployment genomica-service -n genosentinel --replicas=5
```

### Ver logs

```bash
kubectl logs -n genosentinel -l app=gateway -f
kubectl logs -n genosentinel -l app=genomica-service -f
kubectl logs -n genosentinel -l app=clinica-service -f
```

### Reiniciar servicios

```bash
kubectl rollout restart deployment/gateway -n genosentinel
kubectl rollout restart deployment/genomica-service -n genosentinel
kubectl rollout restart deployment/clinica-service -n genosentinel
```

### Port-forward para debug

```bash
kubectl port-forward -n genosentinel svc/gateway 8080:8080
kubectl port-forward -n genosentinel svc/genomica-service 8000:8000
kubectl port-forward -n genosentinel svc/clinica-service 3000:3000
```

### Eliminar todo

```bash
# Usando script
.\k8s\undeploy.ps1    # Windows
./k8s/undeploy.sh     # Linux/Mac

# O manualmente
kubectl delete namespace genosentinel
```

## 🐛 Troubleshooting

### Pods no inician

```bash
kubectl describe pod <pod-name> -n genosentinel
kubectl logs <pod-name> -n genosentinel
kubectl get events -n genosentinel --sort-by='.lastTimestamp'
```

### ImagePullBackOff (Minikube)

```bash
minikube image load genosentinel-gateway:latest
minikube image load genosentinel-genomica-service:latest
minikube image load genosentinel-clinica-service:latest
```

### Base de datos no conecta

```bash
kubectl exec -it <mysql-pod> -n genosentinel -- mysql -u root -p
```

## 🚀 Próximos Pasos (Producción)

1. **Ingress Controller**

   - Instalar nginx-ingress o traefik
   - Configurar rutas en lugar de LoadBalancer

2. **TLS/SSL**

   - Instalar cert-manager
   - Configurar Let's Encrypt

3. **Monitoring**

   - Prometheus + Grafana
   - AlertManager

4. **Logging**

   - ELK Stack o Loki
   - Agregación centralizada

5. **CI/CD**

   - GitHub Actions / GitLab CI
   - ArgoCD para GitOps

6. **Backup**

   - Velero para backups de PVCs
   - Estrategia de DR

7. **Security**
   - Network Policies
   - Pod Security Policies
   - External Secrets Operator

## ✨ Resumen

Has configurado exitosamente GenoSentinel para Kubernetes con:

- ✅ 17 archivos de configuración
- ✅ Scripts automatizados de despliegue
- ✅ Documentación completa
- ✅ Ejemplos de uso
- ✅ Alta disponibilidad (2 réplicas)
- ✅ Almacenamiento persistente
- ✅ Health checks configurados
- ✅ Resource limits optimizados

**¡Tu aplicación está lista para desplegarse en Kubernetes!** 🎉

Para empezar: `.\k8s\deploy.ps1` (Windows) o `./k8s/deploy.sh` (Linux/Mac)
