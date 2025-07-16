Write-Host "=== TEST SIMPLE DES BOUTONS ===" -ForegroundColor Green

# Test du serveur
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/test" -UseBasicParsing
    Write-Host "✓ Serveur OK: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "✗ Serveur KO: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test de l'API projets
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -UseBasicParsing
    $projets = $response.Content | ConvertFrom-Json
    Write-Host "✓ API projets OK: $($projets.Count) projets" -ForegroundColor Green
} catch {
    Write-Host "✗ API projets KO: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== INSTRUCTIONS POUR TESTER ===" -ForegroundColor Yellow
Write-Host "1. Ouvrez http://localhost:8080 dans votre navigateur" -ForegroundColor Cyan
Write-Host "2. Connectez-vous avec un compte ADMIN ou SUPERVISEUR" -ForegroundColor Cyan
Write-Host "3. Essayez d'ajouter une pièce jointe" -ForegroundColor Cyan
Write-Host "4. Ouvrez la console (F12) pour voir les erreurs" -ForegroundColor Cyan
Write-Host "5. Vérifiez que les messages de succès/erreur s'affichent" -ForegroundColor Cyan 