# Diagnostic des pièces jointes
Write-Host "=== DIAGNOSTIC PIÈCES JOINTES ===" -ForegroundColor Yellow

# 1. Vérifier que l'application est démarrée
Write-Host "`n1. Vérification de l'application..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -Method GET -TimeoutSec 5
    Write-Host "✅ Application accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Application non accessible. Démarrez l'application avec: ./mvnw spring-boot:run" -ForegroundColor Red
    exit 1
}

# 2. Récupérer tous les projets
Write-Host "`n2. Récupération des projets..." -ForegroundColor Green
try {
    $projets = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
    Write-Host "✅ ${projets.Count} projets récupérés" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de la récupération des projets" -ForegroundColor Red
    exit 1
}

# 3. Analyser chaque projet
Write-Host "`n3. Analyse des projets..." -ForegroundColor Green
$projetsAvecProblemes = @()
$projetsOK = @()

foreach ($projet in $projets) {
    Write-Host "`n--- Projet: $($projet.numeroProjet) ---" -ForegroundColor Cyan
    
    # Vérifier si le projet a un ID
    if (-not $projet.id) {
        Write-Host "❌ Projet sans ID - problème de base de données" -ForegroundColor Red
        $projetsAvecProblemes += $projet
        continue
    }
    
    # Vérifier les pièces jointes
    $piecesJointes = $projet.piecesJointes
    if (-not $piecesJointes) {
        Write-Host "⚠️ Aucune structure piecesJointes" -ForegroundColor Yellow
        $projetsAvecProblemes += $projet
        continue
    }
    
    # Vérifier chaque type de pièce jointe
    $types = @("contrat", "pvReceptionProvisoire", "pvReceptionDefinitive", "attestationReference", "suiviExecutionDetaille", "suiviReglementDetaille")
    $problemes = @()
    
    foreach ($type in $types) {
        $piece = $piecesJointes.$type
        if ($piece -and $piece.nomFichier) {
            Write-Host "  ✅ $type : $($piece.nomFichier)" -ForegroundColor Green
        } else {
            Write-Host "  ⚪ $type : Aucun fichier" -ForegroundColor Gray
        }
    }
    
    # Vérifier si le projet a des pièces jointes en base mais pas dans le DTO
    $hasPiecesInBase = $false
    if ($projet.contratPieceJointe -or $projet.pvReceptionProvisoire -or $projet.pvReceptionDefinitif -or 
        $projet.attestationReference -or $projet.suiviExecutionDetaillePieceJointe -or $projet.suiviReglementDetaillePieceJointe) {
        $hasPiecesInBase = $true
        Write-Host "  🔍 Pièces jointes détectées en base de données" -ForegroundColor Blue
    }
    
    # Si le projet a des pièces en base mais pas dans le DTO, c'est un problème
    if ($hasPiecesInBase -and (-not $piecesJointes.contrat -and -not $piecesJointes.pvReceptionProvisoire -and 
        -not $piecesJointes.pvReceptionDefinitive -and -not $piecesJointes.attestationReference -and 
        -not $piecesJointes.suiviExecutionDetaille -and -not $piecesJointes.suiviReglementDetaille)) {
        Write-Host "  ❌ PROBLÈME: Pièces en base mais pas dans le DTO" -ForegroundColor Red
        $projetsAvecProblemes += $projet
    } else {
        $projetsOK += $projet
    }
}

# 4. Résumé
Write-Host "`n=== RÉSUMÉ ===" -ForegroundColor Yellow
Write-Host "Projets OK: $($projetsOK.Count)" -ForegroundColor Green
Write-Host "Projets avec problèmes: $($projetsAvecProblemes.Count)" -ForegroundColor Red

if ($projetsAvecProblemes.Count -gt 0) {
    Write-Host "`nProjets avec problèmes:" -ForegroundColor Red
    foreach ($projet in $projetsAvecProblemes) {
        Write-Host "  - $($projet.numeroProjet) (ID: $($projet.id))" -ForegroundColor Red
    }
    
    Write-Host "`n=== SOLUTIONS ===" -ForegroundColor Yellow
    Write-Host "1. Vérifiez que les fichiers existent dans le dossier 'uploads/'" -ForegroundColor Cyan
    Write-Host "2. Redémarrez l'application pour forcer la relecture des données" -ForegroundColor Cyan
    Write-Host "3. Vérifiez les logs de l'application pour des erreurs" -ForegroundColor Cyan
}

# 5. Test d'ajout de pièce jointe
Write-Host "`n5. Test d'ajout de pièce jointe..." -ForegroundColor Green
if ($projetsOK.Count -gt 0) {
    $testProjet = $projetsOK[0]
    Write-Host "Test avec le projet: $($testProjet.numeroProjet)" -ForegroundColor Cyan
    
    # Créer un fichier de test
    $testContent = "Test file content"
    $testFile = "test_file.txt"
    $testContent | Out-File -FilePath $testFile -Encoding UTF8
    
    try {
        $formData = @{
            projetId = $testProjet.id
            type = "contrat"
            fichier = Get-Item $testFile
            description = "Fichier de test"
        }
        
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/pieces-jointes" -Method POST -Form $formData
        Write-Host "✅ Test d'ajout réussi" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors du test d'ajout: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        # Nettoyer le fichier de test
        if (Test-Path $testFile) {
            Remove-Item $testFile
        }
    }
}

Write-Host "`n=== DIAGNOSTIC TERMINÉ ===" -ForegroundColor Yellow 