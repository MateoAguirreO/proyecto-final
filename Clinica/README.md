# 🏥 NestJS - MongoDB Clínica

<div align="center">

![NestJS](https://img.shields.io/badge/NestJS-9.x-red?logo=nestjs)
![MongoDB](https://img.shields.io/badge/MongoDB-6.0-green?logo=mongodb)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green?logo=node.js)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![License](https://img.shields.io/badge/License-MIT-yellow)

</div>

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Instalación](#-instalación)
  - [Opción 1: Docker (Recomendado)](#opción-1-docker-recomendado)
  - [Opción 2: Instalación Local](#opción-2-instalación-local)
- [Modelos de Datos](#-modelos-de-datos)
- [API Endpoints](#-api-endpoints)
- [Documentación](#-documentación)
- [Pruebas](#-pruebas)
- [Despliegue](#-despliegue)

---

## 🎯 Descripción

Microservicio desarrollado con NestJS y MongoDB para la gestión clínica (pacientes, tipos de tumor y registros clínicos). Está diseñado para integrarse con otros microservicios (p. ej. Genómica) y ser desplegado en contenedores.

### Funcionalidades principales

1. Gestión de pacientes (CRUD completo)
2. Catálogo de tipos de tumor
3. Registros clínicos/episodios asociados a pacientes
4. Validación y DTOs con `class-validator` / `class-transformer`
5. Documentación OpenAPI (Swagger)

---

## 🏗️ Arquitectura

```
Client (Angular/React)
    │
    ▼
API Gateway / Auth (Spring Boot)
    │
    ▼
Microservicio Clínica (NestJS) <--> Microservicio Genómica (Django / externo)
    │
    ▼
MongoDB (Atlas / Self-hosted)
```

**Características**

- Desacoplamiento de responsabilidades
- DTOs y validaciones en el borde (pipes)
- Contenedorizado con Docker
- Listo para Kubernetes

---

## 🚀 Tecnologías

| Categoría | Tecnología | Versión |
|---|---:|---:|
| Framework | NestJS | 9.x |
| Base de Datos | MongoDB | 6.x |
| Lenguaje | TypeScript / Node.js | 18.x |
| Documentación | @nestjs/swagger | latest |
| Tests | Jest + Supertest | latest |

---

## 💻 Instalación

### Opción 1: Docker (Recomendado)

Requisitos: Docker Desktop y Docker Compose

```bash
# Desde la raíz del proyecto
docker-compose up -d --build

# Revisar contenedores
docker ps
```

Si la imagen incluye scripts de inicialización para la BD, se ejecutarán automáticamente. Para reiniciar con BD limpia:

```bash
docker-compose down -v
docker-compose up -d --build
```

### Opción 2: Instalación Local

Requisitos: Node 18+, npm/yarn, MongoDB 6+

```bash
# 1. Instalar dependencias
npm install

# 2. Copiar variables de entorno
cp .env.example .env
# Editar `.env` con la conexión a MongoDB

# 3. Ejecutar en modo desarrollo
npm run start:dev
```

URLs por defecto (local):
- API: http://localhost:3000/
- Swagger: http://localhost:3000/api

---

## 📊 Modelos de Datos

Los siguientes modelos reflejan las entidades principales en `src/*`.

### Patient

```ts
interface Patient {
  id: string; // UUID o ObjectId
  firstName: string;
  lastName: string;
  birthDate?: string;
  gender?: string;
  identification?: string;
  createdAt?: string;
  updatedAt?: string;
}
```

### TumorType

```ts
interface TumorType {
  id: string;
  name: string; // ej: Adenocarcinoma
  description?: string;
}
```

### ClinicalRecord

```ts
interface ClinicalRecord {
  id: string;
  patientId: string; // referencia al paciente (ObjectId / UUID)
  tumorTypeId?: string;
  diagnosisDate?: string;
  notes?: string;
  createdAt?: string;
}
```

---

## 🔗 API Endpoints

### Patients

| Método | Endpoint | Descripción |
|---|---|---|
| GET | `/api/v1/patients` | Lista paginada de pacientes |
| POST | `/api/v1/patients` | Crear paciente |
| GET | `/api/v1/patients/:id` | Detalle paciente |
| PUT | `/api/v1/patients/:id` | Reemplazar paciente |
| PATCH | `/api/v1/patients/:id` | Actualizar parcialmente |
| DELETE | `/api/v1/patients/:id` | Eliminar paciente |

### TumorTypes

| Método | Endpoint | Descripción |
|---|---|---|
| GET | `/api/v1/tumortypes` | Lista de tipos de tumor |
| POST | `/api/v1/tumortypes` | Crear tipo |

### ClinicalRecords

| Método | Endpoint | Descripción |
|---|---|---|
| GET | `/api/v1/clinicalrecords` | Lista de registros clínicos |
| POST | `/api/v1/clinicalrecords` | Crear nuevo registro |
| GET | `/api/v1/clinicalrecords/:id` | Detalle registro |
| GET | `/api/v1/clinicalrecords/by_patient?patientId={id}` | Registros por paciente |

Ejemplo de creación de paciente:

```bash
curl -X POST http://localhost:3000/api/v1/patients \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Juan","lastName":"Perez","birthDate":"1980-05-01"}'
```

---

## 📚 Documentación

La API expone documentación Swagger generada por `@nestjs/swagger`.

- URL (local): `http://localhost:3000/api`

---

## 🧪 Pruebas

El proyecto usa Jest y Supertest para pruebas unitarias y e2e.

```bash
# unit tests
npm run test

# e2e tests
npm run test:e2e

# cobertura
npm run test:cov
```

---

## 🚢 Despliegue

Recomendaciones:

- Usar `NODE_ENV=production` y `npm run build` antes de iniciar
- Conectar a un cluster administrado de MongoDB (Atlas) en producción
- Configurar `ConfigMap` y `Secrets` en Kubernetes para variables sensibles

Ejemplo (heroku / contenedor):

```bash
docker build -t clinic-service:latest .
docker run -e MONGO_URI="mongodb://..." -p 3000:3000 clinic-service:latest
```

---

## 🔒 Variables de Entorno (ejemplo)

```env
# App
NODE_ENV=development
PORT=3000

# Mongo
MONGO_URI=mongodb://localhost:27017/clinic_db

# Seguridad
JWT_SECRET=change_me_in_production
```

---

## 🔐 Seguridad y Buenas Prácticas

- Validar y sanitizar entradas con `class-validator`.
- Usar HTTPS en producción.
- Guardar secretos en `Secrets` (K8s) o gestores externos.
- Implementar rate-limiting y CORS restringido.

---

## 🤝 Integración con Otros Microservicios

El microservicio puede integrarse con el Microservicio de Genómica para asociar `patientId` con reportes genómicos. El intercambio se realiza por `patientId` (UUID/ObjectId) y endpoints REST internos.

---

## 📈 Próximos Pasos

- Implementar autenticación JWT y roles/permissions
- Añadir más pruebas unitarias e2e
- CI/CD (GitHub Actions / GitLab CI)
- Observabilidad: Prometheus / Grafana

---

## 👥 Equipo

**Proyecto**: Clínica Microservicio

---

## 📄 Licencia

Este proyecto usa la licencia MIT.

---

**Archivos clave:** `src/` (módulos), `docker-compose.yml`, `.env.example`, `package.json`
