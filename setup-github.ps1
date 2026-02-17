# ============================================================================
# Script PowerShell de configuration Git et GitHub pour le Cluster HPC
# ============================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CONFIGURATION GIT ET GITHUB" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration Git (demander à l'utilisateur)
Write-Host "Configuration Git :" -ForegroundColor Yellow
$GIT_NAME = Read-Host "Votre nom (pour Git)"
$GIT_EMAIL = Read-Host "Votre email (pour Git)"

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

Write-Host ""
Write-Host "✅ Git configuré avec :" -ForegroundColor Green
Write-Host "   Nom: $GIT_NAME"
Write-Host "   Email: $GIT_EMAIL"
Write-Host ""

# Vérifier si le dépôt est déjà initialisé
if (-not (Test-Path ".git")) {
    Write-Host "Initialisation du dépôt Git..." -ForegroundColor Yellow
    git init
}

# Ajouter tous les fichiers
Write-Host "Ajout des fichiers au dépôt..." -ForegroundColor Yellow
git add .

# Premier commit
Write-Host "Création du premier commit..." -ForegroundColor Yellow
git commit -m "Initial commit: Cluster HPC complet - 2 frontaux + 6 nœuds + monitoring complet

- Architecture: 2 frontaux + 6 nœuds de calcul
- Monitoring: Prometheus, Grafana, InfluxDB, Loki, Promtail
- Applications: JupyterHub, Slurm, GlusterFS
- 253+ scripts d'installation
- 85+ guides documentation
- 54 dashboards Grafana
- 100% Open-Source pour SUSE 15 SP4"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✅ DÉPÔT GIT PRÊT" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes :" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Créer un compte GitHub (si pas encore fait) :" -ForegroundColor Yellow
Write-Host "   https://github.com/signup"
Write-Host ""
Write-Host "2. Créer un nouveau dépôt sur GitHub :" -ForegroundColor Yellow
Write-Host "   - Aller sur https://github.com/new"
Write-Host "   - Nom du dépôt: hpc-cluster (ou autre nom)"
Write-Host "   - Ne PAS initialiser avec README, .gitignore ou licence"
Write-Host "   - Cliquer sur 'Create repository'"
Write-Host ""
Write-Host "3. Connecter le dépôt local à GitHub :" -ForegroundColor Yellow
Write-Host "   git remote add origin https://github.com/VOTRE_USERNAME/hpc-cluster.git"
Write-Host "   git branch -M main"
Write-Host "   git push -u origin main"
Write-Host ""
Write-Host "4. Si GitHub demande une authentification :" -ForegroundColor Yellow
Write-Host "   - Utiliser un Personal Access Token (PAT)"
Write-Host "   - Créer un token: https://github.com/settings/tokens"
Write-Host "   - Permissions: repo (toutes les permissions repo)"
Write-Host ""
