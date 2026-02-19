#!/bin/bash
# ============================================================================
# Script de Protection du Dépôt GitHub
# Usage: bash scripts/github/protect-repository.sh
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

REPO_OWNER="mickaelangel"
REPO_NAME="hpc-cluster"
BRANCH="main"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PROTECTION DU DÉPÔT GITHUB${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Vérifier que GitHub CLI est installé
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) n'est pas installé${NC}"
    echo -e "${YELLOW}Installation:${NC}"
    echo "  Windows: winget install GitHub.cli"
    echo "  Linux: https://cli.github.com/"
    exit 1
fi

# Vérifier l'authentification
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Authentification GitHub requise${NC}"
    echo -e "${YELLOW}Exécutez: gh auth login${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/3] Vérification de l'accès au dépôt...${NC}"
if ! gh repo view "${REPO_OWNER}/${REPO_NAME}" &> /dev/null; then
    echo -e "${RED}❌ Dépôt ${REPO_OWNER}/${REPO_NAME} non accessible${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dépôt accessible${NC}"

echo -e "${YELLOW}[2/3] Configuration de la protection de branche...${NC}"

# Configuration de la protection
gh api "repos/${REPO_OWNER}/${REPO_NAME}/branches/${BRANCH}/protection" \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions='{"users":["'"${REPO_OWNER}"'"],"teams":[]}' \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_linear_history=true \
  --field allow_squash_merge=false \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=true

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Protection de branche configurée${NC}"
else
    echo -e "${RED}❌ Erreur lors de la configuration${NC}"
    exit 1
fi

echo -e "${YELLOW}[3/3] Vérification de la protection...${NC}"
PROTECTION=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}/branches/${BRANCH}/protection" 2>/dev/null || echo "")

if [ -n "$PROTECTION" ]; then
    echo -e "${GREEN}✅ Protection activée avec succès${NC}"
    echo ""
    echo -e "${BLUE}Configuration appliquée:${NC}"
    echo "  ✅ Pull requests requis avant merge"
    echo "  ✅ 1 approbation requise"
    echo "  ✅ Code owners requis"
    echo "  ✅ Force pushes désactivés"
    echo "  ✅ Suppression de branche désactivée"
    echo "  ✅ Historique linéaire requis"
    echo "  ✅ Restrictions: seul ${REPO_OWNER} peut push"
    echo ""
    echo -e "${YELLOW}Note: Vous pouvez toujours push directement sur ${BRANCH}${NC}"
    echo -e "${YELLOW}(enforce_admins=false)${NC}"
else
    echo -e "${RED}❌ Erreur lors de la vérification${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PROTECTION CONFIGURÉE AVEC SUCCÈS${NC}"
echo -e "${GREEN}========================================${NC}"
