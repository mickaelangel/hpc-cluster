# Script de verification rapide du statut des agents
# Usage: .\verifier-agents-status.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STATUT DES AGENTS - CLUSTER HPC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Liste des noeuds
$frontals = @("hpc-frontal-01", "hpc-frontal-02")
$computes = @("hpc-compute-01", "hpc-compute-02", "hpc-compute-03", "hpc-compute-04", "hpc-compute-05", "hpc-compute-06")
$allNodes = $frontals + $computes

Write-Host "Verification des agents sur tous les noeuds..." -ForegroundColor Yellow
Write-Host ""

$totalOk = 0
$totalNodes = 0

foreach ($node in $allNodes) {
    $totalNodes++
    $nodeExporter = docker exec $node ps aux 2>&1 | Select-String -Pattern "node_exporter"
    $telegraf = docker exec $node ps aux 2>&1 | Select-String -Pattern "telegraf"
    
    $nodeOk = $false
    if ($nodeExporter -and $telegraf) {
        Write-Host "  OK $node : Node Exporter + Telegraf" -ForegroundColor Green
        $nodeOk = $true
        $totalOk++
    } else {
        Write-Host "  $node : Problemes detectes" -ForegroundColor Red
        if (-not $nodeExporter) { Write-Host "    - Node Exporter manquant" -ForegroundColor Yellow }
        if (-not $telegraf) { Write-Host "    - Telegraf manquant" -ForegroundColor Yellow }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUME" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Noeuds operationnels: $totalOk/$totalNodes" -ForegroundColor $(if ($totalOk -eq $totalNodes) { "Green" } else { "Yellow" })
Write-Host ""

# Verification Prometheus
Write-Host "Verification Prometheus Targets..." -ForegroundColor Cyan
try {
    $targetsJson = docker exec hpc-prometheus wget -q -O- "http://localhost:9090/api/v1/targets" 2>&1
    $targets = $targetsJson | ConvertFrom-Json
    
    $activeTargets = $targets.data.activeTargets
    $upTargets = ($activeTargets | Where-Object { $_.health -eq "up" }).Count
    $totalTargets = $activeTargets.Count
    
    Write-Host "  Targets actifs: $upTargets/$totalTargets" -ForegroundColor $(if ($upTargets -eq $totalTargets) { "Green" } else { "Yellow" })
    
    if ($upTargets -eq $totalTargets) {
        Write-Host "  OK Tous les targets Prometheus sont UP !" -ForegroundColor Green
    } else {
        Write-Host "  Certains targets ne sont pas UP" -ForegroundColor Yellow
        $activeTargets | Where-Object { $_.health -ne "up" } | ForEach-Object {
            Write-Host "    - $($_.labels.job) : $($_.health)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "  Impossible de verifier les targets Prometheus" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ACCES AUX SERVICES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Prometheus:  http://localhost:9090" -ForegroundColor White
Write-Host "  Grafana:     http://localhost:3000 (admin / `$Password!2026)" -ForegroundColor White
Write-Host "  JupyterHub:  http://localhost:8000" -ForegroundColor White
Write-Host ""
