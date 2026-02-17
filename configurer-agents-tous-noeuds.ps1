# Script de configuration et verification des agents sur tous les noeuds
# Usage: .\configurer-agents-tous-noeuds.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION AGENTS - TOUS LES NOEUDS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Liste des noeuds
$frontals = @("hpc-frontal-01", "hpc-frontal-02")
$computes = @("hpc-compute-01", "hpc-compute-02", "hpc-compute-03", "hpc-compute-04", "hpc-compute-05", "hpc-compute-06")
$allNodes = $frontals + $computes

# Fonction de verification d'un agent
function Test-Agent {
    param(
        [string]$Container,
        [string]$Agent,
        [int]$Port
    )
    
    $process = docker exec $Container ps aux 2>&1 | Select-String -Pattern $Agent
    if ($process) {
        Write-Host "  OK $Agent en cours d'execution" -ForegroundColor Green
        
        # Verifier le port
        $netstat = docker exec $Container netstat -tln 2>&1 | Select-String -Pattern ":$Port "
        if ($netstat) {
            Write-Host "    OK Port $Port accessible" -ForegroundColor Green
            return $true
        } else {
            Write-Host "    Port $Port non detecte" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "  $Agent non demarre" -ForegroundColor Red
        return $false
    }
}

# Fonction de test HTTP
function Test-HttpEndpoint {
    param(
        [string]$Container,
        [int]$Port,
        [string]$Path = "/metrics"
    )
    
    $result = docker exec $Container wget -q -O- "http://localhost:$Port$Path" 2>&1
    if ($LASTEXITCODE -eq 0 -and $result) {
        return $true
    }
    
    $result = docker exec $Container curl -s "http://localhost:$Port$Path" 2>&1
    if ($LASTEXITCODE -eq 0 -and $result) {
        return $true
    }
    
    return $false
}

# Fonction de demarrage d'un agent
function Start-Agent {
    param(
        [string]$Container,
        [string]$Agent
    )
    
    Write-Host "  Demarrage de $Agent..." -ForegroundColor Yellow
    
    if ($Agent -eq "node_exporter") {
        docker exec -d $Container /usr/local/bin/node_exporter `
            --web.listen-address=:9100 `
            --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)(`$|/)" 2>&1 | Out-Null
    } elseif ($Agent -eq "telegraf") {
        docker exec -d $Container /usr/local/bin/telegraf --config /etc/telegraf/telegraf.conf 2>&1 | Out-Null
    }
    
    Start-Sleep -Seconds 2
}

# Verification et configuration pour chaque noeud
$totalNodes = $allNodes.Count
$current = 0
$success = 0
$failed = 0

foreach ($node in $allNodes) {
    $current++
    Write-Host ""
    Write-Host "[$current/$totalNodes] Verification: $node" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    # Verifier que le conteneur existe
    $containerExists = docker ps --format '{{.Names}}' | Select-String -Pattern "^${node}$"
    if (-not $containerExists) {
        Write-Host "  Conteneur $node non trouve ou arrete" -ForegroundColor Red
        $failed++
        continue
    }
    
    $nodeOk = $true
    
    # Verifier Node Exporter
    if (-not (Test-Agent $node "node_exporter" 9100)) {
        Start-Agent $node "node_exporter"
        if (-not (Test-Agent $node "node_exporter" 9100)) {
            $nodeOk = $false
        }
    }
    
    # Test HTTP Node Exporter
    if (Test-HttpEndpoint $node 9100 "/metrics") {
        Write-Host "    OK Endpoint /metrics accessible" -ForegroundColor Green
    } else {
        Write-Host "    Endpoint /metrics non accessible" -ForegroundColor Yellow
    }
    
    # Verifier Telegraf
    if (-not (Test-Agent $node "telegraf" 9273)) {
        Start-Agent $node "telegraf"
        if (-not (Test-Agent $node "telegraf" 9273)) {
            $nodeOk = $false
        }
    }
    
    # Test HTTP Telegraf
    if (Test-HttpEndpoint $node 9273 "/metrics") {
        Write-Host "    OK Endpoint Telegraf /metrics accessible" -ForegroundColor Green
    } else {
        Write-Host "    Endpoint Telegraf /metrics non accessible" -ForegroundColor Yellow
    }
    
    if ($nodeOk) {
        $success++
        Write-Host "  OK $node : Tous les agents fonctionnent" -ForegroundColor Green
    } else {
        $failed++
        Write-Host "  $node : Problemes detectes" -ForegroundColor Red
    }
}

# Resume
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OK Noeuds operationnels: $success/$totalNodes" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Noeuds avec problemes: $failed/$totalNodes" -ForegroundColor Red
}
Write-Host ""

# Verification Prometheus
Write-Host "Verification Prometheus..." -ForegroundColor Cyan
$prometheusExists = docker ps --format '{{.Names}}' | Select-String -Pattern "^hpc-prometheus$"
if ($prometheusExists) {
    Write-Host "  OK Prometheus en cours d'execution" -ForegroundColor Green
    
    Write-Host "  Verification des targets Prometheus..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    $targets = docker exec hpc-prometheus wget -q -O- "http://localhost:9090/api/v1/targets" 2>&1
    if ($targets -match "health") {
        Write-Host "  OK API Prometheus accessible" -ForegroundColor Green
    } else {
        Write-Host "  Impossible de verifier les targets Prometheus" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Prometheus non trouve" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration terminee !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour verifier les metriques:" -ForegroundColor Cyan
Write-Host "  - Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  - Grafana: http://localhost:3000" -ForegroundColor White
Write-Host ""
