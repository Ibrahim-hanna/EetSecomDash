Write-Host "Testing API..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/projets" -UseBasicParsing -TimeoutSec 10
    Write-Host "API Status: $($response.StatusCode)"
    $projects = $response.Content | ConvertFrom-Json
    Write-Host "Projects count: $($projects.Count)"
    
    if ($projects.Count -gt 0) {
        Write-Host "First project:"
        Write-Host "  Client: $($projects[0].client)"
        Write-Host "  Numero: $($projects[0].numeroProjet)"
        Write-Host "  Designation: $($projects[0].designation)"
    }
} catch {
    Write-Host "API Error: $($_.Exception.Message)"
} 