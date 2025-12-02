# GenoSentinel - Resumen Rápido de Kubernetes

## 🎯 Comandos Esenciales

### Desplegar

```bash
# Windows
.\k8s\deploy.ps1

# Linux/Mac
./k8s/deploy.sh
```

### Verificar

```bash
kubectl get all -n genosentinel
kubectl get pods -n genosentinel -w
```

### Logs

```bash
kubectl logs -n genosentinel -l app=gateway -f
kubectl logs -n genosentinel -l app=genomica-service -f
kubectl logs -n genosentinel -l app=clinica-service -f
```

### Acceder

```bash
# Minikube
minikube service gateway -n genosentinel --url

# Docker Desktop / Otros
kubectl get svc gateway -n genosentinel
# Luego: http://localhost:8080 o IP mostrada
```

### Eliminar

```bash
# Windows
.\k8s\undeploy.ps1

# Linux/Mac
./k8s/undeploy.sh

# O manualmente
kubectl delete namespace genosentinel
```

## 🔧 Troubleshooting Rápido

### Pods no inician

```bash
kubectl describe pod <pod-name> -n genosentinel
kubectl logs <pod-name> -n genosentinel
```

### Imágenes no encontradas (minikube)

```bash
minikube image load genosentinel-gateway:latest
minikube image load genosentinel-genomica-service:latest
minikube image load genosentinel-clinica-service:latest
```

### Escalar servicios

```bash
kubectl scale deployment gateway -n genosentinel --replicas=3
kubectl scale deployment genomica-service -n genosentinel --replicas=5
```

## 📊 Arquitectura K8s

```
┌─────────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                    │
├─────────────────────────────────────────────────────────┤
│  Namespace: genosentinel                                │
│                                                         │
│  ┌──────────────────┐                                  │
│  │  LoadBalancer    │  (8080)                          │
│  │    gateway       │                                  │
│  └────────┬─────────┘                                  │
│           │                                             │
│  ┌────────▼──────────┐                                 │
│  │   Gateway Pod x2  │  (2 replicas)                   │
│  │   (Spring Boot)   │                                 │
│  └──┬─────────────┬──┘                                 │
│     │             │                                     │
│  ┌──▼────────┐ ┌─▼──────────┐                         │
│  │ Genomica  │ │  Clinica   │  (2 replicas cada uno)  │
│  │  Pod x2   │ │  Pod x2    │                         │
│  └──┬────────┘ └────────────┘                         │
│     │                                                   │
│  ┌──▼─────────┐                                        │
│  │ MySQL Pod  │  (PVC: 5Gi)                           │
│  │ genomica   │                                        │
│  └────────────┘                                        │
│                                                         │
│  ┌─────────────┐                                       │
│  │ MySQL Pod   │  (PVC: 5Gi)                          │
│  │  gateway    │                                       │
│  └─────────────┘                                       │
│                                                         │
│  External: MongoDB Atlas                                │
└─────────────────────────────────────────────────────────┘
```

## 📦 Recursos Creados

- **1 Namespace**: genosentinel
- **3 ConfigMaps**: gateway, genomica, clinica
- **5 Secrets**: gateway, genomica, clinica, mysql-gateway, mysql-genomica
- **2 PVCs**: gateway-mysql-pvc (5Gi), genomica-mysql-pvc (5Gi)
- **5 Deployments**: gateway (2), genomica-service (2), clinica-service (2), gateway-mysql (1), genomica-mysql (1)
- **5 Services**: gateway (LoadBalancer), genomica-service, clinica-service, gateway-mysql, genomica-mysql

## ⚡ Tips de Producción

1. **Secrets**: Cambiar valores por defecto en `secrets.yaml`
2. **Ingress**: Usar Ingress Controller en lugar de LoadBalancer
3. **SSL/TLS**: Configurar cert-manager para HTTPS
4. **Monitoring**: Agregar Prometheus + Grafana
5. **Logging**: Configurar ELK Stack o Loki
6. **Backup**: Configurar Velero para backups de PVCs
7. **Resource Limits**: Ajustar según carga real
8. **HPA**: Configurar Horizontal Pod Autoscaler

Ver [`README.md`](README.md) para documentación completa.
