# Test du calcul du total montant TTC dans la synthèse
Write-Host "=== Test du calcul du total montant TTC ===" -ForegroundColor Green

# URL de l'API de synthèse
$url = "http://localhost:8080/api/projets/synthese"

try {
    Write-Host "Appel de l'API de synthèse..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json"
    
    Write-Host "Réponse reçue :" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
    
    Write-Host "`n=== Détails du calcul ===" -ForegroundColor Green
    Write-Host "Total montant TTC (cumulé): $($response.totalContrats)" -ForegroundColor Yellow
    
    # Calcul manuel pour vérification
    Write-Host "`n=== Vérification manuelle ===" -ForegroundColor Green
    
    # Récupérer tous les projets
    $projetsUrl = "http://localhost:8080/api/projets"
    $projets = Invoke-RestMethod -Uri $projetsUrl -Method GET -ContentType "application/json"
    
    $totalManuel = 0
    $projetsAvecMontant = 0
    
    foreach ($projet in $projets) {
        if ($projet.montantCumul -and $projet.montantCumul -ne "" -and $projet.montantCumul -ne "N/A") {
            # Nettoyer et parser le montant
            $montantString = $projet.montantCumul -replace "[^\d.,]", ""
            if ($montantString -match ",") {
                if ($montantString -match "^\d{1,3}(,\d{3})*(\.\d+)?$") {
                    $montantString = $montantString -replace ",", ""
                } else {
                    $montantString = $montantString -replace ",", "."
                }
            }
            
            $montant = [double]::Parse($montantString)
            $totalManuel += $montant
            $projetsAvecMontant++
            
            Write-Host "Projet $($projet.numeroProjet): $($projet.montantCumul) -> $montant" -ForegroundColor Gray
        }
    }
    
    Write-Host "`nRésultats de la vérification :" -ForegroundColor Cyan
    Write-Host "Nombre de projets avec montant cumulé: $projetsAvecMontant" -ForegroundColor Yellow
    Write-Host "Total calculé manuellement: $totalManuel" -ForegroundColor Yellow
    Write-Host "Total retourné par l'API: $($response.totalContrats)" -ForegroundColor Yellow
    
    if ([Math]::Abs($totalManuel - $response.totalContrats) -lt 0.01) {
        Write-Host "✅ Les montants correspondent !" -ForegroundColor Green
    } else {
        Write-Host "❌ Différence détectée !" -ForegroundColor Red
        Write-Host "Différence: $($totalManuel - $response.totalContrats)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Erreur lors du test: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Assurez-vous que l'application Spring Boot est démarrée sur le port 8080" -ForegroundColor Yellow
} 