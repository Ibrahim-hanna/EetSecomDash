# Script de mise à jour rapide GitHub pour EetSecomDash

Write-Host "🔄 MISE À JOUR RAPIDE EetSecomDash SUR GITHUB" -ForegroundColor Green

# Demander le nom d'utilisateur
$username = Read-Host "Entrez votre nom d'utilisateur GitHub"

if (-not $username) {
    Write-Host "❌ Nom d'utilisateur requis" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Utilisateur : $username" -ForegroundColor Green

# Vérifier s'il y a des modifications
$gitStatus = git status --porcelain
if (-not $gitStatus) {
    Write-Host "✅ Aucune modification détectée. Projet déjà à jour !" -ForegroundColor Green
    Write-Host "📍 URL : https://github.com/$username/EetSecomDash" -ForegroundColor Cyan
    exit 0
}

Write-Host "📝 Modifications détectées, mise à jour en cours..." -ForegroundColor Yellow

# Ajouter, commiter et pousser
git add .
git commit -m "Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm') - Nouvelles modifications"
git push origin master

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 SUCCÈS ! Projet mis à jour sur GitHub" -ForegroundColor Green
    Write-Host "📍 URL : https://github.com/$username/EetSecomDash" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Erreur lors de la mise à jour" -ForegroundColor Red
    Write-Host "Vérifiez que le repository existe et que vous avez les permissions" -ForegroundColor Yellow
} 