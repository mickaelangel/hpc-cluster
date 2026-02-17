#!/bin/bash
# ============================================================================
# Tests Intégration - Cluster HPC
# Tests d'intégration entre composants
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TESTS INTÉGRATION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. TEST AUTHENTIFICATION → SLURM
# ============================================================================
echo -e "\n${YELLOW}[1/5] Test Authentification → Slurm...${NC}"

# Test LDAP
if ldapsearch -x -b "dc=cluster,dc=local" -s base &> /dev/null; then
    echo -e "${GREEN}  ✅ LDAP accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  LDAP non accessible${NC}"
fi

# Test Kerberos
if klist &> /dev/null || kinit -k host/$(hostname)@CLUSTER.LOCAL &> /dev/null; then
    echo -e "${GREEN}  ✅ Kerberos fonctionnel${NC}"
else
    echo -e "${YELLOW}  ⚠️  Kerberos non configuré${NC}"
fi

# Test Slurm avec authentification
if squeue &> /dev/null; then
    echo -e "${GREEN}  ✅ Slurm accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Slurm non accessible${NC}"
fi

# ============================================================================
# 2. TEST SLURM → STOCKAGE
# ============================================================================
echo -e "\n${YELLOW}[2/5] Test Slurm → Stockage...${NC}"

# Test montage BeeGFS
if mountpoint -q /mnt/beegfs 2>/dev/null || df -h | grep -q beegfs; then
    echo -e "${GREEN}  ✅ BeeGFS monté${NC}"
    
    # Test écriture
    TEST_FILE="/mnt/beegfs/test_$$.txt"
    echo "test" > "$TEST_FILE" 2>/dev/null && {
        rm -f "$TEST_FILE"
        echo -e "${GREEN}  ✅ Écriture BeeGFS fonctionnelle${NC}"
    } || {
        echo -e "${YELLOW}  ⚠️  Écriture BeeGFS échouée${NC}"
    }
else
    echo -e "${YELLOW}  ⚠️  BeeGFS non monté${NC}"
fi

# ============================================================================
# 3. TEST MONITORING → SERVICES
# ============================================================================
echo -e "\n${YELLOW}[3/5] Test Monitoring → Services...${NC}"

# Test Prometheus
if curl -s http://localhost:9090/-/healthy &> /dev/null; then
    echo -e "${GREEN}  ✅ Prometheus accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Prometheus non accessible${NC}"
fi

# Test Grafana
if curl -s http://localhost:3000/api/health &> /dev/null; then
    echo -e "${GREEN}  ✅ Grafana accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Grafana non accessible${NC}"
fi

# Test métriques
if curl -s http://localhost:9090/api/v1/query?query=up &> /dev/null; then
    echo -e "${GREEN}  ✅ Métriques Prometheus disponibles${NC}"
else
    echo -e "${YELLOW}  ⚠️  Métriques Prometheus non disponibles${NC}"
fi

# ============================================================================
# 4. TEST APPLICATIONS → SLURM
# ============================================================================
echo -e "\n${YELLOW}[4/5] Test Applications → Slurm...${NC}"

# Test soumission job simple
TEST_JOB="/tmp/test_job_$$.sh"
cat > "$TEST_JOB" <<EOF
#!/bin/bash
#SBATCH --job-name=test-integration
#SBATCH --time=00:01:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

echo "Test integration"
hostname
date
EOF

chmod +x "$TEST_JOB"

if sbatch "$TEST_JOB" &> /dev/null; then
    echo -e "${GREEN}  ✅ Soumission job Slurm fonctionnelle${NC}"
    sleep 2
    scancel -n test-integration &> /dev/null || true
else
    echo -e "${YELLOW}  ⚠️  Soumission job Slurm échouée${NC}"
fi

rm -f "$TEST_JOB"

# ============================================================================
# 5. TEST RÉSEAU → SERVICES
# ============================================================================
echo -e "\n${YELLOW}[5/5] Test Réseau → Services...${NC}"

# Test connectivité entre nœuds
NODES=("frontal-01" "frontal-02" "compute-01" "compute-02")
for node in "${NODES[@]}"; do
    if ping -c 1 -W 1 "$node" &> /dev/null; then
        echo -e "${GREEN}  ✅ $node accessible${NC}"
    else
        echo -e "${YELLOW}  ⚠️  $node non accessible${NC}"
    fi
done

echo -e "\n${GREEN}=== TESTS INTÉGRATION TERMINÉS ===${NC}"
