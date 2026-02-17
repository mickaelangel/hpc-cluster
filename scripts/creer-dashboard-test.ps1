# Script pour creer un dashboard de test simple
# Usage: .\scripts\creer-dashboard-test.ps1

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CREATION DASHBOARD DE TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Authentification
$username = "admin"
$password = '$Password!2026'
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${password}"))
$headers = @{
    "Authorization" = "Basic $auth"
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

# Obtenir l'UID Prometheus
$datasources = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers $headers -Method Get -TimeoutSec 5
$prometheus = $datasources | Where-Object { $_.name -eq "Prometheus" }
$prometheusUid = $prometheus.uid

Write-Host "Creation d'un dashboard de test simple..." -ForegroundColor Yellow

# Dashboard de test avec des metriques de base
$testDashboard = @{
    dashboard = @{
        title = "Test HPC - Donnees Disponibles"
        tags = @("test", "hpc")
        timezone = "browser"
        schemaVersion = 38
        version = 1
        refresh = "10s"
        panels = @(
            @{
                id = 1
                title = "Status des Noeuds (UP/DOWN)"
                type = "stat"
                gridPos = @{ h = 8; w = 12; x = 0; y = 0 }
                targets = @(
                    @{
                        expr = "up{job=~'.*-node'}"
                        refId = "A"
                        legendFormat = "{{instance}}"
                        datasource = @{
                            uid = $prometheusUid
                            type = "prometheus"
                        }
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        mappings = @(
                            @{
                                type = "value"
                                options = @{
                                    "0" = @{ text = "DOWN"; color = "red" }
                                    "1" = @{ text = "UP"; color = "green" }
                                }
                            }
                        )
                        thresholds = @{
                            mode = "absolute"
                            steps = @(
                                @{ value = 0; color = "red" }
                                @{ value = 1; color = "green" }
                            )
                        }
                    }
                }
            }
            @{
                id = 2
                title = "CPU Usage par Noeud"
                type = "timeseries"
                gridPos = @{ h = 8; w = 12; x = 12; y = 0 }
                targets = @(
                    @{
                        expr = "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=`"idle`"}[5m])) * 100)"
                        refId = "A"
                        legendFormat = "{{instance}}"
                        datasource = @{
                            uid = $prometheusUid
                            type = "prometheus"
                        }
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        unit = "percent"
                        min = 0
                        max = 100
                    }
                }
            }
            @{
                id = 3
                title = "Memoire Utilisee"
                type = "timeseries"
                gridPos = @{ h = 8; w = 12; x = 0; y = 8 }
                targets = @(
                    @{
                        expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
                        refId = "A"
                        legendFormat = "{{instance}}"
                        datasource = @{
                            uid = $prometheusUid
                            type = "prometheus"
                        }
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        unit = "percent"
                        min = 0
                        max = 100
                    }
                }
            }
            @{
                id = 4
                title = "Metriques Telegraf - CPU"
                type = "timeseries"
                gridPos = @{ h = 8; w = 12; x = 12; y = 8 }
                targets = @(
                    @{
                        expr = "cpu_usage_idle{role=~'frontal|compute'}"
                        refId = "A"
                        legendFormat = "{{instance}} - {{host}}"
                        datasource = @{
                            uid = $prometheusUid
                            type = "prometheus"
                        }
                    }
                )
                fieldConfig = @{
                    defaults = @{
                        unit = "short"
                    }
                }
            }
        )
    }
    overwrite = $true
    folderId = 0
} | ConvertTo-Json -Depth 20

# Importer le dashboard
try {
    $result = Invoke-RestMethod -Uri "http://localhost:3000/api/dashboards/db" -Headers $headers -Method Post -Body $testDashboard -TimeoutSec 10
    
    if ($result) {
        Write-Host "OK Dashboard de test cree avec succes !" -ForegroundColor Green
        Write-Host ""
        Write-Host "Pour voir le dashboard:" -ForegroundColor Cyan
        Write-Host "  http://localhost:3000/d/$($result.uid)" -ForegroundColor White
        Write-Host ""
        Write-Host "Ou cherchez 'Test HPC - Donnees Disponibles' dans la liste des dashboards" -ForegroundColor White
    }
} catch {
    Write-Host "ERREUR lors de la creation: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
