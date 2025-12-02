Write-Host "Verificando Content-Type de Swagger docs..." -ForegroundColor Cyan

$response = Invoke-WebRequest -Uri "http://ab07b9a4029014e63935d4fddb195b8a-1722548835.us-east-1.elb.amazonaws.com:8080/api/genomica/docs/" -Method Get

Write-Host "`nStatus Code: $($response.StatusCode)" -ForegroundColor Green
Write-Host "Content-Type: $($response.Headers['Content-Type'])" -ForegroundColor $(if ($response.Headers['Content-Type'] -like '*text/html*') { 'Green' } else { 'Red' })

if ($response.Headers['Content-Type'] -like '*text/html*') {
    Write-Host "`n¡ÉXITO! El Content-Type ahora es text/html" -ForegroundColor Green
    Write-Host "La interfaz de Swagger debería renderizarse correctamente en el navegador." -ForegroundColor Green
} else {
    Write-Host "`nADVERTENCIA: El Content-Type todavía es $($response.Headers['Content-Type'])" -ForegroundColor Yellow
    Write-Host "La nueva imagen aún no se ha desplegado. Esperando..." -ForegroundColor Yellow
}
