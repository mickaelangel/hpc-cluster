#!/bin/bash
# ============================================================================
# Vérification des Liens entre Documents
# Vérifie que tous les liens dans les fichiers Markdown sont valides
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}VÉRIFICATION DES LIENS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Compteurs
TOTAL_LINKS=0
VALID_LINKS=0
INVALID_LINKS=0
INVALID_FILES=()

# Fonction pour vérifier un lien
check_link() {
    local file=$1
    local link=$2
    
    ((TOTAL_LINKS++))
    
    # Nettoyer le lien (enlever #anchor, etc.)
    local clean_link=$(echo "$link" | sed 's/#.*$//')
    
    # Vérifier si le fichier existe
    if [ -f "$clean_link" ] || [ -d "$clean_link" ]; then
        ((VALID_LINKS++))
        return 0
    else
        ((INVALID_LINKS++))
        INVALID_FILES+=("$file -> $link")
        echo -e "${RED}  ❌ Lien invalide dans $file: $link${NC}"
        return 1
    fi
}

# Parcourir tous les fichiers Markdown
echo -e "${YELLOW}Analyse des fichiers Markdown...${NC}"

while IFS= read -r -d '' file; do
    # Extraire tous les liens Markdown [text](link)
    while IFS= read -r line; do
        # Pattern pour [text](link)
        if [[ $line =~ \[.*\]\(([^)]+)\) ]]; then
            link="${BASH_REMATCH[1]}"
            # Ignorer les liens HTTP/HTTPS
            if [[ ! $link =~ ^https?:// ]]; then
                check_link "$file" "$link"
            fi
        fi
    done < <(grep -o '\[.*\]([^)]*)' "$file" 2>/dev/null || true)
done < <(find . -name "*.md" -type f -print0 2>/dev/null)

# Résumé
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ VÉRIFICATION${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✅ Liens valides: $VALID_LINKS${NC}"
echo -e "${RED}  ❌ Liens invalides: $INVALID_LINKS${NC}"
echo -e "${CYAN}  📊 Total liens: $TOTAL_LINKS${NC}"
echo ""

if [ $INVALID_LINKS -gt 0 ]; then
    echo -e "${YELLOW}Liens invalides détectés:${NC}"
    for invalid in "${INVALID_FILES[@]}"; do
        echo -e "${YELLOW}  - $invalid${NC}"
    done
    echo ""
    exit 1
else
    echo -e "${GREEN}🎉 Tous les liens sont valides !${NC}"
    exit 0
fi
