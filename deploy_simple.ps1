# Script simplifié de déploiement GitHub pour EetSecomDash

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,
    
    [string]$RepoName = "EetSecomDash"
)

Write-Host "=== DEPLOIEMENT SUR GITHUB ===" -ForegroundColor Green
Write-Host "Nom d'utilisateur GitHub : $GitHubUsername" -ForegroundColor Cyan
Write-Host "Nom du repository : $RepoName" -ForegroundColor Cyan

# Vérifier l'état Git
Write-Host "`nVérification de l'état Git..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "Il y a des modifications non commitées. Voulez-vous les commiter ? (y/n)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq "y" -or $response -eq "Y") {
        git add .
        git commit -m "Auto-commit before GitHub deployment"
        Write-Host "Modifications commitées" -ForegroundColor Green
    } else {
        Write-Host "Déploiement annulé" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Aucune modification en attente" -ForegroundColor Green
}

# Supprimer l'ancien remote s'il existe
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "`nSuppression de l'ancien remote..." -ForegroundColor Yellow
    git remote remove origin
    Write-Host "Ancien remote supprimé" -ForegroundColor Green
}

# Ajouter le nouveau remote
Write-Host "`nConfiguration du remote GitHub..." -ForegroundColor Yellow
$remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"
git remote add origin $remoteUrl
Write-Host "Remote configuré : $remoteUrl" -ForegroundColor Green

# Pousser le code
Write-Host "`nPoussage du code vers GitHub..." -ForegroundColor Yellow
try {
    git push -u origin master
    Write-Host "Code poussé avec succès !" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors du push : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nSOLUTIONS POSSIBLES :" -ForegroundColor Yellow
    Write-Host "1. Créez d'abord le repository sur GitHub : https://github.com/new" -ForegroundColor White
    Write-Host "2. Nom du repository : $RepoName" -ForegroundColor White
    Write-Host "3. Description : Dashboard de gestion de projets Spring Boot avec authentification JWT" -ForegroundColor White
    Write-Host "4. Choisissez Public ou Private" -ForegroundColor White
    Write-Host "5. NE cochez PAS les options README, .gitignore, ou license" -ForegroundColor White
    Write-Host "6. Cliquez sur 'Create repository'" -ForegroundColor White
    Write-Host "7. Relancez ce script" -ForegroundColor White
    exit 1
}

# Afficher les informations finales
Write-Host "`nSUCCES ! Votre projet est maintenant sur GitHub !" -ForegroundColor Green
Write-Host "URL : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan

Write-Host "`nPROCHAINES ETAPES RECOMMANDEES :" -ForegroundColor Yellow
Write-Host "1. Ajouter des topics au repository (spring-boot, java, dashboard, jwt)" -ForegroundColor White
Write-Host "2. Créer des releases pour marquer les versions importantes" -ForegroundColor White
Write-Host "3. Configurer les GitHub Actions (déjà inclus dans le projet)" -ForegroundColor White
Write-Host "4. Améliorer la documentation si nécessaire" -ForegroundColor White
Write-Host "5. Inviter des collaborateurs si besoin" -ForegroundColor White

Write-Host "`nLIENS UTILES :" -ForegroundColor Cyan
Write-Host "Repository : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor White
Write-Host "Actions : https://github.com/$GitHubUsername/$RepoName/actions" -ForegroundColor White
Write-Host "Issues : https://github.com/$GitHubUsername/$RepoName/issues" -ForegroundColor White
Write-Host "Releases : https://github.com/$GitHubUsername/$RepoName/releases" -ForegroundColor White

Write-Host "`nDEPLOIEMENT TERMINE AVEC SUCCES !" -ForegroundColor Green 