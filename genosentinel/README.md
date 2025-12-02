# 🔐 GenoSentinel Gateway - Microservicio de Autenticación

<div align="center">

![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.8-green?logo=springboot)
![Java](https://img.shields.io/badge/Java-17-orange?logo=java)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![JWT](https://img.shields.io/badge/JWT-Enabled-red?logo=jsonwebtokens)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)

**Gateway de autenticación con JWT y proxy a microservicios Dockerizados**

Parte del sistema GenoSentinel de Breaze Labs

</div>

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Arquitectura Docker](#-arquitectura-docker)
- [Inicio Rápido](#-inicio-rápido)
- [Despliegue en Kubernetes](#-despliegue-en-kubernetes)
- [Funcionalidades](#-funcionalidades)
- [Pruebas de Integración](#-pruebas-de-integración)
- [API Endpoints](#-api-endpoints)
- [Desarrollo Local](#-desarrollo-local)

---

## 🎯 Descripción

GenoSentinel Gateway es un microservicio de autenticación y proxy que actúa como punto de entrada unificado para el sistema GenoSentinel. Proporciona:

- **Autenticación JWT**: Emisión y validación de tokens con expiración 24h
- **Proxy HTTP**: Enrutamiento a microservicios Genomica (Django) y Clinica (NestJS)
- **Dockerización**: Multi-stage build optimizado (56MB imagen final)
- **Integración Completa**: 4 contenedores orquestados con Docker Compose

---

## 🐳 Arquitectura Docker

```
┌────────────────────────────────────────────────────────────────────────┐
│                         Docker Compose                                 │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  Network: genosentinel_network                                   │  │
│  │                                                                  │  │
│  │  ┌──────────────┐  ┌──────────────┐                            │  │
│  │  │ gateway_mysql│  │genomica_mysql│                            │  │
│  │  │  Port: 3308  │  │  Port: 3307  │                            │  │
│  │  └──────┬───────┘  └──────┬───────┘                            │  │
│  │         │                  │                                    │  │
│  │  ┌──────▼──────────────────▼──────────────────┐                │  │
│  │  │    genosentinel_gateway                    │                │  │
│  │  │  (Spring Boot + JWT)                       │                │  │
│  │  │  Port: 8080                                │                │  │
│  │  │  Image: 56MB (Alpine JRE 17)               │                │  │
│  │  └──────┬────────────────────┬─────────────────┘                │  │
│  │         │                    │                                  │  │
│  │         │ RestTemplate Proxy │                                  │  │
│  │         ▼                    ▼                                  │  │
│  │  ┌─────────────────┐  ┌──────────────────────┐                │  │
│  │  │ genomica-service│  │  clinica-service     │                │  │
│  │  │  (Django 4.2.7) │  │  (NestJS + MongoDB)  │                │  │
│  │  │  Port: 8000     │  │  Port: 3000          │                │  │
│  │  └─────────────────┘  └──────────────────────┘                │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

**Servicios:**

- `gateway_mysql` - Base de datos usuarios/auth (Puerto 3308)
- `genomica_mysql` - Base de datos genómica (Puerto 3307)
- `genosentinel_gateway` - Gateway Spring Boot (Puerto 8080)
- `genomica-service` - Microservicio Django (Puerto 8000)
- `clinica-service` - Microservicio NestJS (Puerto 3000)

---

## 🚀 Inicio Rápido

### ⚠️ Prerequisitos Importantes:

**MongoDB Atlas Whitelist (para Clinica):**

El microservicio de Clínica usa MongoDB Atlas. Debes configurar la IP whitelist:

1. Ve a tu cluster en [MongoDB Atlas](https://cloud.mongodb.com)
2. Network Access → Add IP Address
3. Agrega `0.0.0.0/0` (permitir desde cualquier IP) o la IP específica de tu red

### Levantar todo el sistema:

```bash
cd genosentinel
docker-compose up --build -d
```

### Verificar estado:

```bash
docker ps
```

Deberías ver 5 contenedores corriendo:

- ✅ gateway_mysql (healthy)
- ✅ genomica_mysql (healthy)
- ✅ genomica-service (healthy)
- ✅ clinica-service (healthy solo si MongoDB Atlas está configurado)
- ✅ genosentinel_gateway (healthy cuando todos los demás lo estén)

### Probar la integración:

```powershell
# 1. Login y obtener token
$login = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
  -Method POST `
  -Body '{"username":"testuser","password":"Test123!"}' `
  -ContentType "application/json"

# 2. Consultar genes a través del gateway
$headers = @{Authorization = "Bearer $($login.token)"}
Invoke-RestMethod -Uri "http://localhost:8080/api/genomica/genes/" -Headers $headers
```

---

## ☸️ Despliegue en Kubernetes

GenoSentinel está listo para desplegarse en Kubernetes con manifiestos completos y scripts automatizados.

### 📁 Estructura K8s

```
k8s/
├── base/
│   ├── namespace.yaml              # Namespace genosentinel
│   ├── configmap.yaml              # Configuraciones
│   ├── secrets.yaml                # Credenciales y JWT
│   ├── pvc.yaml                    # Almacenamiento persistente
│   ├── mysql-deployments.yaml      # Bases de datos
│   ├── genomica-deployment.yaml    # Servicio Genomica
│   ├── clinica-deployment.yaml     # Servicio Clinica
│   ├── gateway-deployment.yaml     # Gateway
│   └── services.yaml               # Exposición de servicios
├── deploy.ps1                      # Script de despliegue (Windows)
├── deploy.sh                       # Script de despliegue (Linux/Mac)
└── README.md                       # Documentación completa
```

### 🚀 Despliegue Rápido

**Windows PowerShell:**

```powershell
.\k8s\deploy.ps1
```

**Linux/Mac:**

```bash
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

### 🔍 Verificar Despliegue

```bash
# Ver pods
kubectl get pods -n genosentinel

# Ver servicios
kubectl get svc -n genosentinel

# Ver logs del Gateway
kubectl logs -n genosentinel -l app=gateway -f
```

### 🌐 Acceder al Gateway

```bash
# Para minikube
minikube service gateway -n genosentinel --url

# Para Docker Desktop
http://localhost:8080

# Para cloud providers
kubectl get svc gateway -n genosentinel
```

### 📊 Características del Despliegue K8s

- ✅ **Alta Disponibilidad**: 2 réplicas de cada servicio de aplicación
- ✅ **Health Checks**: Liveness y Readiness probes configurados
- ✅ **Almacenamiento Persistente**: PVCs para bases de datos MySQL
- ✅ **Secrets Management**: Credenciales en Kubernetes Secrets
- ✅ **Resource Limits**: CPU y memoria controlados
- ✅ **Init Containers**: Espera a que dependencias estén listas
- ✅ **LoadBalancer**: Gateway expuesto externamente

### 📚 Documentación Completa

Para instrucciones detalladas de Kubernetes, consulta: [`k8s/README.md`](k8s/README.md)

Incluye:

- Pre-requisitos y configuración
- Manejo de imágenes Docker
- Troubleshooting completo
- Escalado y monitoreo
- Consideraciones de producción

---

## ✨ Funcionalidades

### 🔑 Autenticación JWT

**Registro:**

```bash
POST /api/auth/register
{
  "username": "usuario",
  "password": "Pass123!",
  "fullName": "Nombre Completo",
  "email": "email@example.com",
  "role": "USER"
}
```

**Login:**

```bash
POST /api/auth/login
{
  "username": "usuario",
  "password": "Pass123!"
}

# Respuesta:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "usuario",
  "fullName": "Nombre Completo",
  "email": "email@example.com",
  "role": "USER",
  "expiresIn": 86400000
}
```

### 🌐 Proxy a Microservicios

**Gateway → Genomica:**

```bash
GET /api/genomica/genes/              # Lista genes
GET /api/genomica/genes/1/            # Gene específico
GET /api/genomica/variants/           # Variantes genéticas
GET /api/genomica/patient-reports/    # Reportes de pacientes
```

**Gateway → Clinica:**

```bash
GET /api/clinica/**                   # Proxy a NestJS (clinica-service:3000)
```

**Características del Proxy:**

- ✅ Reenvío automático de JWT en headers
- ✅ Propagación de query strings
- ✅ Soporte completo HTTP (GET, POST, PUT, PATCH, DELETE)
- ✅ Manejo de errores desde microservicios

### 🏥 Monitoreo

```bash
GET /api/status     # Estado del gateway
GET /api/health     # Health check detallado
GET /api/info       # Información del servicio
```

---

## 🧪 Pruebas de Integración

### Script Completo de Pruebas

```powershell
# 1. Registro de usuario
Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" `
  -Method POST `
  -Body '{"username":"test","password":"Test123!","fullName":"Test User","email":"test@test.com","role":"USER"}' `
  -ContentType "application/json"

# 2. Login
$login = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
  -Method POST `
  -Body '{"username":"test","password":"Test123!"}' `
  -ContentType "application/json"

$headers = @{Authorization = "Bearer $($login.token)"}

# 3. Probar acceso sin token (debe retornar 403)
try {
  Invoke-RestMethod -Uri "http://localhost:8080/api/genomica/genes/"
} catch {
  Write-Host "✓ 403 Forbidden (correcto)"
}

# 4. Consultar genes con token
$genes = Invoke-RestMethod -Uri "http://localhost:8080/api/genomica/genes/" -Headers $headers
Write-Host "✓ Genes: $($genes.count) registros"

# 5. Consultar variantes
$variants = Invoke-RestMethod -Uri "http://localhost:8080/api/genomica/variants/" -Headers $headers
Write-Host "✓ Variantes: $($variants.count) registros"

# 6. Consultar reportes
$reports = Invoke-RestMethod -Uri "http://localhost:8080/api/genomica/patient-reports/" -Headers $headers
Write-Host "✓ Reportes: $($reports.count) registros"
```

### Resultados Esperados

```
✓ Contenedores: 4/4 healthy
✓ Registro: Usuario creado
✓ Login: Token JWT generado
✓ Seguridad: 403 sin autenticación
✓ Proxy Genes: 3 registros (BRCA1, KRAS, TP53)
✓ Proxy Variantes: 12 registros
✓ Proxy Reportes: 6 registros
```

---

## 📚 API Endpoints

### Autenticación

| Método | Endpoint             | Descripción             | Auth |
| ------ | -------------------- | ----------------------- | ---- |
| POST   | `/api/auth/register` | Registrar nuevo usuario | ❌   |
| POST   | `/api/auth/login`    | Iniciar sesión          | ❌   |

### Proxy a Genomica

| Método | Endpoint                         | Descripción           | Auth |
| ------ | -------------------------------- | --------------------- | ---- |
| GET    | `/api/genomica/genes/`           | Listar genes          | ✅   |
| GET    | `/api/genomica/genes/{id}/`      | Gene por ID           | ✅   |
| GET    | `/api/genomica/variants/`        | Listar variantes      | ✅   |
| GET    | `/api/genomica/patient-reports/` | Reportes de pacientes | ✅   |

### Proxy a Clinica

| Método | Endpoint          | Descripción    | Auth |
| ------ | ----------------- | -------------- | ---- |
| ANY    | `/api/clinica/**` | Proxy a NestJS | ✅   |

### Monitoreo

| Método | Endpoint      | Descripción       | Auth |
| ------ | ------------- | ----------------- | ---- |
| GET    | `/api/status` | Estado rápido     | ❌   |
| GET    | `/api/health` | Health check      | ❌   |
| GET    | `/api/info`   | Info del servicio | ❌   |

---

## 💻 Desarrollo Local

### Sin Docker (desarrollo):

```bash
# 1. Crear base de datos
mysql -u root -p
CREATE DATABASE genosentinel_db;

# 2. Configurar application.properties
spring.datasource.url=jdbc:mysql://localhost:3306/genosentinel_db
spring.datasource.username=tu_usuario
spring.datasource.password=tu_password

# 3. Ejecutar
./mvnw spring-boot:run
```

### Con Docker (producción):

```bash
# Reconstruir todo
docker-compose down
docker-compose up --build -d

# Ver logs
docker logs -f genosentinel_gateway
docker logs -f genomica-service

# Detener
docker-compose down
```

### Tecnologías

- **Framework**: Spring Boot 3.5.8
- **Java**: 17 (Eclipse Temurin Alpine)
- **Seguridad**: Spring Security + JWT (JJWT 0.11.5)
- **Base de Datos**: MySQL 8.0
- **HTTP Client**: RestTemplate
- **Contenedores**: Docker + Docker Compose

---

## 🔧 Solución de Problemas

### Error: "Port already allocated"

```bash
# Eliminar contenedores antiguos
docker rm -f genomica_service genomica-service
docker-compose up -d
```

### Error: "DisallowedHost" en Django

**Causa**: Nombres de servicio Docker con underscore (`_`) violan RFC 1034/1035.

**Solución**: Usar guiones (`-`) en nombres de servicios:

```yaml
# docker-compose.yml
services:
  genomica-service:# ✅ Correcto
  # NO usar: genomica_service  # ❌ Causa error Django
```

### Verificar conectividad entre contenedores

```bash
docker exec -it genosentinel_gateway ping genomica-service
docker exec -it genosentinel_gateway wget -O- http://genomica-service:8000/api/v1/genes/
```

---

## 📝 Notas Importantes

1. **Nombres de servicio Docker**: Usar guiones (`-`), no underscores (`_`)
2. **JWT Expiration**: Tokens válidos por 24 horas (86400000 ms)
3. **CORS**: Configurado para `localhost:3000`, `localhost:4200`, `localhost:8080`
4. **Health Checks**: Esperar ~60s para que todos los servicios estén healthy
5. **Logs**: `docker logs <container>` para debugging

---

## 👨‍💻 Autor

**Breaze Labs - GenoSentinel Team**

Sistema de microservicios para análisis genómico y gestión clínica.

---

## 📄 Licencia

MIT License - Ver archivo LICENSE para más detalles.

## 👨‍💻 Autor

**Breaze Labs - GenoSentinel Team**

Sistema de microservicios para análisis genómico y gestión clínica.

---

## 📄 Licencia

MIT License - Ver archivo LICENSE para más detalles.

{
"username": "doctor1",
"password": "password123",
"fullName": "Dr. Carlos Méndez",
"email": "carlos@hospital.com"
}

````

**Respuesta:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "username": "doctor1",
  "fullName": "Dr. Carlos Méndez",
  "email": "carlos@hospital.com",
  "role": "USER",
  "expiresIn": 86400000
}
````

#### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "doctor1",
  "password": "password123"
}
```

**Respuesta:** Igual que registro

---

### Gateway / Proxy

#### Acceder a Microservicio de Clínica

```http
GET /api/gateway/clinica/api/patients
Authorization: Bearer <token>
```

Se redirige a: `http://localhost:3000/api/patients`

#### Acceder a Microservicio de Genómica

```http
GET /api/gateway/genomica/api/v1/genes/
Authorization: Bearer <token>
```

Se redirige a: `http://localhost:8000/api/v1/genes/`

#### Crear recurso a través del Gateway

```http
POST /api/gateway/genomica/api/v1/genes/
Authorization: Bearer <token>
Content-Type: application/json

{
  "symbol": "BRCA2",
  "full_name": "Breast Cancer Type 2",
  "function_summary": "DNA repair"
}
```

---

### Monitoreo

#### Health Check

```http
GET /api/health
```

**Respuesta:**

```json
{
  "status": "UP",
  "timestamp": "2024-11-30T10:30:00",
  "service": "genosentinel",
  "version": "1.0.0",
  "database": {
    "status": "UP",
    "message": "Database connection is healthy"
  },
  "microservices": {
    "clinica": {
      "status": "UP",
      "url": "http://localhost:3000/health",
      "responseTime": 45
    },
    "genomica": {
      "status": "UP",
      "url": "http://localhost:8000/api/health",
      "responseTime": 32
    }
  }
}
```

#### Status Simple

```http
GET /api/status
```

#### Información del Servicio

```http
GET /api/info
```

---

## 🔒 Seguridad

### Arquitectura de Seguridad

1. **BCrypt Password Encoding**

   - Las contraseñas se encriptan con BCrypt (factor 10)
   - Nunca se almacenan en texto plano

2. **JWT Token**

   - Firmado con HMAC-SHA256
   - Expiración de 24 horas
   - Contiene username y authorities

3. **Filtro de Autenticación**

   - `JwtAuthenticationFilter` intercepta todas las peticiones
   - Valida el token en el header `Authorization: Bearer <token>`
   - Configura el SecurityContext

4. **Spring Security Configuration**
   - Endpoints públicos: `/api/auth/**`, `/api/health/**`, `/api/status`
   - Todos los demás requieren autenticación
   - Sesiones deshabilitadas (stateless)
   - CORS configurado para localhost:3000 y localhost:4200

### Endpoints Públicos (No requieren token)

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/health`
- `GET /api/status`
- `GET /api/info`
- `GET /actuator/**`

### Endpoints Protegidos (Requieren token)

- `GET /api/gateway/**`
- Todos los demás endpoints

---

## 🧪 Pruebas

### Usuarios de Prueba Precargados

```
Username: admin
Password: password123
Email: admin@genosentinel.com

Username: doctor
Password: password123
Email: doctor@genosentinel.com
```

### Ejemplo de Flujo Completo

```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "password123"
  }'

# Guardar el token de la respuesta
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 2. Verificar health
curl http://localhost:8080/api/health

# 3. Acceder a microservicio de Genómica vía Gateway
curl http://localhost:8080/api/gateway/genomica/api/v1/genes/ \
  -H "Authorization: Bearer $TOKEN"

# 4. Crear un gen vía Gateway
curl -X POST http://localhost:8080/api/gateway/genomica/api/v1/genes/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "TP53",
    "full_name": "Tumor Protein P53",
    "function_summary": "Guardian del genoma"
  }'
```

### Probar con PowerShell (Windows)

```powershell
# Login
$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"username":"admin","password":"password123"}'

$token = $response.token

# Usar el token
Invoke-RestMethod -Uri "http://localhost:8080/api/gateway/genomica/api/v1/genes/" `
  -Headers @{Authorization="Bearer $token"}
```

---

## 📁 Estructura del Proyecto

```
genosentinel/
├── src/
│   ├── main/
│   │   ├── java/com/gateway/genosentinel/
│   │   │   ├── config/           # Configuraciones
│   │   │   │   └── WebClientConfig.java
│   │   │   ├── controller/       # Controladores REST
│   │   │   │   ├── AuthController.java
│   │   │   │   ├── GatewayController.java
│   │   │   │   └── HealthController.java
│   │   │   ├── dto/              # Data Transfer Objects
│   │   │   │   ├── AuthResponse.java
│   │   │   │   ├── ErrorResponse.java
│   │   │   │   ├── HealthResponse.java
│   │   │   │   ├── LoginRequest.java
│   │   │   │   └── RegisterRequest.java
│   │   │   ├── entity/           # Entidades JPA
│   │   │   │   └── User.java
│   │   │   ├── exception/        # Manejo de excepciones
│   │   │   │   └── GlobalExceptionHandler.java
│   │   │   ├── repository/       # Repositorios JPA
│   │   │   │   └── UserRepository.java
│   │   │   ├── security/         # Configuración de seguridad
│   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   ├── JwtTokenProvider.java
│   │   │   │   └── SecurityConfig.java
│   │   │   ├── service/          # Servicios de negocio
│   │   │   │   ├── AuthService.java
│   │   │   │   ├── GatewayService.java
│   │   │   │   └── HealthCheckService.java
│   │   │   └── GenosentinelApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── data.sql          # Datos de prueba
│   └── test/                     # Tests unitarios
├── pom.xml                       # Dependencias Maven
├── mvnw, mvnw.cmd               # Maven wrapper
└── README.md                     # Esta documentación
```

---

## 🚢 Despliegue

### Compilar JAR ejecutable

```bash
./mvnw clean package -DskipTests

# El JAR se genera en:
# target/genosentinel-0.0.1-SNAPSHOT.jar
```

### Ejecutar JAR

```bash
java -jar target/genosentinel-0.0.1-SNAPSHOT.jar
```

### Variables de Entorno (Producción)

```bash
export DB_URL=jdbc:mysql://production-db:3306/genosentinel_db
export DB_USER=prod_user
export DB_PASSWORD=secure_password
export JWT_SECRET=your-secure-base64-secret-key
export CLINICA_URL=http://clinica-service:3000
export GENOMICA_URL=http://genomica-service:8000

java -jar genosentinel.jar
```

---

## 🤝 Integración con Microservicios

### Flujo de Petición

1. **Cliente** envía petición al Gateway con token JWT
2. **Gateway** valida el token
3. **Gateway** extrae información del usuario
4. **Gateway** reenvía la petición al microservicio correspondiente
5. **Microservicio** procesa y responde
6. **Gateway** devuelve la respuesta al cliente

### Diagrama de Secuencia

```
Cliente          Gateway          Microservicio
   │                │                    │
   │──Login────────>│                    │
   │<───Token───────│                    │
   │                │                    │
   │──GET + Token──>│                    │
   │                │──Validate Token    │
   │                │──Forward Request──>│
   │                │                    │
   │                │<──────Response─────│
   │<───Response────│                    │
```

---

## 📈 Roadmap

- [ ] Refresh tokens
- [ ] Rate limiting
- [ ] Métricas con Micrometer/Prometheus
- [ ] Logging centralizado
- [ ] Circuit breaker (Resilience4j)
- [ ] Cache distribuido (Redis)
- [ ] OpenAPI/Swagger documentation

---

## 👥 Equipo

**Proyecto**: GenoSentinel  
**Cliente**: Breaze Labs  
**Institución**: Maestría en Arquitectura de Software

---

## 📄 Licencia

Este proyecto es parte de un trabajo académico.

---

<div align="center">

**🔐 GenoSentinel Gateway - Seguridad y enrutamiento inteligente**

Desarrollado con ❤️ usando Spring Boot

[Documentación](#) • [API](#) • [Soporte](#)

</div>
