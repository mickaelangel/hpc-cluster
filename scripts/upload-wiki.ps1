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

try {
    git clone $WikiRepo $TempDir 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Le Wiki GitHub n'est pas encore activé !" -ForegroundColor Red
        Write-Host "" -ForegroundColor Yellow
        Write-Host "📋 Pour activer le Wiki :" -ForegroundColor Yellow
        Write-Host "   1. Aller sur: https://github.com/mickaelangel/hpc-cluster/settings" -ForegroundColor White
        Write-Host "   2. Dans le menu de gauche, cliquer sur 'Features'" -ForegroundColor White
        Write-Host "   3. Cocher 'Wikis' pour activer" -ForegroundColor White
        Write-Host "   4. Sauvegarder" -ForegroundColor White
        Write-Host "" -ForegroundColor Yellow
        Write-Host "   Ensuite, réexécutez ce script." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors du clonage : $_" -ForegroundColor Red
    Write-Host "   Vérifiez que le Wiki est activé sur GitHub." -ForegroundColor Yellow
    exit 1
}

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
