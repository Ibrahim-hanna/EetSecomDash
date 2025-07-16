# Script de déploiement rapide pour EetSecomDash

Write-Host "🚀 DÉPLOIEMENT RAPIDE EetSecomDash SUR GITHUB" -ForegroundColor Green

# Demander le nom d'utilisateur
$username = Read-Host "Entrez votre nom d'utilisateur GitHub"

if (-not $username) {
    Write-Host "❌ Nom d'utilisateur requis" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Utilisateur : $username" -ForegroundColor Green

# Instructions
Write-Host "`n📝 CRÉEZ LE REPOSITORY SUR GITHUB :" -ForegroundColor Yellow
Write-Host "1. Allez sur : https://github.com/new" -ForegroundColor White
Write-Host "2. Nom : EetSecomDash" -ForegroundColor White
Write-Host "3. Description : Dashboard de gestion de projets Spring Boot avec authentification JWT" -ForegroundColor White
Write-Host "4. Public ou Private" -ForegroundColor White
Write-Host "5. NE cochez PAS les options README, .gitignore, license" -ForegroundColor Red
Write-Host "6. Cliquez sur 'Create repository'" -ForegroundColor White

Read-Host "Appuyez sur Entrée une fois le repository créé"

# Configurer et pousser
Write-Host "`n📤 Configuration et push..." -ForegroundColor Yellow

# Supprimer l'ancien remote
git remote remove origin 2>$null

# Ajouter le nouveau remote
git remote add origin "https://github.com/$username/EetSecomDash.git"

# Pousser
git push -u origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 SUCCÈS !" -ForegroundColor Green
    Write-Host "URL : https://github.com/$username/EetSecomDash" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Erreur lors du push" -ForegroundColor Red
    Write-Host "Vérifiez que le repository existe et est vide" -ForegroundColor Yellow
} 