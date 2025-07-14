# Script de test pour vérifier que tous les champs sont optionnels
$baseUrl = "http://localhost:8080"

# Test 1: Créer un projet avec seulement l'ID (tous les autres champs vides)
Write-Host "Test 1: Création d'un projet avec seulement l'ID" -ForegroundColor Green

$projetMinimal = @{
    id = $null
    numeroProjet = ""
    client = ""
    designation = ""
    typeProjet = ""
    responsableInterne = ""
    responsableExterne = ""
    dureeContractuelle = ""
    dateDebut = ""
    dateFinEffective = ""
    avancement = ""
    statutExecution = ""
    montantContratTTC = ""
    montantAvenant = ""
    montantCumul = ""
    montantEncaisse = ""
    soldeRestant = ""
    statutFacturation = ""
    remarques = ""
    piecesJointes = $null
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Body $projetMinimal -ContentType "application/json"
    Write-Host "SUCCÈS: Projet créé avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Numéro de projet: $($response.numeroProjet)" -ForegroundColor Yellow
} catch {
    Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Créer un projet avec seulement quelques champs remplis
Write-Host "`nTest 2: Création d'un projet avec quelques champs remplis" -ForegroundColor Green

$projetPartiel = @{
    numeroProjet = "PROJ-001"
    client = "Client Test"
    designation = "Projet de test"
    typeProjet = ""
    responsableInterne = ""
    responsableExterne = ""
    dureeContractuelle = ""
    dateDebut = ""
    dateFinEffective = ""
    avancement = ""
    statutExecution = ""
    montantContratTTC = ""
    montantAvenant = ""
    montantCumul = ""
    montantEncaisse = ""
    soldeRestant = ""
    statutFacturation = ""
    remarques = ""
    piecesJointes = $null
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Body $projetPartiel -ContentType "application/json"
    Write-Host "SUCCÈS: Projet créé avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Numéro de projet: $($response.numeroProjet)" -ForegroundColor Yellow
    Write-Host "Client: $($response.client)" -ForegroundColor Yellow
} catch {
    Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Créer un projet avec des valeurs null
Write-Host "`nTest 3: Création d'un projet avec des valeurs null" -ForegroundColor Green

$projetNull = @{
    numeroProjet = $null
    client = $null
    designation = $null
    typeProjet = $null
    responsableInterne = $null
    responsableExterne = $null
    dureeContractuelle = $null
    dateDebut = $null
    dateFinEffective = $null
    avancement = $null
    statutExecution = $null
    montantContratTTC = $null
    montantAvenant = $null
    montantCumul = $null
    montantEncaisse = $null
    soldeRestant = $null
    statutFacturation = $null
    remarques = $null
    piecesJointes = $null
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Body $projetNull -ContentType "application/json"
    Write-Host "SUCCÈS: Projet créé avec ID: $($response.id)" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTests terminés!" -ForegroundColor Cyan 