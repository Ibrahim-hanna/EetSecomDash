# Script de test pour diagnostiquer les problèmes de boutons d'enregistrement
Write-Host "=== TEST DES BOUTONS D'ENREGISTREMENT ===" -ForegroundColor Green

# Test 1: Vérifier que le serveur répond
Write-Host "`n1. Test de connectivité du serveur..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/test" -UseBasicParsing
    Write-Host "✓ Serveur accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Serveur non accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Vérifier l'API des projets
Write-Host "`n2. Test de l'API des projets..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -UseBasicParsing
    $projets = $response.Content | ConvertFrom-Json
    Write-Host "✓ API projets accessible (${projets.Count} projets trouvés)" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur API projets: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Vérifier l'API des pièces jointes
Write-Host "`n3. Test de l'API des pièces jointes..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/pieces-jointes" -Method OPTIONS -UseBasicParsing
    Write-Host "✓ API pièces jointes accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur API pièces jointes: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vérifier le fichier dashboard.html
Write-Host "`n4. Vérification du code JavaScript..." -ForegroundColor Yellow
$dashboardPath = "src/main/resources/templates/dashboard.html"
if (Test-Path $dashboardPath) {
    $content = Get-Content $dashboardPath -Raw
    
    # Vérifier les handlers de boutons
    $attachSaveHandler = $content -match "function attachSavePieceJointeHandler"
    $btnSaveHandler = $content -match "btnSavePieceJointe.*onclick"
    $multipleHandlers = ($content | Select-String "btnSavePieceJointe.*onclick").Count
    
    Write-Host "✓ Fichier dashboard.html trouvé" -ForegroundColor Green
    Write-Host "  - Fonction attachSavePieceJointeHandler: $(if($attachSaveHandler){'✓'}else{'✗'})" -ForegroundColor $(if($attachSaveHandler){'Green'}else{'Red'}) 
    Write-Host "  - Handlers onclick détectés: $multipleHandlers" -ForegroundColor $(if($multipleHandlers -eq 1){'Green'}else{'Yellow'})
    
    if ($multipleHandlers -gt 1) {
        Write-Host "  ⚠️  ATTENTION: Plusieurs handlers détectés - risque de conflit!" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Fichier dashboard.html non trouvé" -ForegroundColor Red
}

# Test 5: Vérifier les logs du serveur
Write-Host "`n5. Vérification des logs..." -ForegroundColor Yellow
Write-Host "Pour voir les logs en temps réel, utilisez: Get-Process java | Where-Object {$_.ProcessName -eq 'java'}" -ForegroundColor Cyan

Write-Host "`n=== RECOMMANDATIONS ===" -ForegroundColor Green
Write-Host "1. Ouvrez la console du navigateur (F12) pour voir les erreurs JavaScript" -ForegroundColor Cyan
Write-Host "2. Vérifiez que userRole est bien défini dans la console" -ForegroundColor Cyan
Write-Host "3. Testez l'ajout d'une pièce jointe et regardez les messages d'erreur" -ForegroundColor Cyan
Write-Host "4. Vérifiez que les requêtes AJAX sont bien envoyées dans l'onglet Network" -ForegroundColor Cyan

Write-Host "`n=== FIN DU DIAGNOSTIC ===" -ForegroundColor Green 