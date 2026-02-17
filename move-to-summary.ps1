# Script PowerShell pour déplacer les fichiers vers summary/
# Usage: .\move-to-summary.ps1

$ErrorActionPreference = "SilentlyContinue"

# Créer le dossier summary s'il n'existe pas
if (-not (Test-Path "summary")) {
    New-Item -ItemType Directory -Path "summary"
}

# Déplacer les fichiers
Write-Host "Déplacement des fichiers vers summary/..."

# RESUME
Get-ChildItem -Filter "*RESUME*.md" | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - RESUME_*.md déplacés"

# TOUT
Get-ChildItem -Filter "*TOUT*.md" | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - TOUT_*.md déplacés"

# AMELIORATIONS
Get-ChildItem -Filter "*AMELIORATIONS*.md" | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - AMELIORATIONS_*.md déplacés"

# VERIFICATION
Get-ChildItem -Filter "*VERIFICATION*.md" | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - VERIFICATION_*.md déplacés"

# STATISTIQUES
Get-ChildItem -Filter "*STATISTIQUES*.md" | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - STATISTIQUES_*.md déplacés"

# FINAL (sauf README et guides)
Get-ChildItem -Filter "*FINAL*.md" | Where-Object { $_.Name -notlike "README*" -and $_.Name -notlike "GUIDE*" } | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - FINAL_*.md déplacés"

# DEPLOIEMENT
Get-ChildItem -Filter "*DEPLOIEMENT*.md" | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - DEPLOIEMENT_*.md déplacés"

# SECURITE (sauf README et guides)
Get-ChildItem -Filter "*SECURITE*.md" | Where-Object { $_.Name -notlike "README*" -and $_.Name -notlike "GUIDE*" } | Move-Item -Destination "summary/" -ErrorAction SilentlyContinue
Write-Host "  - SECURITE_*.md déplacés"

Write-Host ""
Write-Host "Terminé !"
