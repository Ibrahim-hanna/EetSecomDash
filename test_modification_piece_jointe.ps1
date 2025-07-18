# Script de test pour la modification des pièces jointes
Write-Host "=== TEST MODIFICATION PIÈCES JOINTES ===" -ForegroundColor Yellow

# Vérifier que l'application est démarrée
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET -TimeoutSec 5
    Write-Host "✅ Application connectée" -ForegroundColor Green
} catch {
    Write-Host "❌ Application non accessible. Démarrez l'application d'abord." -ForegroundColor Red
    exit 1
}

# Récupérer tous les projets
$projets = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
Write-Host "Nombre de projets: $($projets.Count)" -ForegroundColor Cyan

# Chercher un projet avec un contrat
$projetAvecContrat = $projets | Where-Object { 
    $_.piecesJointes -and $_.piecesJointes.contrat -and $_.piecesJointes.contrat.nomFichier 
} | Select-Object -First 1

if ($projetAvecContrat) {
    Write-Host "✅ Projet avec contrat trouvé: $($projetAvecContrat.numeroProjet)" -ForegroundColor Green
    Write-Host "  Nom du fichier: $($projetAvecContrat.piecesJointes.contrat.nomFichier)" -ForegroundColor Cyan
    Write-Host "  Description actuelle: $($projetAvecContrat.piecesJointes.contrat.description)" -ForegroundColor Cyan
    
    # Test de modification de description
    $nouvelleDescription = "Description modifiée $(Get-Date -Format yyyyMMdd_HHmmss)"
    Write-Host "`n🔄 Test de modification de description..." -ForegroundColor Yellow
    Write-Host "  Nouvelle description: $nouvelleDescription" -ForegroundColor Cyan
    
    $formData = @{
        projetId = $projetAvecContrat.id
        type = "contrat"
        description = $nouvelleDescription
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
    $bodyLines += "Content-Disposition: form-data; name=`"description`""
    $bodyLines += ""
    $bodyLines += $formData.description
    
    $bodyLines += "--$boundary"
    $bodyLines += "Content-Disposition: form-data; name=`"modification`""
    $bodyLines += ""
    $bodyLines += "true"
    
    $bodyLines += "--$boundary--"
    
    $body = $bodyLines -join $LF
    
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/pieces-jointes" -Method POST -Body $body -Headers $headers
        Write-Host "✅ Modification réussie: $response" -ForegroundColor Green
        
        # Vérifier que la modification a été appliquée
        Write-Host "`n🔄 Vérification de la modification..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        
        $projetsApres = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method GET
        $projetApres = $projetsApres | Where-Object { $_.id -eq $projetAvecContrat.id } | Select-Object -First 1
        
        if ($projetApres.piecesJointes.contrat.description -eq $nouvelleDescription) {
            Write-Host "✅ Description mise à jour avec succès!" -ForegroundColor Green
        } else {
            Write-Host "❌ La description n'a pas été mise à jour" -ForegroundColor Red
            Write-Host "  Description attendue: $nouvelleDescription" -ForegroundColor Cyan
            Write-Host "  Description actuelle: $($projetApres.piecesJointes.contrat.description)" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "❌ Erreur lors de la modification: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Détails: $responseBody" -ForegroundColor Red
        }
    }
    
} else {
    Write-Host "❌ Aucun projet avec contrat trouvé" -ForegroundColor Red
    Write-Host "  Créez d'abord un projet avec un contrat pour tester" -ForegroundColor Yellow
}

Write-Host "`n=== TEST TERMINÉ ===" -ForegroundColor Yellow 