# Script de test pour l'authentification et le dashboard
$baseUrl = "http://localhost:8080"

Write-Host "=== TEST AUTHENTIFICATION ET DASHBOARD ===" -ForegroundColor Cyan

# Test 1: Vérifier l'accès au splash
Write-Host "`n1. Test de la page splash..." -ForegroundColor Green
try {
    $splashResponse = Invoke-WebRequest -Uri "$baseUrl/splash" -Method GET
    Write-Host "✅ Page splash accessible (Status: $($splashResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur page splash: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Vérifier l'accès au login
Write-Host "`n2. Test de la page login..." -ForegroundColor Green
try {
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/login" -Method GET
    Write-Host "✅ Page login accessible (Status: $($loginResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur page login: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Vérifier l'accès au dashboard sans authentification
Write-Host "`n3. Test du dashboard sans authentification..." -ForegroundColor Green
try {
    $dashboardResponse = Invoke-WebRequest -Uri "$baseUrl/dashboard" -Method GET
    Write-Host "✅ Dashboard accessible (Status: $($dashboardResponse.StatusCode))" -ForegroundColor Green
    
    # Vérifier si on est redirigé vers login
    if ($dashboardResponse.BaseResponse.ResponseUri -like "*login*") {
        Write-Host "⚠️ Redirection vers login détectée (normal sans authentification)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur dashboard: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vérifier l'API des projets sans authentification
Write-Host "`n4. Test de l'API projets sans authentification..." -ForegroundColor Green
try {
    $projetsResponse = Invoke-WebRequest -Uri "$baseUrl/api/projets" -Method GET
    Write-Host "✅ API projets accessible (Status: $($projetsResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur API projets: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cela peut être normal si l'API nécessite une authentification" -ForegroundColor Yellow
}

Write-Host "`n=== INSTRUCTIONS POUR TESTER ===" -ForegroundColor Cyan
Write-Host "1. Ouvrez votre navigateur et allez à: http://localhost:8080" -ForegroundColor Yellow
Write-Host "2. Cliquez sur 'Se connecter'" -ForegroundColor Yellow
Write-Host "3. Connectez-vous avec un compte existant ou créez-en un" -ForegroundColor Yellow
Write-Host "4. Une fois connecté, vous devriez être redirigé vers le dashboard" -ForegroundColor Yellow
Write-Host "5. Vérifiez que les projets s'affichent dans le sélecteur" -ForegroundColor Yellow

Write-Host "`n=== COMPTES DE TEST ===" -ForegroundColor Cyan
Write-Host "Si vous n'avez pas de compte, créez-en un via l'interface web ou utilisez:" -ForegroundColor Yellow
Write-Host "Email: admin@test.com" -ForegroundColor Yellow
Write-Host "Password: admin123" -ForegroundColor Yellow
Write-Host "Role: ADMIN" -ForegroundColor Yellow

Write-Host "`n=== DIAGNOSTIC MANUEL ===" -ForegroundColor Cyan
Write-Host "1. Ouvrez la console de votre navigateur (F12)" -ForegroundColor Yellow
Write-Host "2. Allez sur le dashboard" -ForegroundColor Yellow
Write-Host "3. Regardez les erreurs dans la console" -ForegroundColor Yellow
Write-Host "4. Vérifiez les requêtes réseau pour voir si l'API répond" -ForegroundColor Yellow

Write-Host "`n=== FIN DU TEST ===" -ForegroundColor Cyan 