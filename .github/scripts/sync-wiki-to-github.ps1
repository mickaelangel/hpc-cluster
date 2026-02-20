# Sync .github/wiki/ vers le Wiki GitHub (onglet Wiki du projet)
# Usage: exécuter depuis la racine du repo "cluster hpc"

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot + "\..\.."
$wikiSource = Join-Path $repoRoot ".github\wiki"
$wikiClonePath = Join-Path $repoRoot "hpc-cluster.wiki"

Write-Host "Source wiki: $wikiSource" -ForegroundColor Cyan
Write-Host "Clone wiki GitHub: $wikiClonePath" -ForegroundColor Cyan

# 1. Cloner le depot wiki GitHub (s'il n'existe pas)
if (-not (Test-Path $wikiClonePath)) {
    Write-Host "`nClonage du wiki GitHub..." -ForegroundColor Yellow
    $parentDir = Split-Path $wikiClonePath -Parent
    $wikiDirName = Split-Path $wikiClonePath -Leaf
    Set-Location $parentDir
    git clone https://github.com/mickaelangel/hpc-cluster.wiki.git $wikiDirName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERREUR: Impossible de cloner le wiki. Activez d'abord le Wiki dans les parametres du depot GitHub (Settings -> General -> Features -> Wiki)." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nDepot wiki deja clone. Mise a jour (git pull)..." -ForegroundColor Yellow
    Set-Location $wikiClonePath
    git pull origin main 2>$null
    if ($LASTEXITCODE -ne 0) { git pull origin master 2>$null }
}

Set-Location $wikiClonePath

# 2. Copier tous les .md de .github/wiki/ vers la racine du wiki
Write-Host "`nCopie des pages depuis .github\wiki\ vers le wiki..." -ForegroundColor Yellow
$files = Get-ChildItem -Path $wikiSource -Filter "*.md"
foreach ($f in $files) {
    Copy-Item -Path $f.FullName -Destination (Join-Path $wikiClonePath $f.Name) -Force
    Write-Host "  -> $($f.Name)"
}

# 3. Commit et push
git add *.md
git status
$count = (git status --short | Measure-Object -Line).Lines
if ($count -eq 0) {
    Write-Host "`nAucun changement." -ForegroundColor Gray
    exit 0
}
Write-Host "`nCommit des modifications..." -ForegroundColor Yellow
git commit -m "Sync wiki depuis .github/wiki (manuel HPC, cours, glossaire, volumes)"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Rien a committer (deja a jour?)." -ForegroundColor Gray
    exit 0
}
Write-Host "`nPush vers GitHub Wiki..." -ForegroundColor Yellow
git push origin main 2>$null
if ($LASTEXITCODE -ne 0) { git push origin master }
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR: Push echoue. Verifiez vos identifiants (credential.helper)." -ForegroundColor Red
    exit 1
}
Write-Host "`nTermine. Ouvrez: https://github.com/mickaelangel/hpc-cluster/wiki" -ForegroundColor Green
