# Script pour créer un repository GitHub et pousser le code
# Instructions d'utilisation :
# 1. Remplacez YOUR_GITHUB_USERNAME par votre nom d'utilisateur GitHub
# 2. Remplacez YOUR_GITHUB_TOKEN par votre token GitHub (optionnel, pour l'authentification)

param(
    [string]$GitHubUsername = "YOUR_GITHUB_USERNAME",
    [string]$GitHubToken = "YOUR_GITHUB_TOKEN",
    [string]$RepoName = "EetSecomDash",
    [string]$Description = "Dashboard de gestion de projets Spring Boot avec authentification JWT"
)

Write-Host "=== Création du repository GitHub ===" -ForegroundColor Green

# Configuration du repository
$repoData = @{
    name = $RepoName
    description = $Description
    private = $false
    auto_init = $false
    gitignore_template = ""
    license_template = ""
} | ConvertTo-Json

Write-Host "Repository à créer : $RepoName" -ForegroundColor Yellow
Write-Host "Description : $Description" -ForegroundColor Yellow

# URL de l'API GitHub
$apiUrl = "https://api.github.com/user/repos"

# Headers pour l'API
$headers = @{
    "Accept" = "application/vnd.github.v3+json"
    "Content-Type" = "application/json"
}

# Ajouter le token si fourni
if ($GitHubToken -ne "YOUR_GITHUB_TOKEN") {
    $headers["Authorization"] = "token $GitHubToken"
    Write-Host "Utilisation de l'authentification par token" -ForegroundColor Green
} else {
    Write-Host "Mode non authentifié - vous devrez créer le repository manuellement" -ForegroundColor Yellow
}

try {
    if ($GitHubToken -ne "YOUR_GITHUB_TOKEN") {
        # Créer le repository via l'API
        Write-Host "Création du repository via l'API GitHub..." -ForegroundColor Green
        $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Headers $headers -Body $repoData
        
        Write-Host "Repository créé avec succès!" -ForegroundColor Green
        Write-Host "URL : $($response.html_url)" -ForegroundColor Cyan
        
        # Configurer le remote Git
        $remoteUrl = $response.clone_url
        git remote add origin $remoteUrl
        
        Write-Host "Remote Git configuré : $remoteUrl" -ForegroundColor Green
        
        # Pousser le code
        Write-Host "Poussage du code vers GitHub..." -ForegroundColor Green
        git push -u origin master
        
        Write-Host "Code poussé avec succès!" -ForegroundColor Green
        Write-Host "Votre projet est maintenant disponible sur : $($response.html_url)" -ForegroundColor Cyan
        
    } else {
        Write-Host "`n=== INSTRUCTIONS MANUELLES ===" -ForegroundColor Yellow
        Write-Host "1. Allez sur https://github.com/new" -ForegroundColor White
        Write-Host "2. Nom du repository : $RepoName" -ForegroundColor White
        Write-Host "3. Description : $Description" -ForegroundColor White
        Write-Host "4. Choisissez Public ou Private" -ForegroundColor White
        Write-Host "5. NE cochez PAS 'Add a README file'" -ForegroundColor White
        Write-Host "6. NE cochez PAS 'Add .gitignore'" -ForegroundColor White
        Write-Host "7. NE cochez PAS 'Choose a license'" -ForegroundColor White
        Write-Host "8. Cliquez sur 'Create repository'" -ForegroundColor White
        Write-Host "`nUne fois créé, exécutez ces commandes :" -ForegroundColor Yellow
        Write-Host "git remote add origin https://github.com/$GitHubUsername/$RepoName.git" -ForegroundColor Cyan
        Write-Host "git push -u origin master" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "Erreur lors de la création du repository : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nUtilisez les instructions manuelles ci-dessus." -ForegroundColor Yellow
}

Write-Host "`n=== FIN ===" -ForegroundColor Green 