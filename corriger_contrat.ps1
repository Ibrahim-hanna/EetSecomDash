# Correction du problème du contrat
Write-Host "=== Correction du problème du contrat ===" -ForegroundColor Green

# Étape 1: Vérifier que l'application répond
Write-Host "Étape 1: Vérification de l'application..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Application accessible" -ForegroundColor Green
    } else {
        Write-Host "✗ Application non accessible" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Étape 2: Créer le dossier uploads s'il n'existe pas
Write-Host "Étape 2: Vérification du dossier uploads..." -ForegroundColor Cyan
$uploadsPath = "uploads"
if (-not (Test-Path $uploadsPath)) {
    Write-Host "  - Création du dossier uploads..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $uploadsPath -Force | Out-Null
    Write-Host "✓ Dossier uploads créé" -ForegroundColor Green
} else {
    Write-Host "✓ Dossier uploads existe déjà" -ForegroundColor Green
}

# Étape 3: Analyser les projets avec contrats problématiques
Write-Host "Étape 3: Analyse des contrats problématiques..." -ForegroundColor Cyan
try {
    $projets = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
    
    $projetsAvecContratProblematique = $projets | Where-Object { 
        $_.piecesJointes -and $_.piecesJointes.contrat -and $_.piecesJointes.contrat.nomFichier -and 
        -not (Test-Path "uploads/$($_.piecesJointes.contrat.nomFichier)")
    }
    
    Write-Host "  - Projets avec contrat problématique: $($projetsAvecContratProblematique.Count)" -ForegroundColor Yellow
    
    if ($projetsAvecContratProblematique.Count -eq 0) {
        Write-Host "✓ Aucun problème détecté avec les contrats" -ForegroundColor Green
        exit 0
    }
    
    # Étape 4: Corriger les problèmes
    Write-Host "Étape 4: Correction des problèmes..." -ForegroundColor Cyan
    
    foreach ($projet in $projetsAvecContratProblematique) {
        $nomFichier = $projet.piecesJointes.contrat.nomFichier
        $description = $projet.piecesJointes.contrat.description
        
        Write-Host "  Correction du projet: $($projet.numeroProjet) (ID: $($projet.id))" -ForegroundColor Yellow
        Write-Host "    - Fichier manquant: $nomFichier" -ForegroundColor Gray
        
        # Option 1: Créer un fichier temporaire pour simuler l'existence
        $tempFilePath = "uploads/$nomFichier"
        Write-Host "    - Création d'un fichier temporaire..." -ForegroundColor Gray
        
        # Créer un fichier temporaire avec le contenu du nom de fichier
        "Fichier temporaire pour: $nomFichier`nDescription: $description`nDate de création: $(Get-Date)" | Out-File -FilePath $tempFilePath -Encoding UTF8
        
        Write-Host "    ✓ Fichier temporaire créé: $tempFilePath" -ForegroundColor Green
    }
    
    Write-Host "✓ Correction terminée" -ForegroundColor Green
    
    # Étape 5: Vérification après correction
    Write-Host "Étape 5: Vérification après correction..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    
    $projetsApresCorrection = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
    
    $projetsAvecContratApresCorrection = $projetsApresCorrection | Where-Object { 
        $_.piecesJointes -and $_.piecesJointes.contrat -and $_.piecesJointes.contrat.nomFichier 
    }
    
    Write-Host "  - Projets avec contrat après correction: $($projetsAvecContratApresCorrection.Count)" -ForegroundColor Yellow
    
    foreach ($projet in $projetsAvecContratApresCorrection) {
        $nomFichier = $projet.piecesJointes.contrat.nomFichier
        $fichierExiste = Test-Path "uploads/$nomFichier"
        
        Write-Host "  Projet: $($projet.numeroProjet)" -ForegroundColor Cyan
        Write-Host "    - Fichier: $nomFichier" -ForegroundColor Gray
        Write-Host "    - Statut: $(if ($fichierExiste) { '✓ Existe' } else { '✗ Manquant' })" -ForegroundColor $(if ($fichierExiste) { 'Green' } else { 'Red' })
    }
    
} catch {
    Write-Host "✗ Erreur lors de la correction: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "=== Correction terminée ===" -ForegroundColor Green
Write-Host "Note: Les fichiers temporaires ont été créés pour résoudre le problème immédiat." -ForegroundColor Yellow
Write-Host "Pour une solution permanente, vous devrez recharger les vrais fichiers." -ForegroundColor Yellow 