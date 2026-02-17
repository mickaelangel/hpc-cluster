# Script pour charger et verifier les dashboards Grafana
# Usage: .\scripts\charger-dashboards-grafana.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CHARGEMENT DASHBOARDS GRAFANA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$dashboardsDir = Join-Path $projectRoot "grafana-dashboards"

# Verifier que le dossier existe
if (-not (Test-Path $dashboardsDir)) {
    Write-Host "ERREUR: Dossier grafana-dashboards non trouve" -ForegroundColor Red
    exit 1
}

# Compter les dashboards
$dashboards = Get-ChildItem -Path $dashboardsDir -Filter "*.json"
$dashboardCount = $dashboards.Count

Write-Host "Dashboards trouves: $dashboardCount" -ForegroundColor Yellow
Write-Host ""

# Verifier que Grafana est en cours d'execution
$grafanaRunning = docker ps --format '{{.Names}}' | Select-String -Pattern "^hpc-grafana$"
if (-not $grafanaRunning) {
    Write-Host "ERREUR: Grafana n'est pas en cours d'execution" -ForegroundColor Red
    Write-Host "Demarrez Grafana avec: docker start hpc-grafana" -ForegroundColor Yellow
    exit 1
}

Write-Host "Verification de Grafana..." -ForegroundColor Yellow
Write-Host "  OK Grafana en cours d'execution" -ForegroundColor Green
Write-Host ""

# Verifier que les dashboards sont montes
Write-Host "Verification du montage des dashboards..." -ForegroundColor Yellow
$mountedDashboards = docker exec hpc-grafana ls /var/lib/grafana/dashboards/ 2>&1
if ($LASTEXITCODE -eq 0 -and $mountedDashboards) {
    $mountedCount = ($mountedDashboards | Measure-Object -Line).Lines
    Write-Host "  OK $mountedCount dashboards montes dans Grafana" -ForegroundColor Green
} else {
    Write-Host "  ATTENTION: Dashboards non detectes dans le conteneur" -ForegroundColor Yellow
    Write-Host "  Redemarrage de Grafana pour appliquer les changements..." -ForegroundColor Yellow
    docker restart hpc-grafana
    Start-Sleep -Seconds 10
}

Write-Host ""
Write-Host "Verification de la configuration de provisioning..." -ForegroundColor Yellow
$provisioningConfig = docker exec hpc-grafana cat /etc/grafana/provisioning/dashboards/default.yml 2>&1
if ($provisioningConfig -match "HPC Cluster Dashboards") {
    Write-Host "  OK Configuration de provisioning detectee" -ForegroundColor Green
} else {
    Write-Host "  ATTENTION: Configuration de provisioning non trouvee" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Attente du chargement des dashboards (15 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verifier l'API Grafana pour les dashboards
Write-Host ""
Write-Host "Verification via l'API Grafana..." -ForegroundColor Yellow

try {
    # Obtenir le token d'authentification (basique)
    $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:`$Password!2026"))
    $headers = @{
        "Authorization" = "Basic $auth"
        "Content-Type" = "application/json"
    }
    
    # Tester la connexion
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "  OK API Grafana accessible" -ForegroundColor Green
        
        # Essayer de recuperer les dashboards (necessite authentification)
        try {
            $dashboardsApi = Invoke-RestMethod -Uri "http://localhost:3000/api/search?type=dash-db" -Headers $headers -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($dashboardsApi) {
                $apiCount = $dashboardsApi.Count
                Write-Host "  OK $apiCount dashboards detectes via l'API" -ForegroundColor Green
            }
        } catch {
            Write-Host "  Impossible de recuperer la liste via l'API (normal si premiere connexion)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  Impossible de verifier l'API Grafana" -ForegroundColor Yellow
    Write-Host "  Connectez-vous manuellement a http://localhost:3000" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Dashboards disponibles: $dashboardCount" -ForegroundColor Green
Write-Host ""
Write-Host "Pour acceder aux dashboards:" -ForegroundColor Cyan
Write-Host "  1. Ouvrez http://localhost:3000" -ForegroundColor White
Write-Host "  2. Connectez-vous avec:" -ForegroundColor White
Write-Host "     Login: admin" -ForegroundColor Gray
Write-Host "     Mot de passe: `$Password!2026" -ForegroundColor Gray
Write-Host "  3. Allez dans Dashboards pour voir tous les dashboards" -ForegroundColor White
Write-Host ""
Write-Host "Dashboards principaux:" -ForegroundColor Cyan
Write-Host "  - HPC Cluster Overview (vue d'ensemble)" -ForegroundColor White
Write-Host "  - Performance (performances)" -ForegroundColor White
Write-Host "  - Security (securite)" -ForegroundColor White
Write-Host "  - Network IO (reseau)" -ForegroundColor White
Write-Host "  - Slurm Jobs (jobs Slurm)" -ForegroundColor White
Write-Host "  - Et 49 autres dashboards..." -ForegroundColor White
Write-Host ""
