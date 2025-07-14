# Script de test pour vérifier la modification d'un projet avec des champs optionnels
$baseUrl = "http://localhost:8080"

# D'abord, récupérer tous les projets pour avoir un ID à modifier
Write-Host "Récupération des projets existants..." -ForegroundColor Green
try {
    $projets = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    if ($projets.Count -eq 0) {
        Write-Host "Aucun projet trouvé. Créons d'abord un projet de test." -ForegroundColor Yellow
        
        # Créer un projet de test
        $projetTest = @{
            numeroProjet = "TEST-001"
            client = "Client Test"
            designation = "Projet de test pour modification"
        } | ConvertTo-Json
        
        $nouveauProjet = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method POST -Body $projetTest -ContentType "application/json"
        $projetId = $nouveauProjet.id
        Write-Host "Projet de test créé avec ID: $projetId" -ForegroundColor Green
    } else {
        $projetId = $projets[0].id
        Write-Host "Utilisation du projet existant avec ID: $projetId" -ForegroundColor Green
    }
} catch {
    Write-Host "ERREUR lors de la récupération des projets: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Test 1: Modifier un projet en vidant certains champs
Write-Host "`nTest 1: Modification d'un projet en vidant certains champs" -ForegroundColor Green

$projetModifie = @{
    id = $projetId
    numeroProjet = ""  # Vider le numéro de projet
    client = ""        # Vider le client
    designation = "Nouvelle désignation"  # Garder seulement la désignation
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
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets/$projetId" -Method PUT -Body $projetModifie -ContentType "application/json"
    Write-Host "SUCCÈS: Projet modifié avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Numéro de projet: '$($response.numeroProjet)'" -ForegroundColor Yellow
    Write-Host "Client: '$($response.client)'" -ForegroundColor Yellow
    Write-Host "Désignation: '$($response.designation)'" -ForegroundColor Yellow
} catch {
    Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Modifier un projet en ajoutant seulement quelques champs
Write-Host "`nTest 2: Modification d'un projet en ajoutant seulement quelques champs" -ForegroundColor Green

$projetPartiel = @{
    id = $projetId
    numeroProjet = "PROJ-MODIFIE"
    client = "Nouveau Client"
    designation = ""
    typeProjet = "Type Modifié"
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
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets/$projetId" -Method PUT -Body $projetPartiel -ContentType "application/json"
    Write-Host "SUCCÈS: Projet modifié avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Numéro de projet: '$($response.numeroProjet)'" -ForegroundColor Yellow
    Write-Host "Client: '$($response.client)'" -ForegroundColor Yellow
    Write-Host "Type de projet: '$($response.typeProjet)'" -ForegroundColor Yellow
} catch {
    Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Modifier un projet avec des valeurs null
Write-Host "`nTest 3: Modification d'un projet avec des valeurs null" -ForegroundColor Green

$projetNull = @{
    id = $projetId
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
    $response = Invoke-RestMethod -Uri "$baseUrl/api/projets/$projetId" -Method PUT -Body $projetNull -ContentType "application/json"
    Write-Host "SUCCÈS: Projet modifié avec ID: $($response.id)" -ForegroundColor Green
    Write-Host "Tous les champs sont maintenant vides/null" -ForegroundColor Yellow
} catch {
    Write-Host "ERREUR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTests de modification terminés!" -ForegroundColor Cyan 