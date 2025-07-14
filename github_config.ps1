# Configuration GitHub pour EetSecomDash
# Remplacez YOUR_GITHUB_USERNAME par votre nom d'utilisateur GitHub réel

$GitHubUsername = "YOUR_GITHUB_USERNAME"  # Remplacez par votre nom d'utilisateur
$RepoName = "EetSecomDash"

Write-Host "=== Configuration GitHub pour EetSecomDash ===" -ForegroundColor Green
Write-Host "Nom d'utilisateur GitHub : $GitHubUsername" -ForegroundColor Yellow
Write-Host "Nom du repository : $RepoName" -ForegroundColor Yellow

# Vérifier si le remote existe déjà
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Remote 'origin' existe déjà : $existingRemote" -ForegroundColor Yellow
    $response = Read-Host "Voulez-vous le remplacer ? (y/n)"
    if ($response -eq "y" -or $response -eq "Y") {
        git remote remove origin
        Write-Host "Remote 'origin' supprimé" -ForegroundColor Green
    } else {
        Write-Host "Opération annulée" -ForegroundColor Red
        exit
    }
}

# Ajouter le remote
$remoteUrl = "https://github.com/$GitHubUsername/$RepoName.git"
git remote add origin $remoteUrl
Write-Host "Remote 'origin' ajouté : $remoteUrl" -ForegroundColor Green

# Pousser le code
Write-Host "Poussage du code vers GitHub..." -ForegroundColor Green
git push -u origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCÈS ! Votre projet est maintenant sur GitHub !" -ForegroundColor Green
    Write-Host "URL : https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
    Write-Host "`nProchaines étapes recommandées :" -ForegroundColor Yellow
    Write-Host "1. Ajouter une licence (MIT, Apache, etc.)" -ForegroundColor White
    Write-Host "2. Configurer GitHub Actions pour l'CI/CD" -ForegroundColor White
    Write-Host "3. Créer des releases pour marquer les versions" -ForegroundColor White
    Write-Host "4. Ajouter des topics pour améliorer la découvrabilité" -ForegroundColor White
} else {
    Write-Host "`n❌ Erreur lors du push. Vérifiez que :" -ForegroundColor Red
    Write-Host "1. Le repository existe sur GitHub" -ForegroundColor White
    Write-Host "2. Votre nom d'utilisateur est correct" -ForegroundColor White
    Write-Host "3. Vous avez les permissions nécessaires" -ForegroundColor White
}

Write-Host "`n=== FIN ===" -ForegroundColor Green 