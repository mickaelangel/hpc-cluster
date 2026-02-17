#!/bin/bash
# ============================================================================
# Script de Tests Slurm
# Tests de soumission et gestion de jobs
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compteurs
PASSED=0
FAILED=0

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TESTS SLURM${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. TESTS SERVICES
# ============================================================================
echo -e "\n${YELLOW}[1/5] Tests services...${NC}"

# Test SlurmCTLD
if systemctl is-active slurmctld > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ SlurmCTLD actif${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ SlurmCTLD inactif${NC}"
    ((FAILED++))
fi

# Test SlurmDBD
if systemctl is-active slurmdbd > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ SlurmDBD actif${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}  ⚠️  SlurmDBD inactif (optionnel)${NC}"
fi

# Test Munge
if systemctl is-active munge > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Munge actif${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Munge inactif${NC}"
    ((FAILED++))
fi

# ============================================================================
# 2. TESTS CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/5] Tests configuration...${NC}"

# Test configuration Slurm
if [ -f /etc/slurm/slurm.conf ]; then
    echo -e "${GREEN}  ✅ Configuration Slurm présente${NC}"
    ((PASSED++))
    
    # Test validation configuration
    if scontrol ping > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ Configuration Slurm valide${NC}"
        ((PASSED++))
    else
        echo -e "${RED}  ❌ Configuration Slurm invalide${NC}"
        ((FAILED++))
    fi
else
    echo -e "${RED}  ❌ Configuration Slurm manquante${NC}"
    ((FAILED++))
fi

# Test clé Munge
if [ -f /etc/munge/munge.key ]; then
    echo -e "${GREEN}  ✅ Clé Munge présente${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Clé Munge manquante${NC}"
    ((FAILED++))
fi

# ============================================================================
# 3. TESTS CONNECTIVITÉ
# ============================================================================
echo -e "\n${YELLOW}[3/5] Tests connectivité...${NC}"

# Test ping Slurm
if scontrol ping > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Slurm accessible${NC}"
    ((PASSED++))
    
    # Afficher le statut
    STATUS=$(scontrol ping 2>&1)
    echo -e "${GREEN}    $STATUS${NC}"
else
    echo -e "${RED}  ❌ Slurm non accessible${NC}"
    ((FAILED++))
fi

# Test Munge
if munge -n | unmunge > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Munge fonctionnel${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Munge non fonctionnel${NC}"
    ((FAILED++))
fi

# ============================================================================
# 4. TESTS NŒUDS
# ============================================================================
echo -e "\n${YELLOW}[4/5] Tests nœuds...${NC}"

# Lister les nœuds
NODES=$(sinfo -h -o "%N" 2>/dev/null | head -1)
if [ -n "$NODES" ]; then
    echo -e "${GREEN}  ✅ Nœuds détectés: $NODES${NC}"
    ((PASSED++))
    
    # Vérifier l'état des nœuds
    NODE_STATE=$(sinfo -h -o "%T" 2>/dev/null | head -1)
    if [ "$NODE_STATE" == "idle" ] || [ "$NODE_STATE" == "mixed" ] || [ "$NODE_STATE" == "allocated" ]; then
        echo -e "${GREEN}  ✅ Nœuds en état valide: $NODE_STATE${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}  ⚠️  État des nœuds: $NODE_STATE${NC}"
    fi
else
    echo -e "${RED}  ❌ Aucun nœud détecté${NC}"
    ((FAILED++))
fi

# ============================================================================
# 5. TESTS SOUMISSION JOBS
# ============================================================================
echo -e "\n${YELLOW}[5/5] Tests soumission jobs...${NC}"

# Créer un script de test
TEST_SCRIPT=$(mktemp)
cat > "$TEST_SCRIPT" <<'EOF'
#!/bin/bash
#SBATCH --job-name=test-job
#SBATCH --output=/tmp/test-job-%j.out
#SBATCH --time=1:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

echo "Test job executed successfully"
hostname
date
EOF

chmod +x "$TEST_SCRIPT"

# Soumettre un job
JOB_ID=$(sbatch "$TEST_SCRIPT" 2>&1 | grep -oP '\d+')
if [ -n "$JOB_ID" ]; then
    echo -e "${GREEN}  ✅ Job soumis: $JOB_ID${NC}"
    ((PASSED++))
    
    # Attendre que le job se termine
    sleep 5
    
    # Vérifier le statut
    JOB_STATE=$(squeue -j $JOB_ID -h -o "%T" 2>/dev/null)
    if [ -z "$JOB_STATE" ]; then
        echo -e "${GREEN}  ✅ Job terminé${NC}"
        ((PASSED++))
        
        # Vérifier la sortie
        if [ -f "/tmp/test-job-${JOB_ID}.out" ]; then
            echo -e "${GREEN}  ✅ Sortie du job présente${NC}"
            ((PASSED++))
        fi
    else
        echo -e "${YELLOW}  ⚠️  Job en cours: $JOB_STATE${NC}"
    fi
else
    echo -e "${RED}  ❌ Échec soumission job${NC}"
    ((FAILED++))
fi

# Nettoyer
rm -f "$TEST_SCRIPT"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}RÉSUMÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tests réussis: ${PASSED}${NC}"
echo -e "${RED}Tests échoués: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ Tous les tests Slurm passent!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Des tests ont échoué${NC}"
    exit 1
fi
