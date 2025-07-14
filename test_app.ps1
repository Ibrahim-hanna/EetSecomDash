Write-Host "Testing application availability..."

# Attendre que l'application démarre
Start-Sleep -Seconds 30

# Vérifier si le port 8080 est ouvert
$port8080 = netstat -an | findstr ":8080"
if ($port8080) {
    Write-Host "Port 8080 is open"
    Write-Host $port8080
} else {
    Write-Host "Port 8080 is not open"
}

# Tester l'accès à l'application
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/dashboard" -UseBasicParsing -TimeoutSec 10
    Write-Host "Application is responding with status: $($response.StatusCode)"
} catch {
    Write-Host "Application is not responding: $($_.Exception.Message)"
}

# Tester l'API des projets
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -UseBasicParsing -TimeoutSec 10
    Write-Host "API is responding with status: $($response.StatusCode)"
    Write-Host "Response length: $($response.Content.Length) characters"
} catch {
    Write-Host "API is not responding: $($_.Exception.Message)"
} 