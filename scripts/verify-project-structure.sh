#!/bin/bash
# ============================================================================
# Script de Vérification de la Structure du Projet
# Usage: bash scripts/verify-project-structure.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${YELLOW}Vérification de la structure du projet...${NC}"
echo ""

# Fonction pour vérifier l'existence d'un fichier/dossier
check_exists() {
    local path=$1
    local type=$2  # "file" ou "dir"
    local required=${3:-true}  # true par défaut
    
    if [ "$type" == "file" ]; then
        if [ -f "$path" ]; then
            echo -e "${GREEN}  ✅ $path${NC}"
            return 0
        else
            if [ "$required" == "true" ]; then
                echo -e "${RED}  ❌ $path (manquant)${NC}"
                ((ERRORS++))
                return 1
            else
                echo -e "${YELLOW}  ⚠️  $path (optionnel, manquant)${NC}"
                ((WARNINGS++))
                return 0
            fi
        fi
    else
        if [ -d "$path" ]; then
            echo -e "${GREEN}  ✅ $path/${NC}"
            return 0
        else
            if [ "$required" == "true" ]; then
                echo -e "${RED}  ❌ $path/ (manquant)${NC}"
                ((ERRORS++))
                return 1
            else
                echo -e "${YELLOW}  ⚠️  $path/ (optionnel, manquant)${NC}"
                ((WARNINGS++))
                return 0
            fi
        fi
    fi
}

# Fichiers essentiels
echo -e "${YELLOW}[1/6] Fichiers essentiels...${NC}"
check_exists "README.md" "file"
check_exists "LICENSE" "file"
check_exists "SECURITY.md" "file"
check_exists "CONTRIBUTING.md" "file"
check_exists "CHANGELOG.md" "file"
check_exists ".gitignore" "file"

# Structure des dossiers
echo -e "\n${YELLOW}[2/6] Structure des dossiers...${NC}"
check_exists "docs" "dir"
check_exists "scripts" "dir"
check_exists "docker" "dir"
check_exists "configs" "dir"
check_exists "tests" "dir"
check_exists "terraform" "dir"
check_exists "ansible" "dir"
check_exists "helm" "dir"

# Docker
echo -e "\n${YELLOW}[3/6] Configuration Docker...${NC}"
check_exists "docker/docker-compose-opensource.yml" "file"
check_exists "docker/docker-compose.prod.yml" "file"
check_exists "docker/frontal/Dockerfile" "file"
check_exists "docker/client/Dockerfile" "file"

# Tests
echo -e "\n${YELLOW}[4/6] Tests...${NC}"
check_exists "tests/unit" "dir"
check_exists "tests/integration" "dir"
check_exists "tests/unit/test_scripts.sh" "file"
check_exists "tests/integration/test_cluster_integration.sh" "file"

# CI/CD
echo -e "\n${YELLOW}[5/6] CI/CD...${NC}"
check_exists ".github/workflows" "dir"
check_exists ".github/workflows/ci.yml" "file"
check_exists ".github/workflows/docker-publish.yml" "file"
check_exists ".github/dependabot.yml" "file"

# Documentation
echo -e "\n${YELLOW}[6/6] Documentation...${NC}"
check_exists "docs/API.md" "file" "false"
check_exists "docs/RUNBOOK.md" "file" "false"
check_exists "docs/ARCHITECTURE_DIAGRAMS.md" "file" "false"
check_exists "docs/SLA_SLO.md" "file" "false"

echo ""
echo -e "${YELLOW}Résultats:${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  ✅ Structure du projet valide${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}  ⚠️  $WARNINGS avertissement(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}  ❌ $ERRORS erreur(s) détectée(s)${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}  ⚠️  $WARNINGS avertissement(s)${NC}"
    fi
    exit 1
fi
