# Script de prueba de integración entre microservicios (PowerShell)
# GenoSentinel Gateway + Genómica

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PRUEBA DE INTEGRACIÓN - GenoSentinel" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$BaseUrl = "http://localhost:8080"

# Función para imprimir resultados
function Print-Result {
    param($Success, $Message)
    if ($Success) {
        Write-Host "✓ $Message" -ForegroundColor Green
    } else {
        Write-Host "✗ $Message" -ForegroundColor Red
    }
}

try {
    Write-Host "1. Verificando estado del Gateway..." -ForegroundColor Yellow
    $status = Invoke-RestMethod -Uri "$BaseUrl/api/status"
    Print-Result $true "Gateway está activo"
    Write-Host ""

    Write-Host "2. Verificando health check completo..." -ForegroundColor Yellow
    $health = Invoke-RestMethod -Uri "$BaseUrl/api/health"
    $health | ConvertTo-Json -Depth 10
    Print-Result $true "Health check completado"
    Write-Host ""

    Write-Host "3. Registrando nuevo usuario..." -ForegroundColor Yellow
    $registerBody = @{
        username = "test_user_$(Get-Random)"
        password = "test123"
        fullName = "Usuario de Prueba"
        email = "test$(Get-Random)@test.com"
    } | ConvertTo-Json

    $registerResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerBody

    $registerResponse | ConvertTo-Json
    Print-Result $true "Usuario registrado correctamente"
    Write-Host "Token: $($registerResponse.token.Substring(0, 50))..." -ForegroundColor Gray
    Write-Host ""

    Write-Host "4. Login con usuario existente..." -ForegroundColor Yellow
    $loginBody = @{
        username = "admin"
        password = "password123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody

    $loginResponse | ConvertTo-Json
    $token = $loginResponse.token
    Print-Result $true "Login exitoso"
    Write-Host ""

    $headers = @{
        Authorization = "Bearer $token"
    }

    Write-Host "5. Accediendo a microservicio de Genómica vía Gateway..." -ForegroundColor Yellow
    Write-Host "GET /api/gateway/genomica/api/v1/genes/" -ForegroundColor Gray
    $genes = Invoke-RestMethod -Uri "$BaseUrl/api/gateway/genomica/api/v1/genes/" -Headers $headers
    $genes | ConvertTo-Json -Depth 5
    Print-Result $true "Acceso a Genómica exitoso"
    Write-Host ""

    Write-Host "6. Creando un gen vía Gateway..." -ForegroundColor Yellow
    $geneBody = @{
        symbol = "EGFR"
        full_name = "Epidermal Growth Factor Receptor"
        function_summary = "Receptor de tirosina quinasa que regula el crecimiento celular"
    } | ConvertTo-Json

    $createGene = Invoke-RestMethod -Uri "$BaseUrl/api/gateway/genomica/api/v1/genes/" `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json" `
        -Body $geneBody

    $createGene | ConvertTo-Json
    Print-Result $true "Gen creado exitosamente"
    Write-Host ""

    Write-Host "7. Obteniendo variantes genéticas vía Gateway..." -ForegroundColor Yellow
    $variants = Invoke-RestMethod -Uri "$BaseUrl/api/gateway/genomica/api/v1/variants/" -Headers $headers
    $variants | ConvertTo-Json -Depth 5
    Print-Result $true "Variantes obtenidas exitosamente"
    Write-Host ""

    Write-Host "8. Obteniendo reportes de pacientes vía Gateway..." -ForegroundColor Yellow
    $reports = Invoke-RestMethod -Uri "$BaseUrl/api/gateway/genomica/api/v1/patient-reports/" -Headers $headers
    $reports | ConvertTo-Json -Depth 5
    Print-Result $true "Reportes obtenidos exitosamente"
    Write-Host ""

    Write-Host "9. Probando endpoint sin autenticación (debe fallar)..." -ForegroundColor Yellow
    try {
        $unauth = Invoke-RestMethod -Uri "$BaseUrl/api/gateway/genomica/api/v1/genes/"
        Print-Result $false "Seguridad no está funcionando correctamente"
    } catch {
        if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Response.StatusCode -eq 401) {
            Print-Result $true "Autenticación requerida (como se esperaba)"
        } else {
            Print-Result $false "Error inesperado: $($_.Exception.Message)"
        }
    }
    Write-Host ""

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  PRUEBAS COMPLETADAS" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green

} catch {
    Write-Host "Error durante las pruebas: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
