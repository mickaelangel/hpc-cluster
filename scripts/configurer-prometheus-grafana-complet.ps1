# Script complet pour configurer Prometheus et Grafana avec toutes les donnees
# Usage: .\scripts\configurer-prometheus-grafana-complet.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION COMPLETE PROMETHEUS/GRAFANA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verifier Prometheus
Write-Host "[1/5] Verification de Prometheus..." -ForegroundColor Yellow
try {
    $prometheusHealth = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -UseBasicParsing -TimeoutSec 5
    if ($prometheusHealth.StatusCode -eq 200) {
        Write-Host "  OK Prometheus accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "  ERREUR: Prometheus non accessible" -ForegroundColor Red
    exit 1
}

# 2. Verifier les targets Prometheus
Write-Host ""
Write-Host "[2/5] Verification des targets Prometheus..." -ForegroundColor Yellow
try {
    $targetsJson = docker exec hpc-prometheus wget -q -O- "http://localhost:9090/api/v1/targets" 2>&1
    $targets = $targetsJson | ConvertFrom-Json
    $activeTargets = $targets.data.activeTargets
    $upTargets = ($activeTargets | Where-Object { $_.health -eq "up" }).Count
    $totalTargets = $activeTargets.Count
    
    Write-Host "  Targets UP: $upTargets/$totalTargets" -ForegroundColor $(if ($upTargets -eq $totalTargets) { "Green" } else { "Yellow" })
    
    if ($upTargets -lt $totalTargets) {
        Write-Host "  ATTENTION: Certains targets ne sont pas UP" -ForegroundColor Yellow
        $activeTargets | Where-Object { $_.health -ne "up" } | ForEach-Object {
            Write-Host "    - $($_.labels.job): $($_.health)" -ForegroundColor Red
            if ($_.lastError) {
                Write-Host "      Erreur: $($_.lastError)" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "  Impossible de verifier les targets" -ForegroundColor Yellow
}

# 3. Verifier les metriques disponibles
Write-Host ""
Write-Host "[3/5] Verification des metriques disponibles..." -ForegroundColor Yellow
try {
    $metricsQuery = docker exec hpc-prometheus wget -q -O- "http://localhost:9090/api/v1/label/__name__/values" 2>&1
    $metrics = $metricsQuery | ConvertFrom-Json
    $metricsCount = $metrics.data.Count
    Write-Host "  OK $metricsCount metriques disponibles dans Prometheus" -ForegroundColor Green
    
    # Tester quelques metriques importantes
    $testMetrics = @("up", "node_cpu_seconds_total", "node_memory_MemTotal_bytes", "cpu_usage_idle")
    $availableMetrics = $metrics.data
    foreach ($testMetric in $testMetrics) {
        if ($availableMetrics -contains $testMetric) {
            Write-Host "    OK Metrique disponible: $testMetric" -ForegroundColor Green
        } else {
            Write-Host "    Metrique non trouvee: $testMetric" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  Impossible de verifier les metriques" -ForegroundColor Yellow
}

# 4. Configurer la source de donnees Prometheus dans Grafana
Write-Host ""
Write-Host "[4/5] Configuration de la source de donnees Prometheus dans Grafana..." -ForegroundColor Yellow

$username = "admin"
$password = '$Password!2026'
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

try {
    # Verifier les sources de donnees existantes
    $datasources = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method Get -TimeoutSec 5
    
    $prometheusExists = $false
    foreach ($ds in $datasources) {
        if ($ds.name -eq "Prometheus") {
            $prometheusExists = $true
            Write-Host "  Source de donnees Prometheus trouvee (ID: $($ds.id), UID: $($ds.uid))" -ForegroundColor Green
            
            # Verifier la configuration
            if ($ds.url -match "172.20.0.10:9090" -or $ds.url -match "localhost:9090" -or $ds.url -match "prometheus:9090") {
                Write-Host "    OK URL correcte: $($ds.url)" -ForegroundColor Green
            } else {
                Write-Host "    ATTENTION: URL peut-etre incorrecte: $($ds.url)" -ForegroundColor Yellow
            }
            
            if ($ds.isDefault) {
                Write-Host "    OK Source de donnees par defaut" -ForegroundColor Green
            } else {
                Write-Host "    ATTENTION: Source de donnees non par defaut" -ForegroundColor Yellow
            }
            
            break
        }
    }
    
    if (-not $prometheusExists) {
        Write-Host "  Creation de la source de donnees Prometheus..." -ForegroundColor Yellow
        
        $datasourceConfig = @{
            name = "Prometheus"
            type = "prometheus"
            access = "proxy"
            url = "http://172.20.0.10:9090"
            isDefault = $true
            editable = $true
            jsonData = @{
                httpMethod = "POST"
                timeInterval = "15s"
            }
        } | ConvertTo-Json
        
        try {
            $result = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method Post -Body $datasourceConfig -TimeoutSec 5
            Write-Host "  OK Source de donnees Prometheus creee" -ForegroundColor Green
        } catch {
            Write-Host "  ERREUR lors de la creation: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        # Mettre a jour la source de donnees pour etre sure qu'elle est correcte
        $prometheusDs = $datasources | Where-Object { $_.name -eq "Prometheus" }
        $updateConfig = @{
            name = "Prometheus"
            type = "prometheus"
            access = "proxy"
            url = "http://172.20.0.10:9090"
            isDefault = $true
            editable = $true
            jsonData = @{
                httpMethod = "POST"
                timeInterval = "15s"
            }
        } | ConvertTo-Json
        
        try {
            $result = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources/$($prometheusDs.id)" -Headers $headers -Method Put -Body $updateConfig -TimeoutSec 5
            Write-Host "  OK Source de donnees Prometheus mise a jour" -ForegroundColor Green
        } catch {
            Write-Host "  ATTENTION: Impossible de mettre a jour la source de donnees" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  ERREUR: Impossible d'acceder a l'API Grafana" -ForegroundColor Red
    Write-Host "  Verifiez que Grafana est demarre et accessible" -ForegroundColor Yellow
}

# 5. Tester une requete PromQL depuis Grafana
Write-Host ""
Write-Host "[5/5] Test d'une requete PromQL..." -ForegroundColor Yellow
try {
    $testQuery = "up"
    $queryUrl = "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=$testQuery"
    $queryResult = Invoke-RestMethod -Uri $queryUrl -Headers $headers -Method Get -TimeoutSec 5
    
    if ($queryResult.status -eq "success" -and $queryResult.data.result.Count -gt 0) {
        $resultCount = $queryResult.data.result.Count
        Write-Host "  OK Requete reussie: $resultCount resultats" -ForegroundColor Green
        Write-Host "    Exemple: $($queryResult.data.result[0].metric.job) = $($queryResult.data.result[0].value[1])" -ForegroundColor Gray
    } else {
        Write-Host "  ATTENTION: Requete reussie mais aucun resultat" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ERREUR: Impossible d'executer une requete PromQL" -ForegroundColor Red
    Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Redemarrer Prometheus pour appliquer les changements
Write-Host ""
Write-Host "Redemarrage de Prometheus pour appliquer les configurations..." -ForegroundColor Yellow
docker restart hpc-prometheus
Start-Sleep -Seconds 5

# Redemarrer Grafana pour appliquer les changements
Write-Host "Redemarrage de Grafana pour appliquer les configurations..." -ForegroundColor Yellow
docker restart hpc-grafana
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION TERMINEE !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour verifier les donnees:" -ForegroundColor Cyan
Write-Host "  1. Ouvrez http://localhost:3000" -ForegroundColor White
Write-Host "  2. Connectez-vous avec admin / `$Password!2026" -ForegroundColor White
Write-Host "  3. Allez dans Dashboards et ouvrez 'HPC Cluster Overview'" -ForegroundColor White
Write-Host "  4. Les donnees devraient maintenant s'afficher" -ForegroundColor White
Write-Host ""
Write-Host "Pour tester Prometheus directement:" -ForegroundColor Cyan
Write-Host "  http://localhost:9090/graph?g0.expr=up&g0.tab=1" -ForegroundColor White
Write-Host ""
