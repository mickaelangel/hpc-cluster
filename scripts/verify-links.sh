#!/bin/bash
# ============================================================================
# Script de Vérification des Liens dans la Documentation
# Usage: bash scripts/verify-links.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

BROKEN_LINKS=0
TOTAL_LINKS=0

echo -e "${YELLOW}Vérification des liens dans la documentation...${NC}"
echo ""

# Fonction pour vérifier un lien
check_link() {
    local link=$1
    local file=$2
    ((TOTAL_LINKS++))
    
    # Ignorer les liens locaux (commençant par #)
    if [[ "$link" =~ ^# ]]; then
        return 0
    fi
    
    # Ignorer les liens mailto
    if [[ "$link" =~ ^mailto: ]]; then
        return 0
    fi
    
    # Vérifier les liens HTTP/HTTPS
    if [[ "$link" =~ ^https?:// ]]; then
        if curl -sf --head "$link" > /dev/null 2>&1; then
            return 0
        else
            echo -e "${RED}  ❌ Lien cassé: $link (dans $file)${NC}"
            ((BROKEN_LINKS++))
            return 1
        fi
    fi
    
    # Vérifier les liens relatifs
    if [[ "$link" =~ ^\./ ]] || [[ ! "$link" =~ ^/ ]] && [[ ! "$link" =~ ^https?:// ]]; then
        local target_file="$PROJECT_ROOT/$(dirname "$file")/$link"
        if [ -f "$target_file" ] || [ -d "$target_file" ]; then
            return 0
        else
            echo -e "${RED}  ❌ Fichier introuvable: $link (dans $file)${NC}"
            ((BROKEN_LINKS++))
            return 1
        fi
    fi
    
    return 0
}

# Parcourir tous les fichiers Markdown
find docs -name "*.md" -type f | while read -r file; do
    # Extraire les liens Markdown [text](link)
    grep -oP '\[([^\]]+)\]\(([^)]+)\)' "$file" | while IFS= read -r match; do
        link=$(echo "$match" | sed -n 's/.*(\(.*\))/\1/p')
        if [ -n "$link" ]; then
            check_link "$link" "$file" || true
        fi
    done
done

echo ""
echo -e "${YELLOW}Résultats:${NC}"
echo -e "  Total de liens vérifiés: $TOTAL_LINKS"
if [ $BROKEN_LINKS -eq 0 ]; then
    echo -e "${GREEN}  ✅ Aucun lien cassé${NC}"
    exit 0
else
    echo -e "${RED}  ❌ $BROKEN_LINKS lien(s) cassé(s)${NC}"
    exit 1
fi
