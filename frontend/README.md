# GenoSentinel Frontend

Frontend Angular para el sistema GenoSentinel de gestión de datos genómicos y clínicos.

## 🚀 Inicio Rápido

### Desarrollo Local

```bash
# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm start
```

La aplicación estará disponible en `http://localhost:4200`

### Producción

```bash
# Build de producción
npm run build

# La carpeta dist/ contendrá los archivos estáticos
```

## 🐳 Docker

### Build

```bash
docker build -t genosentinel-frontend:latest .
```

### Run

```bash
docker run -p 80:80 genosentinel-frontend:latest
```

## 📋 Características

- ✅ Autenticación JWT con guards
- ✅ Gestión de pacientes (CRUD completo)
- ✅ Visualización de variantes genéticas
- ✅ Creación de reportes genéticos
- ✅ Dashboard con estadísticas
- ✅ Diseño responsive y moderno

## 🔧 Configuración

### Environments

- **Development**: `src/environments/environment.ts`

  - API URL: `http://localhost:8080/api`

- **Production**: `src/environments/environment.prod.ts`
  - API URL: `/api` (proxy via nginx)

## 🏗️ Estructura del Proyecto

```
src/
├── app/
│   ├── components/         # Componentes UI
│   │   ├── login/
│   │   ├── dashboard/
│   │   ├── patients/
│   │   ├── variants/
│   │   ├── reports/
│   │   └── navbar/
│   ├── models/            # Interfaces TypeScript
│   ├── services/          # Servicios HTTP
│   ├── guards/            # Route guards
│   └── interceptors/      # HTTP interceptors
├── environments/          # Configuración de entornos
└── styles.css            # Estilos globales
```

## 🌐 Endpoints Utilizados

### Gateway (http://localhost:8080)

- `POST /api/auth/login` - Autenticación
- `POST /api/auth/register` - Registro

### Clínica (via gateway)

- `GET /api/clinica/patients` - Listar pacientes
- `POST /api/clinica/patients` - Crear paciente
- `PATCH /api/clinica/patients/:id` - Actualizar paciente
- `DELETE /api/clinica/patients/:id` - Eliminar paciente

### Genómica (via gateway)

- `GET /api/genomica/v1/variants/` - Listar variantes
- `GET /api/genomica/v1/patient-reports/` - Listar reportes
- `POST /api/genomica/v1/patient-reports/` - Crear reporte

## 🔐 Autenticación

El sistema usa JWT tokens:

1. Login exitoso guarda el token en `localStorage`
2. `AuthInterceptor` agrega automáticamente el header `Authorization: Bearer <token>`
3. `AuthGuard` protege las rutas privadas

## 📦 Dependencias Principales

- Angular 17.3
- RxJS 7.8
- TypeScript 5.4

## 🎨 Estilos

- CSS puro (sin frameworks)
- Diseño moderno con gradientes
- Componentes responsivos
- Paleta de colores: #667eea, #764ba2

## 🚢 Despliegue en Kubernetes

Ver `k8s/` para manifiestos de Kubernetes.

```bash
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

## 📝 Notas

- Para crear reportes genéticos, necesitas un UUID válido de paciente
- Las variantes se cargan automáticamente desde el backend
- El dashboard muestra estadísticas en tiempo real
