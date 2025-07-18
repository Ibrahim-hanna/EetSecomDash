# Test de modification des pièces jointes dans la section suivi détaillé
Write-Host "=== Test de modification des pièces jointes - Suivi détaillé ===" -ForegroundColor Green

# Configuration
$baseUrl = "http://localhost:8080"
$testFile = "test_modification.txt"

# Créer un fichier de test
"Ceci est un fichier de test pour la modification" | Out-File -FilePath $testFile -Encoding UTF8

try {
    # 1. Récupérer la liste des projets
    Write-Host "1. Récupération de la liste des projets..." -ForegroundColor Yellow
    $projetsResponse = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    $projets = $projetsResponse | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    
    if ($projets.Count -eq 0) {
        Write-Host "❌ Aucun projet trouvé" -ForegroundColor Red
        exit 1
    }
    
    $projet = $projets[0]
    Write-Host "✅ Projet sélectionné: $($projet.numeroProjet)" -ForegroundColor Green
    
    # 2. Tester la modification de la description pour suivi_execution_detaille
    Write-Host "`n2. Test de modification de description pour suivi_execution_detaille..." -ForegroundColor Yellow
    
    $formData = @{
        projetId = $projet.id
        type = "suivi_execution_detaille"
        description = "Description modifiée pour suivi exécution détaillé - $(Get-Date)"
    }
    
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $bodyLines = @()
    
    foreach ($key in $formData.Keys) {
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"$key`""
        $bodyLines += ""
        $bodyLines += $formData[$key]
    }
    $bodyLines += "--$boundary--"
    
    $body = $bodyLines -join $LF
    
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/pieces-jointes" -Method POST -Body $body -Headers $headers
        Write-Host "✅ Modification de description réussie pour suivi_execution_detaille" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors de la modification de description pour suivi_execution_detaille: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Détails de l'erreur: $responseBody" -ForegroundColor Red
        }
    }
    
    # 3. Tester la modification de la description pour suivi_reglement_detaille
    Write-Host "`n3. Test de modification de description pour suivi_reglement_detaille..." -ForegroundColor Yellow
    
    $formData = @{
        projetId = $projet.id
        type = "suivi_reglement_detaille"
        description = "Description modifiée pour suivi règlement détaillé - $(Get-Date)"
    }
    
    $bodyLines = @()
    foreach ($key in $formData.Keys) {
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"$key`""
        $bodyLines += ""
        $bodyLines += $formData[$key]
    }
    $bodyLines += "--$boundary--"
    
    $body = $bodyLines -join $LF
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/pieces-jointes" -Method POST -Body $body -Headers $headers
        Write-Host "✅ Modification de description réussie pour suivi_reglement_detaille" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors de la modification de description pour suivi_reglement_detaille: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Détails de l'erreur: $responseBody" -ForegroundColor Red
        }
    }
    
    # 4. Vérifier que les modifications ont été appliquées
    Write-Host "`n4. Vérification des modifications..." -ForegroundColor Yellow
    $projetsResponse = Invoke-RestMethod -Uri "$baseUrl/api/projets" -Method GET
    $projets = $projetsResponse | ConvertTo-Json -Depth 10 | ConvertFrom-Json
    $projetUpdated = $projets | Where-Object { $_.id -eq $projet.id } | Select-Object -First 1
    
    if ($projetUpdated.piecesJointes.suiviExecutionDetaille) {
        Write-Host "✅ Suivi exécution détaillé trouvé: $($projetUpdated.piecesJointes.suiviExecutionDetaille.description)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Suivi exécution détaillé non trouvé" -ForegroundColor Yellow
    }
    
    if ($projetUpdated.piecesJointes.suiviReglementDetaille) {
        Write-Host "✅ Suivi règlement détaillé trouvé: $($projetUpdated.piecesJointes.suiviReglementDetaille.description)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Suivi règlement détaillé non trouvé" -ForegroundColor Yellow
    }
    
    Write-Host "`n=== Test terminé ===" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erreur générale: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Nettoyage
    if (Test-Path $testFile) {
        Remove-Item $testFile -Force
    }
} 