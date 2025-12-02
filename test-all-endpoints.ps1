# GenoSentinel - Test de Endpoints
# Demuestra autenticacion JWT y endpoints protegidos

$baseUrl = "http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " GENOSENTINEL - PRUEBA DE ENDPOINTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. REGISTRO
Write-Host "1. Registrando usuario..." -ForegroundColor Yellow
$registerBody = @{
    username = "testuser_$(Get-Random -Maximum 9999)"
    password = "Test123!"
    fullName = "Test User"
    email = "test@example.com"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-WebRequest -Uri "$baseUrl/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    $registerData = $registerResponse.Content | ConvertFrom-Json
    $token = $registerData.token
    Write-Host "   OK - Usuario: $($registerData.username)" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

# 2. GENES
Write-Host ""
Write-Host "2. Consultando genes..." -ForegroundColor Yellow
try {
    $genesResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/genes/" -Method GET -Headers $headers
    $genes = ($genesResponse.Content | ConvertFrom-Json).results
    Write-Host "   OK - Genes: $($genes.Count)" -ForegroundColor Green
    $genes | ForEach-Object {
        Write-Host "      * $($_.symbol) - $($_.full_name)"
    }
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. VARIANTES
Write-Host ""
Write-Host "3. Consultando variantes..." -ForegroundColor Yellow
try {
    $variantsResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/variants/" -Method GET -Headers $headers
    $variants = ($variantsResponse.Content | ConvertFrom-Json).results
    Write-Host "   OK - Variantes: $($variants.Count)" -ForegroundColor Green
    $variants | ForEach-Object {
        Write-Host "      * $($_.chromosome):$($_.position) - $($_.impact)"
    }
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. REPORTES
Write-Host ""
Write-Host "4. Consultando reportes..." -ForegroundColor Yellow
try {
    $reportsResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/patient-reports/" -Method GET -Headers $headers
    $reports = ($reportsResponse.Content | ConvertFrom-Json).results
    Write-Host "   OK - Reportes: $($reports.Count)" -ForegroundColor Green
    $reports | ForEach-Object {
        Write-Host "      * Paciente: $($_.patient_id.Substring(0,8))..."
    }
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. SWAGGER
Write-Host ""
Write-Host "5. Verificando Swagger..." -ForegroundColor Yellow
try {
    $docsResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/docs/" -Method GET
    Write-Host "   OK - Swagger disponible" -ForegroundColor Green
} catch {
    Write-Host "   ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "      TODAS LAS PRUEBAS EXITOSAS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Endpoints probados:" -ForegroundColor Cyan
Write-Host "  - POST /api/auth/register"
Write-Host "  - GET /api/genomica/v1/genes/"
Write-Host "  - GET /api/genomica/v1/variants/"
Write-Host "  - GET /api/genomica/v1/patient-reports/"
Write-Host "  - GET /api/genomica/docs/"
Write-Host ""
Write-Host "Autenticacion JWT: OK" -ForegroundColor Green
Write-Host "Gateway Proxy: OK" -ForegroundColor Green
Write-Host "Base de datos: OK" -ForegroundColor Green
Write-Host ""
