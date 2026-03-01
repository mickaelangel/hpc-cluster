#!/bin/bash
# ============================================================================
# Vérification des variables d'environnement pour le mode PROD
# Usage: HPC_MODE=prod . scripts/check-env-prod.sh
#        ou depuis docker/ : source ../scripts/check-env-prod.sh
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODE="${HPC_MODE:-demo}"
REQUIRED_VARS=(
    "GF_SECURITY_ADMIN_PASSWORD"
    "DOCKER_INFLUXDB_INIT_PASSWORD"
)
MISSING=()
for var in "${REQUIRED_VARS[@]}"; do
    eval "val=\${${var}:-}"
    if [ -z "${val}" ]; then
        MISSING+=("$var")
    fi
done

if [ "$MODE" != "prod" ]; then
    echo -e "${GREEN}Mode $MODE : vérification prod ignorée (secrets optionnels).${NC}"
    exit 0
fi

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${RED}ERREUR — Mode PROD actif mais variables manquantes ou vides :${NC}"
    printf '  - %s\n' "${MISSING[@]}"
    echo ""
    echo -e "${YELLOW}En production, définir toutes les variables dans .env (copier .env.example et remplacer les valeurs).${NC}"
    echo "  cp .env.example .env && éditer .env"
    exit 1
fi

# Détection de valeurs "démo" (optionnel, avertissement)
DEMO_PASSWORDS=("demo-hpc-2024" "admin1234" "ChangeMeInProduction!")
eval "gf=\${GF_SECURITY_ADMIN_PASSWORD:-}"
for d in "${DEMO_PASSWORDS[@]}"; do
    if [ "$gf" = "$d" ]; then
        echo -e "${YELLOW}ATTENTION : GF_SECURITY_ADMIN_PASSWORD ressemble à une valeur de démo. En prod, utilisez un mot de passe fort.${NC}"
        break
    fi
done

echo -e "${GREEN}Variables PROD requises présentes.${NC}"
exit 0
