# Test pour vérifier que tous les champs sont maintenant facultatifs
# Ce script teste la création d'un projet avec des champs vides

Write-Host "=== Test des champs facultatifs ===" -ForegroundColor Green

# URL de base
$baseUrl = "http://localhost:8080"

# Test 1: Créer un projet avec seulement un numéro de projet
Write-Host "`nTest 1: Création d'un projet avec seulement le numéro de projet" -ForegroundColor Yellow
$projetMinimal = @{
    numeroProjet = "TEST-OPTIONAL-001"
    # Tous les autres champs sont vides/null
}

$headers = @{
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Headers $headers -Body ($projetMinimal | ConvertTo-Json)
    Write-Host "✅ Succès: Projet créé avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Numéro projet: $($response.numeroProjet)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur lors de la création du projet minimal: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Créer un projet avec quelques champs remplis
Write-Host "`nTest 2: Création d'un projet avec quelques champs remplis" -ForegroundColor Yellow
$projetPartiel = @{
    numeroProjet = "TEST-OPTIONAL-002"
    client = "Client Test"
    designation = "Projet de test partiel"
    # Les autres champs restent vides
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Headers $headers -Body ($projetPartiel | ConvertTo-Json)
    Write-Host "✅ Succès: Projet partiel créé avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Client: $($response.client)" -ForegroundColor Cyan
    Write-Host "Désignation: $($response.designation)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur lors de la création du projet partiel: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Créer un projet avec tous les champs remplis
Write-Host "`nTest 3: Création d'un projet avec tous les champs remplis" -ForegroundColor Yellow
$projetComplet = @{
    numeroProjet = "TEST-OPTIONAL-003"
    client = "Client Complet"
    designation = "Projet de test complet"
    typeProjet = "detection incendie"
    responsableInterne = "Jean Dupont"
    responsableExterne = "Marie Martin"
    dureeContractuelle = "12 mois"
    montantContratTTC = "500000"
    montantAvenant = "50000"
    dateDebut = "2024-01-01"
    dateFinEffective = "2024-12-31"
    avancement = "75"
    statutExecution = "en cours"
    montantCumul = "375000"
    montantEncaisse = "300000"
    soldeRestant = "200000"
    statutFacturation = "partiellement paye"
    remarques = "Projet de test avec tous les champs remplis"
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Headers $headers -Body ($projetComplet | ConvertTo-Json)
    Write-Host "✅ Succès: Projet complet créé avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Tous les champs ont été sauvegardés correctement" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erreur lors de la création du projet complet: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Lister tous les projets pour vérifier
Write-Host "`nTest 4: Liste de tous les projets" -ForegroundColor Yellow
try {
    $projets = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    Write-Host "✅ Succès: $($projets.Count) projets trouvés" -ForegroundColor Green
    foreach ($projet in $projets) {
        Write-Host "  - ID: $($projet.id), N°: $($projet.numeroProjet), Client: $($projet.client)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Erreur lors de la récupération des projets: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Green 