# Diagnostic spécifique pour le problème du contrat
Write-Host "=== Diagnostic du probleme du contrat ===" -ForegroundColor Green

try {
    # Test 1: Vérifier que l'application répond
    Write-Host "Test 1: Verification de la disponibilite de l'application..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Application accessible" -ForegroundColor Green
    } else {
        Write-Host "✗ Application non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
        exit 1
    }

    # Test 2: Vérifier le dossier uploads
    Write-Host "Test 2: Verification du dossier uploads..." -ForegroundColor Cyan
    $uploadsPath = "uploads"
    if (Test-Path $uploadsPath) {
        Write-Host "✓ Dossier uploads existe" -ForegroundColor Green
        $files = Get-ChildItem -Path $uploadsPath -File
        Write-Host "  - Nombre de fichiers: $($files.Count)" -ForegroundColor Yellow
        if ($files.Count -gt 0) {
            Write-Host "  - Fichiers presents:" -ForegroundColor Yellow
            $files | ForEach-Object { Write-Host "    * $($_.Name)" -ForegroundColor Gray }
        }
    } else {
        Write-Host "✗ Dossier uploads n existe pas" -ForegroundColor Red
        Write-Host "  - Creation du dossier..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $uploadsPath -Force | Out-Null
        Write-Host "✓ Dossier uploads cree" -ForegroundColor Green
    }

    # Test 3: Recuperer les projets et analyser les contrats
    Write-Host "Test 3: Analyse des contrats dans les projets..." -ForegroundColor Cyan
    $projets = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
    Write-Host "✓ $($projets.Count) projets recuperes" -ForegroundColor Green
    
    $projetsAvecContrat = $projets | Where-Object { 
        $_.piecesJointes -and $_.piecesJointes.contrat -and $_.piecesJointes.contrat.nomFichier 
    }
    
    Write-Host "  - Projets avec contrat: $($projetsAvecContrat.Count)" -ForegroundColor Yellow
    
    foreach ($projet in $projetsAvecContrat) {
        $nomFichier = $projet.piecesJointes.contrat.nomFichier
        $description = $projet.piecesJointes.contrat.description
        $fichierExiste = Test-Path "uploads/$nomFichier"
        
        Write-Host "  Projet: $($projet.numeroProjet) (ID: $($projet.id))" -ForegroundColor Cyan
        Write-Host "    - Fichier: $nomFichier" -ForegroundColor Gray
        Write-Host "    - Description: $description" -ForegroundColor Gray
        Write-Host "    - Fichier physique: $(if ($fichierExiste) { '✓ Existe' } else { '✗ Manquant' })" -ForegroundColor $(if ($fichierExiste) { 'Green' } else { 'Red' })
        
        if (-not $fichierExiste) {
            Write-Host "    ATTENTION: Le fichier physique est manquant!" -ForegroundColor Red
        }
    }
    
    # Test 4: Tester la modification d un contrat existant
    Write-Host "Test 4: Test de modification d un contrat..." -ForegroundColor Cyan
    $projetAvecContrat = $projetsAvecContrat | Select-Object -First 1
    
    if ($projetAvecContrat) {
        Write-Host "  Test sur le projet: $($projetAvecContrat.numeroProjet)" -ForegroundColor Yellow
        
        # Simuler une modification
        $formData = @{
            projetId = $projetAvecContrat.id
            type = "contrat"
            nomFichier = $projetAvecContrat.piecesJointes.contrat.nomFichier
            description = "Description test contrat $(Get-Date -Format yyyyMMdd_HHmmss)"
        }
        
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        $bodyLines = @()
        
        # Ajouter les parametres
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"projetId`""
        $bodyLines += ""
        $bodyLines += $formData.projetId
        
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"type`""
        $bodyLines += ""
        $bodyLines += $formData.type
        
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"nomFichier`""
        $bodyLines += ""
        $bodyLines += $formData.nomFichier
        
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"description`""
        $bodyLines += ""
        $bodyLines += $formData.description
        
        $bodyLines += "--$boundary--"
        
        $body = $bodyLines -join $LF
        
        $headers = @{
            "Content-Type" = "multipart/form-data; boundary=$boundary"
        }
        
        $Error.Clear()
        $response = $null
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/pieces-jointes" -Method POST -Body $body -Headers $headers
        if ($?) {
            Write-Host "✓ Modification reussie: $response" -ForegroundColor Green
            Start-Sleep -Seconds 2
            $projetModifie = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET | Where-Object { $_.id -eq $projetAvecContrat.id } | Select-Object -First 1
            if ($projetModifie.piecesJointes.contrat.description -eq $formData.description) {
                Write-Host "✓ Description mise a jour avec succes" -ForegroundColor Green
            } else {
                Write-Host "ATTENTION: Description non mise a jour" -ForegroundColor Yellow
                Write-Host "  - Attendu: $($formData.description)" -ForegroundColor Gray
                Write-Host "  - Obtenu: $($projetModifie.piecesJointes.contrat.description)" -ForegroundColor Gray
            }
        } else {
            Write-Host "ERREUR lors de la modification: $($Error[0])" -ForegroundColor Red
        }
    } else {
        Write-Host "ATTENTION: Aucun projet avec contrat trouve pour le test" -ForegroundColor Yellow
    }

    Write-Host "=== Diagnostic termine ===" -ForegroundColor Green

} catch {
    Write-Host "ERREUR GENERALE: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 