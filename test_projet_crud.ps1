# Script de test pour les opérations CRUD sur les projets

Write-Host "=== Test des opérations CRUD sur les projets ===" -ForegroundColor Green

# Attendre que l'application démarre
Write-Host "Attente du démarrage de l'application..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test 1: Vérifier que l'application répond
Write-Host "`n1. Test de connexion à l'application..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/login" -Method GET
    Write-Host "✓ Application accessible (code: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur de connexion à l'application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Simuler une connexion (login)
Write-Host "`n2. Test de connexion utilisateur..." -ForegroundColor Cyan
try {
    $loginData = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✓ Connexion réussie" -ForegroundColor Green
    
    # Extraire le token JWT
    $loginResult = $response.Content | ConvertFrom-Json
    $token = $loginResult.token
    Write-Host "Token JWT obtenu" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Tentative avec des identifiants par défaut..." -ForegroundColor Yellow
    
    # Essayer avec des identifiants par défaut
    try {
        $loginData = @{
            username = "user"
            password = "password"
        } | ConvertTo-Json

        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
        Write-Host "✓ Connexion réussie avec identifiants par défaut" -ForegroundColor Green
        
        $loginResult = $response.Content | ConvertFrom-Json
        $token = $loginResult.token
    } catch {
        Write-Host "✗ Impossible de se connecter" -ForegroundColor Red
        exit 1
    }
}

# Test 3: Récupérer la liste des projets
Write-Host "`n3. Récupération de la liste des projets..." -ForegroundColor Cyan
try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -Method GET -Headers $headers
    $projets = $response.Content | ConvertFrom-Json
    Write-Host "✓ Nombre de projets récupérés: $($projets.Count)" -ForegroundColor Green
    
    if ($projets.Count -gt 0) {
        Write-Host "Premier projet: $($projets[0].numeroProjet) - $($projets[0].client)" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Erreur lors de la récupération des projets: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Créer un nouveau projet
Write-Host "`n4. Test de création d'un nouveau projet..." -ForegroundColor Cyan
try {
    $nouveauProjet = @{
        numeroProjet = "TEST-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        client = "Client Test"
        designation = "Projet de test automatique"
        typeProjet = "Détection incendie"
        responsableInterne = "Testeur"
        responsableExterne = "Client Test"
        dureeContractuelle = "6 mois"
        montantContratTTC = "50000"
        montantAvenant = "0"
        dateDebut = "1/1/2024"
        dateFinEffective = "6/30/2024"
        pourcentageAvancement = "50"
        statutExecution = "En cours"
        montantCumul = "25000"
        montantEncaisse = "20000"
        soldeRestant = "30000"
        statutFacturation = "Partiellement payé"
        remarques = "Projet créé par test automatique"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -Method POST -Body $nouveauProjet -Headers $headers
    $projetCree = $response.Content | ConvertFrom-Json
    Write-Host "✓ Projet créé avec succès, ID: $($projetCree.id)" -ForegroundColor Green
    Write-Host "Numéro: $($projetCree.numeroProjet)" -ForegroundColor Gray
    
    $projetId = $projetCree.id
} catch {
    Write-Host "✗ Erreur lors de la création du projet: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorContent = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorContent)
        $errorText = $reader.ReadToEnd()
        Write-Host "Détails de l'erreur: $errorText" -ForegroundColor Red
    }
    exit 1
}

# Test 5: Modifier le projet créé
Write-Host "`n5. Test de modification du projet..." -ForegroundColor Cyan
try {
    $projetModifie = @{
        id = $projetId
        numeroProjet = $projetCree.numeroProjet
        client = "Client Test Modifié"
        designation = "Projet de test automatique - MODIFIÉ"
        typeProjet = "Protection incendie"
        responsableInterne = "Testeur Modifié"
        responsableExterne = "Client Test Modifié"
        dureeContractuelle = "12 mois"
        montantContratTTC = "75000"
        montantAvenant = "5000"
        dateDebut = "1/1/2024"
        dateFinEffective = "12/31/2024"
        pourcentageAvancement = "75"
        statutExecution = "En cours"
        montantCumul = "60000"
        montantEncaisse = "50000"
        soldeRestant = "30000"
        statutFacturation = "Partiellement payé"
        remarques = "Projet modifié par test automatique"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets/$projetId" -Method PUT -Body $projetModifie -Headers $headers
    $projetModifieResult = $response.Content | ConvertFrom-Json
    Write-Host "✓ Projet modifié avec succès" -ForegroundColor Green
    Write-Host "Nouveau client: $($projetModifieResult.client)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Erreur lors de la modification du projet: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorContent = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorContent)
        $errorText = $reader.ReadToEnd()
        Write-Host "Détails de l'erreur: $errorText" -ForegroundColor Red
    }
}

# Test 6: Supprimer le projet créé
Write-Host "`n6. Test de suppression du projet..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets/$projetId" -Method DELETE -Headers $headers
    Write-Host "✓ Projet supprimé avec succès" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors de la suppression du projet: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorContent = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorContent)
        $errorText = $reader.ReadToEnd()
        Write-Host "Détails de l'erreur: $errorText" -ForegroundColor Red
    }
}

Write-Host "`n=== Test termine ===" -ForegroundColor Green 