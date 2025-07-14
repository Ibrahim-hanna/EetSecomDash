# Script de déploiement interactif pour EetSecomDash
# Ce script vous guide étape par étape pour déployer sur GitHub

Write-Host "🚀 === DÉPLOIEMENT EetSecomDash SUR GITHUB ===" -ForegroundColor Green
Write-Host "Ce script va vous guider pour déployer votre projet sur GitHub" -ForegroundColor Cyan

# Demander le nom d'utilisateur GitHub
Write-Host "`n📝 Veuillez entrer votre nom d'utilisateur GitHub :" -ForegroundColor Yellow
$GitHubUsername = Read-Host

if (-not $GitHubUsername) {
    Write-Host "❌ Nom d'utilisateur requis. Déploiement annulé." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Nom d'utilisateur : $GitHubUsername" -ForegroundColor Green

# Vérifier l'état Git
Write-Host "`n📋 Vérification de l'état Git..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  Modifications détectées. Voulez-vous les commiter ? (y/n)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq "y" -or $response -eq "Y") {
        git add .
        git commit -m "Auto-commit before GitHub deployment"
        Write-Host "✅ Modifications commitées" -ForegroundColor Green
    } else {
        Write-Host "❌ Déploiement annulé" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Aucune modification en attente" -ForegroundColor Green
}

# Supprimer l'ancien remote s'il existe
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "`n🔄 Suppression de l'ancien remote..." -ForegroundColor Yellow
    git remote remove origin
    Write-Host "✅ Ancien remote supprimé" -ForegroundColor Green
}

# Ajouter le nouveau remote
Write-Host "`n🔗 Configuration du remote GitHub..." -ForegroundColor Yellow
$remoteUrl = "https://github.com/$GitHubUsername/EetSecomDash.git"
git remote add origin $remoteUrl
Write-Host "✅ Remote configuré : $remoteUrl" -ForegroundColor Green

# Instructions pour créer le repository
Write-Host "`n📝 CRÉATION DU REPOSITORY SUR GITHUB" -ForegroundColor Yellow
Write-Host "1. Ouvrez votre navigateur et allez sur : https://github.com/new" -ForegroundColor White
Write-Host "2. Remplissez les informations suivantes :" -ForegroundColor White
Write-Host "   • Repository name : EetSecomDash" -ForegroundColor Cyan
Write-Host "   • Description : Dashboard de gestion de projets Spring Boot avec authentification JWT" -ForegroundColor Cyan
Write-Host "   • Visibility : Public ou Private (selon vos préférences)" -ForegroundColor Cyan
Write-Host "   • NE cochez PAS 'Add a README file'" -ForegroundColor Red
Write-Host "   • NE cochez PAS 'Add .gitignore'" -ForegroundColor Red
Write-Host "   • NE cochez PAS 'Choose a license'" -ForegroundColor Red
Write-Host "3. Cliquez sur 'Create repository'" -ForegroundColor White

Write-Host "`n⏳ Une fois le repository créé, appuyez sur Entrée pour continuer..." -ForegroundColor Yellow
Read-Host

# Pousser le code
Write-Host "`n📤 Poussage du code vers GitHub..." -ForegroundColor Yellow
try {
    git push -u origin master
    Write-Host "✅ Code poussé avec succès !" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors du push : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n🔧 Vérifiez que :" -ForegroundColor Yellow
    Write-Host "1. Le repository existe sur GitHub" -ForegroundColor White
    Write-Host "2. Votre nom d'utilisateur est correct : $GitHubUsername" -ForegroundColor White
    Write-Host "3. Vous avez les permissions nécessaires" -ForegroundColor White
    Write-Host "4. Le repository est vide (pas de README, .gitignore, ou license)" -ForegroundColor White
    exit 1
}

# Succès !
Write-Host "`n🎉 SUCCÈS ! Votre projet est maintenant sur GitHub !" -ForegroundColor Green
Write-Host "📍 URL : https://github.com/$GitHubUsername/EetSecomDash" -ForegroundColor Cyan

Write-Host "`n📋 PROCHAINES ÉTAPES RECOMMANDÉES :" -ForegroundColor Yellow
Write-Host "1. 🌟 Ajouter des topics : spring-boot, java, dashboard, jwt" -ForegroundColor White
Write-Host "2. 📝 Créer une release v1.0.0" -ForegroundColor White
Write-Host "3. 🔧 Vérifier que les GitHub Actions fonctionnent" -ForegroundColor White
Write-Host "4. 📖 Améliorer la documentation si nécessaire" -ForegroundColor White

Write-Host "`n🔗 LIENS UTILES :" -ForegroundColor Cyan
Write-Host "• Repository : https://github.com/$GitHubUsername/EetSecomDash" -ForegroundColor White
Write-Host "• Actions : https://github.com/$GitHubUsername/EetSecomDash/actions" -ForegroundColor White
Write-Host "• Issues : https://github.com/$GitHubUsername/EetSecomDash/issues" -ForegroundColor White
Write-Host "• Releases : https://github.com/$GitHubUsername/EetSecomDash/releases" -ForegroundColor White

Write-Host "`n✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !" -ForegroundColor Green
Write-Host "Votre projet EetSecomDash est maintenant professionnel et prêt pour la collaboration ! 🚀" -ForegroundColor Cyan 