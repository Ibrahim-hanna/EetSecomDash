# Script de test pour le rechargement automatique
Write-Host "=== Test du rechargement automatique ===" -ForegroundColor Green

# URL de base
$baseUrl = "http://localhost:8080"

Write-Host "1. Test de l'endpoint WebSocket..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/websocket/test" -Method GET
    Write-Host "✓ Test WebSocket réussi: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors du test WebSocket: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Test de notification de mise à jour des projets..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/websocket/notify-projets-update" -Method GET
    Write-Host "✓ Notification envoyée: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors de l'envoi de notification: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Test de l'API des projets..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    Write-Host "✓ API projets accessible: $($response.Count) projets trouvés" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors de l'accès à l'API projets: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Instructions pour tester le rechargement automatique ===" -ForegroundColor Cyan
Write-Host "1. Ouvrez votre navigateur et allez sur: $baseUrl/dashboard" -ForegroundColor White
Write-Host "2. Ouvrez la console du navigateur (F12)" -ForegroundColor White
Write-Host "3. Vous devriez voir des messages de connexion WebSocket" -ForegroundColor White
Write-Host "4. Testez les fonctions WebSocket dans la console:" -ForegroundColor White
Write-Host "   - testWebSocket() : Test de connexion" -ForegroundColor White
Write-Host "   - disconnectWebSocket() : Déconnexion" -ForegroundColor White
Write-Host "5. Modifiez un projet et observez la mise à jour automatique" -ForegroundColor White

Write-Host "`n=== Configuration DevTools ===" -ForegroundColor Cyan
Write-Host "Le rechargement automatique est configuré avec:" -ForegroundColor White
Write-Host "- Spring Boot DevTools activé" -ForegroundColor White
Write-Host "- LiveReload activé" -ForegroundColor White
Write-Host "- WebSocket pour les mises à jour en temps réel" -ForegroundColor White
Write-Host "- Rechargement périodique en fallback" -ForegroundColor White

Write-Host "`nTest terminé!" -ForegroundColor Green 