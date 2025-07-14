# Test des permissions pour les employés
# Ce script teste que les employés ne peuvent pas voir les boutons d'action

Write-Host "=== Test des permissions employé ===" -ForegroundColor Green

# 1. Créer un utilisateur employé
Write-Host "1. Création d'un utilisateur employé..." -ForegroundColor Yellow
$employeData = @{
    email = "employe@test.com"
    password = "employe123"
    username = "Employé Test"
    role = "EMPLOYE"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" -Method POST -Body $employeData -ContentType "application/json"
Write-Host "Utilisateur employé créé: $($response.message)" -ForegroundColor Green

# 2. Se connecter en tant qu'employé
Write-Host "`n2. Connexion en tant qu'employé..." -ForegroundColor Yellow
$loginData = @{
    email = "employe@test.com"
    password = "employe123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
Write-Host "Connexion employé réussie: $($loginResponse.message)" -ForegroundColor Green

# 3. Tester l'accès au dashboard
Write-Host "`n3. Test d'accès au dashboard..." -ForegroundColor Yellow
try {
    $dashboardResponse = Invoke-WebRequest -Uri "http://localhost:8080/dashboard" -Method GET
    Write-Host "Dashboard accessible pour l'employé" -ForegroundColor Green
} catch {
    Write-Host "Erreur d'accès au dashboard: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Tester les endpoints API avec restrictions
Write-Host "`n4. Test des endpoints API..." -ForegroundColor Yellow

# Test création de projet (devrait être refusé)
try {
    $projetData = @{
        numeroProjet = "TEST-EMPLOYE-001"
        client = "Client Test"
        designation = "Projet test employé"
    } | ConvertTo-Json
    
    $createResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/projets" -Method POST -Body $projetData -ContentType "application/json"
    Write-Host "ERREUR: L'employé a pu créer un projet (ne devrait pas être possible)" -ForegroundColor Red
} catch {
    Write-Host "SUCCÈS: L'employé ne peut pas créer de projet (comportement attendu)" -ForegroundColor Green
}

# Test modification de projet (devrait être refusé)
try {
    $updateData = @{
        numeroProjet = "TEST-EMPLOYE-MODIFIED"
        client = "Client Test Modifié"
    } | ConvertTo-Json
    
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/projets/1" -Method PUT -Body $updateData -ContentType "application/json"
    Write-Host "ERREUR: L'employé a pu modifier un projet (ne devrait pas être possible)" -ForegroundColor Red
} catch {
    Write-Host "SUCCÈS: L'employé ne peut pas modifier de projet (comportement attendu)" -ForegroundColor Green
}

# Test suppression de projet (devrait être refusé)
try {
    $deleteResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/projets/1" -Method DELETE
    Write-Host "ERREUR: L'employé a pu supprimer un projet (ne devrait pas être possible)" -ForegroundColor Red
} catch {
    Write-Host "SUCCÈS: L'employé ne peut pas supprimer de projet (comportement attendu)" -ForegroundColor Green
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Green
Write-Host "Vérifiez manuellement dans le navigateur que les boutons d'action sont masqués pour l'employé" -ForegroundColor Cyan 