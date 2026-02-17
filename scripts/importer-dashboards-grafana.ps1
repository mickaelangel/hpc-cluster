# Script pour importer les dashboards Grafana via l'API
# Usage: .\scripts\importer-dashboards-grafana.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPORT DASHBOARDS GRAFANA VIA API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$dashboardsDir = Join-Path $projectRoot "grafana-dashboards"

# Verifier que Grafana est accessible
Write-Host "[1/4] Verification de Grafana..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5
    if ($health.StatusCode -eq 200) {
        Write-Host "  OK Grafana accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "  ERREUR: Grafana n'est pas accessible" -ForegroundColor Red
    Write-Host "  Verifiez que Grafana est demarre: docker ps | findstr grafana" -ForegroundColor Yellow
    exit 1
}

# Authentification
Write-Host ""
Write-Host "[2/4] Authentification..." -ForegroundColor Yellow
$username = "admin"
$password = '$Password!2026'
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

# Tester l'authentification
try {
    $userInfo = Invoke-RestMethod -Uri "http://localhost:3000/api/user" -Headers $headers -Method Get -TimeoutSec 5
    Write-Host "  OK Authentifie en tant que: $($userInfo.login)" -ForegroundColor Green
} catch {
    Write-Host "  ERREUR: Authentification echouee" -ForegroundColor Red
    Write-Host "  Verifiez les identifiants dans docker-compose-opensource.yml" -ForegroundColor Yellow
    exit 1
}

# Verifier la source de donnees Prometheus
Write-Host ""
Write-Host "[3/4] Verification de la source de donnees Prometheus..." -ForegroundColor Yellow
try {
    $datasources = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method Get -TimeoutSec 5
    $prometheus = $datasources | Where-Object { $_.name -eq "Prometheus" }
    if ($prometheus) {
        Write-Host "  OK Source de donnees Prometheus trouvee (ID: $($prometheus.id))" -ForegroundColor Green
        $prometheusId = $prometheus.id
    } else {
        Write-Host "  ATTENTION: Source de donnees Prometheus non trouvee" -ForegroundColor Yellow
        Write-Host "  Les dashboards peuvent ne pas fonctionner correctement" -ForegroundColor Yellow
        $prometheusId = 1  # ID par defaut
    }
} catch {
    Write-Host "  ATTENTION: Impossible de verifier les sources de donnees" -ForegroundColor Yellow
    $prometheusId = 1
}

# Importer les dashboards
Write-Host ""
Write-Host "[4/4] Import des dashboards..." -ForegroundColor Yellow

$dashboards = Get-ChildItem -Path $dashboardsDir -Filter "*.json"
$total = $dashboards.Count
$success = 0
$failed = 0
$skipped = 0

Write-Host "  $total dashboards a importer..." -ForegroundColor Gray
Write-Host ""

foreach ($dashboardFile in $dashboards) {
    $fileName = $dashboardFile.Name
    Write-Host "  Import: $fileName..." -ForegroundColor Gray -NoNewline
    
    try {
        # Lire le contenu du dashboard
        $dashboardContent = Get-Content -Path $dashboardFile.FullName -Raw | ConvertFrom-Json
        
        # S'assurer que le dashboard a la bonne structure
        if ($dashboardContent.dashboard) {
            $dashboard = $dashboardContent.dashboard
        } else {
            $dashboard = $dashboardContent
        }
        
        # Mettre a jour l'ID de la source de donnees si necessaire
        if ($prometheusId) {
            # Parcourir tous les panneaux et mettre a jour les datasource
            if ($dashboard.panels) {
                foreach ($panel in $dashboard.panels) {
                    if ($panel.targets) {
                        foreach ($target in $panel.targets) {
                            if (-not $target.datasource) {
                                $target | Add-Member -MemberType NoteProperty -Name "datasource" -Value @{
                                    type = "prometheus"
                                    uid = "Prometheus"
                                } -Force
                            }
                        }
                    }
                }
            }
        }
        
        # Preparer le payload pour l'API
        $payload = @{
            dashboard = $dashboard
            overwrite = $true
            folderId = 0  # Dossier racine
        } | ConvertTo-Json -Depth 20
        
        # Importer via l'API
        $result = Invoke-RestMethod -Uri "http://localhost:3000/api/dashboards/db" -Headers $headers -Method Post -Body $payload -TimeoutSec 10
        
        if ($result) {
            Write-Host " OK" -ForegroundColor Green
            $success++
        } else {
            Write-Host " ECHEC" -ForegroundColor Red
            $failed++
        }
    } catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -match "already exists" -or $errorMsg -match "409") {
            Write-Host " DEJA IMPORTE" -ForegroundColor Yellow
            $skipped++
        } else {
            Write-Host " ECHEC: $errorMsg" -ForegroundColor Red
            $failed++
        }
    }
    
    # Petite pause pour ne pas surcharger l'API
    Start-Sleep -Milliseconds 200
}

# Resume
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Total: $total dashboards" -ForegroundColor White
Write-Host "  OK Importes: $success" -ForegroundColor Green
Write-Host "  Deja importes: $skipped" -ForegroundColor Yellow
if ($failed -gt 0) {
    Write-Host "  Echecs: $failed" -ForegroundColor Red
}
Write-Host ""

# Verifier les dashboards importes
Write-Host "Verification des dashboards importes..." -ForegroundColor Yellow
try {
    $importedDashboards = Invoke-RestMethod -Uri "http://localhost:3000/api/search?type=dash-db" -Headers $headers -Method Get -TimeoutSec 5
    $importedCount = $importedDashboards.Count
    Write-Host "  OK $importedCount dashboards disponibles dans Grafana" -ForegroundColor Green
} catch {
    Write-Host "  Impossible de verifier la liste des dashboards" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPORT TERMINE !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour voir les dashboards:" -ForegroundColor Cyan
Write-Host "  1. Ouvrez http://localhost:3000" -ForegroundColor White
Write-Host "  2. Connectez-vous avec admin / `$Password!2026" -ForegroundColor White
Write-Host "  3. Cliquez sur 'Dashboards' dans le menu de gauche" -ForegroundColor White
Write-Host "  4. Vous devriez voir tous les dashboards importes" -ForegroundColor White
Write-Host ""
