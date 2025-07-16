# Correction des problèmes de pièces jointes
Write-Host "=== CORRECTION PIÈCES JOINTES ===" -ForegroundColor Yellow

# 1. Vérifier que l'application est démarrée
Write-Host "`n1. Vérification de l'application..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -Method GET -TimeoutSec 5
    Write-Host "✅ Application accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Application non accessible. Démarrez l'application avec: ./mvnw spring-boot:run" -ForegroundColor Red
    exit 1
}

# 2. Vérifier le dossier uploads
Write-Host "`n2. Vérification du dossier uploads..." -ForegroundColor Green
$uploadsDir = "uploads"
if (-not (Test-Path $uploadsDir)) {
    Write-Host "📁 Création du dossier uploads..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $uploadsDir -Force
    Write-Host "✅ Dossier uploads créé" -ForegroundColor Green
} else {
    Write-Host "✅ Dossier uploads existe" -ForegroundColor Green
    $files = Get-ChildItem -Path $uploadsDir -File
    Write-Host "📄 Fichiers dans uploads: $($files.Count)" -ForegroundColor Cyan
    foreach ($file in $files) {
        Write-Host "  - $($file.Name)" -ForegroundColor Gray
    }
}

# 3. Récupérer tous les projets
Write-Host "`n3. Récupération des projets..." -ForegroundColor Green
try {
    $projets = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
    Write-Host "✅ ${projets.Count} projets récupérés" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de la récupération des projets" -ForegroundColor Red
    exit 1
}

# 4. Analyser et corriger les projets
Write-Host "`n4. Analyse et correction des projets..." -ForegroundColor Green
$projetsCorriges = 0

foreach ($projet in $projets) {
    Write-Host "`n--- Projet: $($projet.numeroProjet) ---" -ForegroundColor Cyan
    
    if (-not $projet.id) {
        Write-Host "⚠️ Projet sans ID - ignoré" -ForegroundColor Yellow
        continue
    }
    
    # Vérifier les pièces jointes en base
    $piecesEnBase = @()
    if ($projet.contratPieceJointe) { $piecesEnBase += "contrat: $($projet.contratPieceJointe)" }
    if ($projet.pvReceptionProvisoire) { $piecesEnBase += "pvReceptionProvisoire: $($projet.pvReceptionProvisoire)" }
    if ($projet.pvReceptionDefinitif) { $piecesEnBase += "pvReceptionDefinitif: $($projet.pvReceptionDefinitif)" }
    if ($projet.attestationReference) { $piecesEnBase += "attestationReference: $($projet.attestationReference)" }
    if ($projet.suiviExecutionDetaillePieceJointe) { $piecesEnBase += "suiviExecutionDetaille: $($projet.suiviExecutionDetaillePieceJointe)" }
    if ($projet.suiviReglementDetaillePieceJointe) { $piecesEnBase += "suiviReglementDetaille: $($projet.suiviReglementDetaillePieceJointe)" }
    
    if ($piecesEnBase.Count -gt 0) {
        Write-Host "📄 Pièces jointes en base:" -ForegroundColor Blue
        foreach ($piece in $piecesEnBase) {
            Write-Host "  - $piece" -ForegroundColor Gray
        }
        
        # Vérifier si les fichiers existent physiquement
        $fichiersManquants = @()
        foreach ($piece in $piecesEnBase) {
            $parts = $piece.Split(": ")
            $type = $parts[0]
            $filename = $parts[1]
            
            $filePath = Join-Path $uploadsDir $filename
            if (-not (Test-Path $filePath)) {
                $fichiersManquants += "$type: $filename"
                Write-Host "  ❌ Fichier manquant: $filename" -ForegroundColor Red
            } else {
                Write-Host "  ✅ Fichier présent: $filename" -ForegroundColor Green
            }
        }
        
        if ($fichiersManquants.Count -gt 0) {
            Write-Host "⚠️ Fichiers manquants détectés" -ForegroundColor Yellow
            
            # Option 1: Supprimer les références en base
            $choice = Read-Host "Voulez-vous supprimer les références manquantes en base? (o/n)"
            if ($choice -eq "o" -or $choice -eq "O") {
                Write-Host "🗑️ Suppression des références manquantes..." -ForegroundColor Yellow
                foreach ($piece in $fichiersManquants) {
                    $parts = $piece.Split(": ")
                    $type = $parts[0]
                    $filename = $parts[1]
                    
                    # Appel API pour supprimer la pièce jointe
                    try {
                        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/pieces-jointes/$($projet.id)/$type" -Method DELETE
                        Write-Host "  ✅ Référence supprimée: $type" -ForegroundColor Green
                    } catch {
                        Write-Host "  ❌ Erreur lors de la suppression: $type" -ForegroundColor Red
                    }
                }
                $projetsCorriges++
            }
        }
    } else {
        Write-Host "⚪ Aucune pièce jointe en base" -ForegroundColor Gray
    }
}

# 5. Test de récupération après correction
Write-Host "`n5. Test de récupération après correction..." -ForegroundColor Green
try {
    $projetsApresCorrection = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
    Write-Host "✅ ${projetsApresCorrection.Count} projets récupérés après correction" -ForegroundColor Green
    
    # Compter les projets avec pièces jointes visibles
    $projetsAvecPiecesVisibles = 0
    foreach ($projet in $projetsApresCorrection) {
        if ($projet.piecesJointes -and 
            ($projet.piecesJointes.contrat -or $projet.piecesJointes.pvReceptionProvisoire -or 
             $projet.piecesJointes.pvReceptionDefinitive -or $projet.piecesJointes.attestationReference -or
             $projet.piecesJointes.suiviExecutionDetaille -or $projet.piecesJointes.suiviReglementDetaille)) {
            $projetsAvecPiecesVisibles++
        }
    }
    Write-Host "📊 Projets avec pièces jointes visibles: $projetsAvecPiecesVisibles" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erreur lors de la récupération après correction" -ForegroundColor Red
}

Write-Host "`n=== CORRECTION TERMINÉE ===" -ForegroundColor Yellow
Write-Host "Projets corrigés: $projetsCorriges" -ForegroundColor Green 