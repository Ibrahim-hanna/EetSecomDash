# Script de mise à jour GitHub pour EetSecomDash
# Ce script met à jour votre repository GitHub existant avec les nouvelles modifications

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,
    
    [string]$RepoName = "EetSecomDash",
    [string]$CommitMessage = "Update: Nouvelles fonctionnalités et améliorations"
)

Write-Host "🔄 === MISE À JOUR EetSecomDash SUR GITHUB ===" -ForegroundColor Green
Write-Host "Nom d'utilisateur GitHub : $GitHubUsername" -ForegroundColor Cyan
Write-Host "Nom du repository : $RepoName" -ForegroundColor Cyan
Write-Host "Message de commit : $CommitMessage" -ForegroundColor Cyan

# Vérifier l'état Git
Write-Host "`n📋 Vérification de l'état Git..." -ForegroundColor Yellow
$gitStatus = git status --porcelain

if (-not $gitStatus) {
    Write-Host "✅ Aucune modification détectée. Votre projet est déjà à jour !" -ForegroundColor Green
    Write-Host "📍 URL : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
    exit 0
}

Write-Host "📝 Modifications détectées :" -ForegroundColor Yellow
Write-Host $gitStatus -ForegroundColor White

# Ajouter toutes les modifications
Write-Host "`n📦 Ajout des modifications..." -ForegroundColor Yellow
git add .
Write-Host "✅ Modifications ajoutées au staging area" -ForegroundColor Green

# Commiter les modifications
Write-Host "`n💾 Création du commit..." -ForegroundColor Yellow
git commit -m $CommitMessage
Write-Host "✅ Commit créé avec succès" -ForegroundColor Green

# Vérifier si le remote existe
$existingRemote = git remote get-url origin 2>$null
if (-not $existingRemote) {
    Write-Host "`n🔗 Configuration du remote GitHub..." -ForegroundColor Yellow
    $remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"
    git remote add origin $remoteUrl
    Write-Host "✅ Remote configuré : $remoteUrl" -ForegroundColor Green
} else {
    Write-Host "`n✅ Remote déjà configuré : $existingRemote" -ForegroundColor Green
}

# Pousser les modifications
Write-Host "`n📤 Poussage des modifications vers GitHub..." -ForegroundColor Yellow
try {
    git push origin master
    Write-Host "✅ Modifications poussées avec succès !" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors du push : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n🔧 SOLUTIONS POSSIBLES :" -ForegroundColor Yellow
    Write-Host "1. Vérifiez que le repository existe : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor White
    Write-Host "2. Vérifiez vos permissions sur le repository" -ForegroundColor White
    Write-Host "3. Vérifiez votre authentification GitHub" -ForegroundColor White
    Write-Host "4. Si c'est un nouveau repository, utilisez le script deploy_to_github.ps1" -ForegroundColor White
    exit 1
}

# Afficher les informations finales
Write-Host "`n🎉 SUCCÈS ! Votre projet a été mis à jour sur GitHub !" -ForegroundColor Green
Write-Host "📍 URL : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan

Write-Host "`n📋 INFORMATIONS SUR LA MISE À JOUR :" -ForegroundColor Yellow
Write-Host "• Commit : $CommitMessage" -ForegroundColor White
Write-Host "• Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "• Branche : master" -ForegroundColor White

Write-Host "`n🔗 LIENS UTILES :" -ForegroundColor Cyan
Write-Host "• Repository : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor White
Write-Host "• Commits : https://github.com/$GitHubUsername/$RepoName/commits" -ForegroundColor White
Write-Host "• Actions : https://github.com/$GitHubUsername/$RepoName/actions" -ForegroundColor White

Write-Host "`n✅ MISE À JOUR TERMINÉE AVEC SUCCÈS !" -ForegroundColor Green 