# Script PowerShell pour uploader le Wiki sur GitHub
# Usage: .\scripts\upload-wiki.ps1

$ErrorActionPreference = "Stop"

$WikiDir = ".github\wiki"
$WikiRepo = "https://github.com/mickaelangel/hpc-cluster.wiki.git"
$TempDir = "$env:TEMP\hpc-cluster-wiki"

Write-Host "=== Upload Wiki GitHub ===" -ForegroundColor Cyan

# Vérifier que les fichiers existent
if (-not (Test-Path $WikiDir)) {
    Write-Host "❌ Répertoire $WikiDir introuvable" -ForegroundColor Red
    exit 1
}

# Cloner le Wiki GitHub
Write-Host "📥 Clonage du Wiki GitHub..." -ForegroundColor Yellow
if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
}
git clone $WikiRepo $TempDir

# Copier les fichiers
Write-Host "📋 Copie des fichiers..." -ForegroundColor Yellow
Copy-Item "$WikiDir\*.md" -Destination $TempDir -Force

# Commit et push
Push-Location $TempDir
try {
    git add .
    $commitMessage = "Update wiki pages - $(Get-Date -Format 'yyyy-MM-dd')"
    git commit -m $commitMessage 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        git push origin master
        Write-Host "✅ Wiki uploadé avec succès !" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Aucun changement à commiter" -ForegroundColor Yellow
    }
} finally {
    Pop-Location
}

# Nettoyer
Remove-Item -Recurse -Force $TempDir

Write-Host "🌐 Voir sur : https://github.com/mickaelangel/hpc-cluster/wiki" -ForegroundColor Cyan
