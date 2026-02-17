#!/bin/bash
# Script pour uploader le Wiki sur GitHub
# Usage: ./scripts/upload-wiki.sh

set -e

WIKI_DIR=".github/wiki"
WIKI_REPO="https://github.com/mickaelangel/hpc-cluster.wiki.git"
TEMP_DIR="/tmp/hpc-cluster-wiki"

echo "=== Upload Wiki GitHub ==="

# Vérifier que les fichiers existent
if [ ! -d "$WIKI_DIR" ]; then
    echo "❌ Répertoire $WIKI_DIR introuvable"
    exit 1
fi

# Cloner le Wiki GitHub
echo "📥 Clonage du Wiki GitHub..."
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

if ! git clone "$WIKI_REPO" "$TEMP_DIR" 2>&1; then
    echo "❌ Le Wiki GitHub n'est pas encore activé !"
    echo ""
    echo "📋 Pour activer le Wiki :"
    echo "   1. Aller sur: https://github.com/mickaelangel/hpc-cluster/settings"
    echo "   2. Dans le menu de gauche, cliquer sur 'Features'"
    echo "   3. Cocher 'Wikis' pour activer"
    echo "   4. Sauvegarder"
    echo ""
    echo "   Ensuite, réexécutez ce script."
    exit 1
fi

# Copier les fichiers
echo "📋 Copie des fichiers..."
cp "$WIKI_DIR"/*.md "$TEMP_DIR/"

# Commit et push
cd "$TEMP_DIR"
git add .
git commit -m "Update wiki pages - $(date +%Y-%m-%d)" || echo "Aucun changement"
git push origin master

# Nettoyer
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo "✅ Wiki uploadé avec succès !"
echo "🌐 Voir sur : https://github.com/mickaelangel/hpc-cluster/wiki"
