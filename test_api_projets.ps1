# Script de diagnostic pour les projets
$baseUrl = "http://localhost:8080"

Write-Host "=== DIAGNOSTIC DES PROJETS ===" -ForegroundColor Cyan

# Test 1: Vérifier si l'API répond
Write-Host "`n1. Test de connexion à l'API..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    Write-Host "✅ API accessible" -ForegroundColor Green
    Write-Host "Nombre de projets récupérés: $($response.Count)" -ForegroundColor Yellow
    
    if ($response.Count -gt 0) {
        Write-Host "Premier projet:" -ForegroundColor Yellow
        $response[0] | ConvertTo-Json -Depth 3
    }
} catch {
    Write-Host "❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Test 2: Vérifier la structure des données
Write-Host "`n2. Analyse de la structure des données..." -ForegroundColor Green
if ($response.Count -gt 0) {
    $projet = $response[0]
    Write-Host "Champs disponibles:" -ForegroundColor Yellow
    $projet.PSObject.Properties | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Value)" -ForegroundColor Gray
    }
}

# Test 3: Vérifier les données spécifiques
Write-Host "`n3. Vérification des champs critiques..." -ForegroundColor Green
if ($response.Count -gt 0) {
    $projet = $response[0]
    $champsCritiques = @('id', 'numeroProjet', 'client', 'designation', 'typeProjet')
    
    foreach ($champ in $champsCritiques) {
        $valeur = $projet.$champ
        if ($valeur) {
            Write-Host "✅ $champ`: $valeur" -ForegroundColor Green
        } else {
            Write-Host "❌ $champ`: VIDE" -ForegroundColor Red
        }
    }
}

# Test 4: Test de l'endpoint individuel
Write-Host "`n4. Test de récupération d'un projet individuel..." -ForegroundColor Green
if ($response.Count -gt 0) {
    $projetId = $response[0].id
    try {
        $projetIndividuel = Invoke-RestMethod -Uri "$baseUrl/api/projets/$projetId" -Method GET
        Write-Host "✅ Projet individuel récupéré avec succès" -ForegroundColor Green
        Write-Host "ID: $($projetIndividuel.id)" -ForegroundColor Yellow
        Write-Host "Numéro: $($projetIndividuel.numeroProjet)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Erreur lors de la récupération du projet individuel: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 5: Vérifier la console H2
Write-Host "`n5. Informations sur la console H2..." -ForegroundColor Green
Write-Host "Console H2 accessible à: http://localhost:8080/h2-console" -ForegroundColor Yellow
Write-Host "JDBC URL: jdbc:h2:file:./data/testdb" -ForegroundColor Yellow
Write-Host "Username: sa" -ForegroundColor Yellow
Write-Host "Password: (vide)" -ForegroundColor Yellow

Write-Host "`n=== FIN DU DIAGNOSTIC ===" -ForegroundColor Cyan 