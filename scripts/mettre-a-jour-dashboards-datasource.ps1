# Script pour mettre a jour tous les dashboards avec la bonne source de donnees
# Usage: .\scripts\mettre-a-jour-dashboards-datasource.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MISE A JOUR DASHBOARDS - SOURCE DE DONNEES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$dashboardsDir = Join-Path $projectRoot "grafana-dashboards"

# Authentification Grafana
$username = "admin"
$password = '$Password!2026'
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

# Obtenir l'UID de la source de donnees Prometheus
Write-Host "[1/3] Recuperation de l'UID Prometheus..." -ForegroundColor Yellow
try {
    $datasources = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method Get -TimeoutSec 5
    $prometheus = $datasources | Where-Object { $_.name -eq "Prometheus" }
    if ($prometheus) {
        $prometheusUid = $prometheus.uid
        $prometheusName = $prometheus.name
        Write-Host "  OK UID Prometheus: $prometheusUid" -ForegroundColor Green
        Write-Host "  OK Nom: $prometheusName" -ForegroundColor Green
    } else {
        Write-Host "  ERREUR: Source de donnees Prometheus non trouvee" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ERREUR: Impossible d'acceder a l'API Grafana" -ForegroundColor Red
    exit 1
}

# Fonction pour mettre a jour un dashboard
function Update-DashboardDatasource {
    param(
        [string]$DashboardUid,
        [string]$PrometheusUid,
        [string]$PrometheusName
    )
    
    try {
        # Recuperer le dashboard actuel
        $dashboard = Invoke-RestMethod -Uri "http://localhost:3000/api/dashboards/uid/$DashboardUid" -Headers $headers -Method Get -TimeoutSec 5
        
        $updated = $false
        $dashboardObj = $dashboard.dashboard
        
        # Fonction recursive pour mettre a jour les datasources
        function Update-DatasourceInObject {
            param($obj)
            
            if ($obj -is [PSCustomObject] -or $obj -is [Hashtable]) {
                $props = if ($obj -is [PSCustomObject]) { $obj.PSObject.Properties } else { $obj.Keys }
                
                foreach ($prop in $props) {
                    $key = if ($obj -is [PSCustomObject]) { $prop.Name } else { $prop }
                    $value = if ($obj -is [PSCustomObject]) { $prop.Value } else { $obj[$prop] }
                    
                    # Mettre a jour datasource
                    if ($key -eq "datasource") {
                        if ($value -is [PSCustomObject] -or $value -is [Hashtable]) {
                            if ($value.uid -or $value.name) {
                                $value.uid = $PrometheusUid
                                $value.name = $PrometheusName
                                $value.type = "prometheus"
                                $script:updated = $true
                            }
                        } elseif ($value -is [String]) {
                            if ($value -ne $PrometheusUid -and $value -ne $PrometheusName) {
                                if ($obj -is [PSCustomObject]) {
                                    $obj.$key = @{
                                        uid = $PrometheusUid
                                        type = "prometheus"
                                    }
                                } else {
                                    $obj[$key] = @{
                                        uid = $PrometheusUid
                                        type = "prometheus"
                                    }
                                }
                                $script:updated = $true
                            }
                        }
                    } else {
                        # Recursion
                        Update-DatasourceInObject -obj $value
                    }
                }
            } elseif ($obj -is [Array]) {
                foreach ($item in $obj) {
                    Update-DatasourceInObject -obj $item
                }
            }
        }
        
        # Mettre a jour le dashboard
        Update-DatasourceInObject -obj $dashboardObj
        
        if ($updated) {
            # Sauvegarder le dashboard
            $payload = @{
                dashboard = $dashboardObj
                overwrite = $true
            } | ConvertTo-Json -Depth 20
            
            $result = Invoke-RestMethod -Uri "http://localhost:3000/api/dashboards/db" -Headers $headers -Method Post -Body $payload -TimeoutSec 10
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# Recuperer tous les dashboards
Write-Host ""
Write-Host "[2/3] Recuperation de la liste des dashboards..." -ForegroundColor Yellow
try {
    $allDashboards = Invoke-RestMethod -Uri "http://localhost:3000/api/search?type=dash-db" -Headers $headers -Method Get -TimeoutSec 5
    $dashboardCount = $allDashboards.Count
    Write-Host "  OK $dashboardCount dashboards trouves" -ForegroundColor Green
} catch {
    Write-Host "  ERREUR: Impossible de recuperer la liste des dashboards" -ForegroundColor Red
    exit 1
}

# Mettre a jour chaque dashboard
Write-Host ""
Write-Host "[3/3] Mise a jour des dashboards..." -ForegroundColor Yellow
$updated = 0
$skipped = 0
$failed = 0

foreach ($db in $allDashboards) {
    $dbTitle = $db.title
    $dbUid = $db.uid
    Write-Host "  Mise a jour: $dbTitle..." -ForegroundColor Gray -NoNewline
    
    if (Update-DashboardDatasource -DashboardUid $dbUid -PrometheusUid $prometheusUid -PrometheusName $prometheusName) {
        Write-Host " OK" -ForegroundColor Green
        $updated++
    } else {
        Write-Host " DEJA A JOUR" -ForegroundColor Yellow
        $skipped++
    }
    
    Start-Sleep -Milliseconds 100
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Total dashboards: $dashboardCount" -ForegroundColor White
Write-Host "  Mis a jour: $updated" -ForegroundColor Green
Write-Host "  Deja a jour: $skipped" -ForegroundColor Yellow
if ($failed -gt 0) {
    Write-Host "  Echecs: $failed" -ForegroundColor Red
}
Write-Host ""

Write-Host "Les dashboards devraient maintenant afficher les donnees !" -ForegroundColor Green
Write-Host ""
Write-Host "Testez en ouvrant:" -ForegroundColor Cyan
Write-Host "  http://localhost:3000/d/hpc-cluster-overview" -ForegroundColor White
Write-Host ""
