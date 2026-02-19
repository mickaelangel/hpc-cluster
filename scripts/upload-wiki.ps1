# Script PowerShell pour uploader le Wiki sur GitHub
# Usage: .\scripts\upload-wiki.ps1

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$WikiDir = ".github\wiki"
$WikiRepo = "https://github.com/mickaelangel/hpc-cluster.wiki.git"
$TempDir = "$env:TEMP\hpc-cluster-wiki"

Write-Host "=== Upload Wiki GitHub ===" -ForegroundColor Cyan

# Vérifier que les fichiers existent
if (-not (Test-Path $WikiDir)) {
    Write-Host "ERREUR: Repertoire $WikiDir introuvable" -ForegroundColor Red
    exit 1
}

# Cloner le Wiki GitHub
Write-Host "Clonage du Wiki GitHub..." -ForegroundColor Yellow
if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
}

# Cloner le wiki (ignorer les messages de sortie)
$ErrorActionPreference = "SilentlyContinue"
git clone $WikiRepo $TempDir 2>&1 | Out-Null
$ErrorActionPreference = "Stop"

# Vérifier si le clonage a réussi en vérifiant l'existence du répertoire
Start-Sleep -Seconds 2
if (-not (Test-Path $TempDir)) {
    Write-Host "ERREUR: Le Wiki GitHub n'est pas encore active ou erreur de clonage !" -ForegroundColor Red
    Write-Host "" -ForegroundColor Yellow
    Write-Host "Pour activer le Wiki :" -ForegroundColor Yellow
    Write-Host "   1. Aller sur: https://github.com/mickaelangel/hpc-cluster/settings" -ForegroundColor White
    Write-Host "   2. Dans le menu de gauche, cliquer sur Features" -ForegroundColor White
    Write-Host "   3. Cocher Wikis pour activer" -ForegroundColor White
    Write-Host "   4. Sauvegarder" -ForegroundColor White
    Write-Host "" -ForegroundColor Yellow
    Write-Host "   Ensuite, reexecutez ce script." -ForegroundColor Yellow
    exit 1
}
Write-Host "Clonage reussi !" -ForegroundColor Green

# Copier les fichiers
Write-Host "Copie des fichiers..." -ForegroundColor Yellow
Copy-Item "$WikiDir\*.md" -Destination $TempDir -Force

# Commit et push
Push-Location $TempDir
try {
    git add .
    $dateStr = Get-Date -Format "yyyy-MM-dd"
    $commitMessage = "Update wiki pages - $dateStr"
    $commitOutput = git commit -m $commitMessage 2>&1
    $commitExitCode = $LASTEXITCODE
    
    if ($commitExitCode -eq 0) {
        Write-Host "Commit reussi, push en cours..." -ForegroundColor Yellow
        git push origin master
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCES: Wiki uploade avec succes !" -ForegroundColor Green
        } else {
            Write-Host "ERREUR: Echec du push vers GitHub" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "INFO: Aucun changement a commiter (deja a jour)" -ForegroundColor Yellow
    }
} finally {
    Pop-Location
}

# Nettoyer
Remove-Item -Recurse -Force $TempDir

Write-Host "Voir sur : https://github.com/mickaelangel/hpc-cluster/wiki" -ForegroundColor Cyan
