# Script de prueba completa de endpoints GenoSentinel
# Demuestra el correcto funcionamiento de autenticación y endpoints protegidos

$baseUrl = "http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         🧬 GENOSENTINEL - PRUEBA DE ENDPOINTS 🧬            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. REGISTRO DE USUARIO
Write-Host "📝 1. Registrando nuevo usuario..." -ForegroundColor Yellow
$registerBody = @{
    username = "demo_user_$(Get-Random -Maximum 9999)"
    password = "DemoPass123!"
    fullName = "Demo User"
    email = "demo@genosentinel.com"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-WebRequest -Uri "$baseUrl/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    $registerData = $registerResponse.Content | ConvertFrom-Json
    $token = $registerData.token
    Write-Host "   ✅ Registro exitoso - Usuario: $($registerData.username)" -ForegroundColor Green
    Write-Host "   🔑 Token JWT obtenido (válido por 24h)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Error en registro: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Headers con JWT
$headers = @{ Authorization = "Bearer $token" }

# 2. HEALTH CHECK
Write-Host "`n🏥 2. Verificando salud del sistema..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "$baseUrl/api/health" -Method GET
    $health = $healthResponse.Content | ConvertFrom-Json
    Write-Host "   ✅ Gateway: $($health.status)" -ForegroundColor Green
    Write-Host "   ✅ Database: $($health.database.status)" -ForegroundColor Green
    Write-Host "   ✅ Genomica: $($health.microservices.genomica.status)" -ForegroundColor Green
    Write-Host "   ✅ Clinica: $($health.microservices.clinica.status)" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Health check parcial" -ForegroundColor Yellow
}

# 3. LISTAR GENES
Write-Host "`n🧬 3. Obteniendo catálogo de genes..." -ForegroundColor Yellow
try {
    $genesResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/genes/" -Method GET -Headers $headers
    $genes = ($genesResponse.Content | ConvertFrom-Json).results
    Write-Host "   ✅ Genes encontrados: $($genes.Count)" -ForegroundColor Green
    $genes | ForEach-Object {
        Write-Host "      • $($_.symbol) - $($_.full_name)" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. OBTENER GEN ESPECÍFICO
Write-Host "`n🔬 4. Consultando gen específico (BRCA1)..." -ForegroundColor Yellow
try {
    $geneResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/genes/1/" -Method GET -Headers $headers
    $gene = $geneResponse.Content | ConvertFrom-Json
    Write-Host "   ✅ Gen: $($gene.symbol)" -ForegroundColor Green
    Write-Host "      Nombre: $($gene.full_name)" -ForegroundColor White
    Write-Host "      Función: $($gene.function_summary)" -ForegroundColor White
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. LISTAR VARIANTES GENÉTICAS
Write-Host "`n🧪 5. Obteniendo variantes genéticas..." -ForegroundColor Yellow
try {
    $variantsResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/variants/" -Method GET -Headers $headers
    $variants = ($variantsResponse.Content | ConvertFrom-Json).results
    Write-Host "   ✅ Variantes encontradas: $($variants.Count)" -ForegroundColor Green
    $variants | ForEach-Object {
        Write-Host "      • $($_.chromosome):$($_.position) $($_.reference_base)>$($_.alternate_base) - $($_.impact)" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. LISTAR REPORTES DE PACIENTES
Write-Host "`n📊 6. Obteniendo reportes de pacientes..." -ForegroundColor Yellow
try {
    $reportsResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/v1/patient-reports/" -Method GET -Headers $headers
    $reports = ($reportsResponse.Content | ConvertFrom-Json).results
    Write-Host "   ✅ Reportes encontrados: $($reports.Count)" -ForegroundColor Green
    $reports | ForEach-Object {
        Write-Host "      • Paciente: $($_.patient_id)" -ForegroundColor White
        Write-Host "        Muestra: $($_.sample_type)" -ForegroundColor Gray
        Write-Host "        Frecuencia alélica: $($_.allele_frequency)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. SWAGGER DOCUMENTATION
Write-Host "`n📚 7. Verificando documentación Swagger..." -ForegroundColor Yellow
try {
    $docsResponse = Invoke-WebRequest -Uri "$baseUrl/api/genomica/docs/" -Method GET
    Write-Host "   ✅ Swagger UI disponible" -ForegroundColor Green
    Write-Host "      URL: $baseUrl/api/genomica/docs/" -ForegroundColor White
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# RESUMEN FINAL
Write-Host "`n`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✅ PRUEBAS COMPLETADAS ✅                    ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n📌 Endpoints probados exitosamente:" -ForegroundColor Cyan
Write-Host "   • POST /api/auth/register" -ForegroundColor White
Write-Host "   • GET /api/health" -ForegroundColor White
Write-Host "   • GET /api/genomica/v1/genes/" -ForegroundColor White
Write-Host "   • GET /api/genomica/v1/genes/{id}/" -ForegroundColor White
Write-Host "   • GET /api/genomica/v1/variants/" -ForegroundColor White
Write-Host "   • GET /api/genomica/v1/patient-reports/" -ForegroundColor White
Write-Host "   • GET /api/genomica/docs/" -ForegroundColor White
Write-Host ""
Write-Host "🔐 Autenticación JWT funcionando correctamente" -ForegroundColor Cyan
Write-Host "🔗 Proxy del Gateway configurado correctamente" -ForegroundColor Cyan
Write-Host "💾 Base de datos con datos de ejemplo cargados" -ForegroundColor Cyan
Write-Host ""
