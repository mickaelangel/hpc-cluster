#!/bin/bash
# ============================================================================
# Script de configuration Git et GitHub pour le Cluster HPC
# ============================================================================

echo "=========================================="
echo "CONFIGURATION GIT ET GITHUB"
echo "=========================================="
echo ""

# Configuration Git (demander à l'utilisateur)
echo "Configuration Git :"
read -p "Votre nom (pour Git) : " GIT_NAME
read -p "Votre email (pour Git) : " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo ""
echo "✅ Git configuré avec :"
echo "   Nom: $GIT_NAME"
echo "   Email: $GIT_EMAIL"
echo ""

# Vérifier si le dépôt est déjà initialisé
if [ ! -d ".git" ]; then
    echo "Initialisation du dépôt Git..."
    git init
fi

# Ajouter tous les fichiers
echo "Ajout des fichiers au dépôt..."
git add .

# Premier commit
echo "Création du premier commit..."
git commit -m "Initial commit: Cluster HPC complet - 2 frontaux + 6 nœuds + monitoring complet

- Architecture: 2 frontaux + 6 nœuds de calcul
- Monitoring: Prometheus, Grafana, InfluxDB, Loki, Promtail
- Applications: JupyterHub, Slurm, GlusterFS
- 253+ scripts d'installation
- 85+ guides documentation
- 54 dashboards Grafana
- 100% Open-Source pour SUSE 15 SP4"

echo ""
echo "=========================================="
echo "✅ DÉPÔT GIT PRÊT"
echo "=========================================="
echo ""
echo "Prochaines étapes :"
echo ""
echo "1. Créer un compte GitHub (si pas encore fait) :"
echo "   https://github.com/signup"
echo ""
echo "2. Créer un nouveau dépôt sur GitHub :"
echo "   - Aller sur https://github.com/new"
echo "   - Nom du dépôt: hpc-cluster (ou autre nom)"
echo "   - Ne PAS initialiser avec README, .gitignore ou licence"
echo "   - Cliquer sur 'Create repository'"
echo ""
echo "3. Connecter le dépôt local à GitHub :"
echo "   git remote add origin https://github.com/VOTRE_USERNAME/hpc-cluster.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "4. Si GitHub demande une authentification :"
echo "   - Utiliser un Personal Access Token (PAT)"
echo "   - Créer un token: https://github.com/settings/tokens"
echo "   - Permissions: repo (toutes les permissions repo)"
echo ""
