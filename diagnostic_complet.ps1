# Script de diagnostic complet pour les projets
$baseUrl = "http://localhost:8080"

Write-Host "=== DIAGNOSTIC COMPLET DES PROJETS ===" -ForegroundColor Cyan

# Test 1: Vérifier si l'application répond
Write-Host "`n1. Test de connexion à l'application..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "$baseUrl" -Method GET
    Write-Host "✅ Application accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Application non accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vérifiez que l'application est démarrée avec: ./mvnw spring-boot:run" -ForegroundColor Yellow
    exit
}

# Test 2: Vérifier l'API des projets
Write-Host "`n2. Test de l'API des projets..." -ForegroundColor Green
try {
    $projets = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    Write-Host "✅ API projets accessible" -ForegroundColor Green
    Write-Host "Nombre de projets récupérés: $($projets.Count)" -ForegroundColor Yellow
    
    if ($projets.Count -gt 0) {
        Write-Host "Premier projet (structure complète):" -ForegroundColor Yellow
        $projets[0] | ConvertTo-Json -Depth 5
    } else {
        Write-Host "⚠️ Aucun projet trouvé dans la base de données" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur API projets: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Détails de l'erreur:" -ForegroundColor Yellow
    $_.Exception.Response | Format-List
}

# Test 3: Vérifier le dashboard directement
Write-Host "`n3. Test du dashboard..." -ForegroundColor Green
try {
    $dashboardResponse = Invoke-WebRequest -Uri "$baseUrl/dashboard" -Method GET
    Write-Host "✅ Dashboard accessible (Status: $($dashboardResponse.StatusCode))" -ForegroundColor Green
    
    # Vérifier si le contenu contient des projets
    $content = $dashboardResponse.Content
    if ($content -match "projet") {
        Write-Host "✅ Le dashboard contient des références aux projets" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Le dashboard ne contient pas de références aux projets" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur dashboard: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vérifier la console H2
Write-Host "`n4. Test de la console H2..." -ForegroundColor Green
try {
    $h2Response = Invoke-WebRequest -Uri "$baseUrl/h2-console" -Method GET
    Write-Host "✅ Console H2 accessible (Status: $($h2Response.StatusCode))" -ForegroundColor Green
    Write-Host "URL de la console H2: http://localhost:8080/h2-console" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Console H2 non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Vérifier les fichiers de base de données
Write-Host "`n5. Vérification des fichiers de base de données..." -ForegroundColor Green
$dataPath = "data"
if (Test-Path $dataPath) {
    $files = Get-ChildItem $dataPath
    Write-Host "✅ Dossier data trouvé" -ForegroundColor Green
    foreach ($file in $files) {
        Write-Host "  - $($file.Name): $($file.Length) bytes" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Dossier data non trouvé" -ForegroundColor Red
}

# Test 6: Créer un projet de test si aucun n'existe
Write-Host "`n6. Test de création d'un projet..." -ForegroundColor Green
if ($projets.Count -eq 0) {
    Write-Host "Aucun projet trouvé, création d'un projet de test..." -ForegroundColor Yellow
    
    $projetTest = @{
        numeroProjet = "TEST-001"
        client = "Client Test"
        designation = "Projet de test pour diagnostic"
        typeProjet = "Test"
    } | ConvertTo-Json
    
    try {
        $nouveauProjet = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Body $projetTest -ContentType "application/json"
        Write-Host "✅ Projet de test créé avec succès" -ForegroundColor Green
        Write-Host "ID: $($nouveauProjet.id)" -ForegroundColor Yellow
        Write-Host "Numéro: $($nouveauProjet.numeroProjet)" -ForegroundColor Yellow
        
        # Vérifier que le projet apparaît maintenant
        $projetsApresCreation = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
        Write-Host "Nombre de projets après création: $($projetsApresCreation.Count)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Erreur lors de la création du projet de test: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Des projets existent déjà, pas besoin de créer un projet de test" -ForegroundColor Green
}

# Test 7: Vérifier les logs de l'application
Write-Host "`n7. Informations de diagnostic..." -ForegroundColor Green
Write-Host "Pour voir les logs de l'application, regardez la console où vous avez lancé ./mvnw spring-boot:run" -ForegroundColor Yellow
Write-Host "Recherchez les messages contenant 'projet', 'ProjetService', ou 'dashboard'" -ForegroundColor Yellow

Write-Host "`n=== RECOMMANDATIONS ===" -ForegroundColor Cyan
Write-Host "1. Vérifiez les logs de l'application pour voir s'il y a des erreurs" -ForegroundColor Yellow
Write-Host "2. Accédez à http://localhost:8080/h2-console pour voir les données en base" -ForegroundColor Yellow
Write-Host "3. Vérifiez que vous êtes connecté avec un rôle approprié (ADMIN, SUPERVISEUR, EMPLOYE)" -ForegroundColor Yellow
Write-Host "4. Testez l'API directement: http://localhost:8080/api/projets" -ForegroundColor Yellow

Write-Host "`n=== FIN DU DIAGNOSTIC ===" -ForegroundColor Cyan 