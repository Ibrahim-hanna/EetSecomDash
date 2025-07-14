# Script de test pour verifier le dashboard
Write-Host "=== TEST DU DASHBOARD ===" -ForegroundColor Green

# Attendre que l'application demarre
Write-Host "Attente du demarrage de l'application..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Test 1: Verifier que l'application repond
Write-Host "Test 1: Verification de la disponibilite de l'application..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -Method GET -TimeoutSec 10
    Write-Host "OK Application accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "ERREUR Application non accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Verifier l'API des projets
Write-Host "Test 2: Verification de l'API des projets..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -Method GET -TimeoutSec 10
    $projets = $response.Content | ConvertFrom-Json
    Write-Host "OK API projets accessible - Nombre de projets: $($projets.Count)" -ForegroundColor Green
    
    if ($projets.Count -gt 0) {
        Write-Host "Premier projet: $($projets[0].numeroProjet) - $($projets[0].client)" -ForegroundColor Green
    }
} catch {
    Write-Host "ERREUR API projets: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Verifier le dashboard
Write-Host "Test 3: Verification du dashboard..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/dashboard" -Method GET -TimeoutSec 10
    Write-Host "OK Dashboard accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    
    # Verifier que le contenu contient des informations de projet
    if ($response.Content -match "selectedProjet") {
        Write-Host "OK Template contient les variables selectedProjet" -ForegroundColor Green
    } else {
        Write-Host "ATTENTION Template ne contient pas selectedProjet" -ForegroundColor Yellow
    }
    
    if ($response.Content -match "section-info") {
        Write-Host "OK Section info presente dans le template" -ForegroundColor Green
    } else {
        Write-Host "ATTENTION Section info manquante" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "ERREUR dashboard: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== FIN DES TESTS ===" -ForegroundColor Green
Write-Host "Ouvrez http://localhost:8080/dashboard dans votre navigateur pour tester manuellement" -ForegroundColor Cyan 