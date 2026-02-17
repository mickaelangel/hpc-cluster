#!/bin/bash
# ============================================================================
# Suite de Tests Automatisés Complets - Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SUITE DE TESTS AUTOMATISÉS${NC}"
echo -e "${GREEN}========================================${NC}"

PASSED=0
FAILED=0

# Test 1: Services système
echo -e "\n${YELLOW}[1/10] Test services système...${NC}"
systemctl is-active sshd && ((PASSED++)) || ((FAILED++))
systemctl is-active NetworkManager && ((PASSED++)) || ((FAILED++))

# Test 2: Slurm
echo -e "\n${YELLOW}[2/10] Test Slurm...${NC}"
sinfo && ((PASSED++)) || ((FAILED++))

# Test 3: Authentification
echo -e "\n${YELLOW}[3/10] Test authentification...${NC}"
ldapsearch -x -b "dc=cluster,dc=local" -s base && ((PASSED++)) || ((FAILED++))

# Test 4: Stockage
echo -e "\n${YELLOW}[4/10] Test stockage...${NC}"
mountpoint -q /mnt/beegfs && ((PASSED++)) || ((FAILED++))

# Test 5: Monitoring
echo -e "\n${YELLOW}[5/10] Test monitoring...${NC}"
curl -s http://localhost:9090/-/healthy && ((PASSED++)) || ((FAILED++))

# Test 6: Applications
echo -e "\n${YELLOW}[6/10] Test applications...${NC}"
module avail gromacs 2>&1 | grep -q gromacs && ((PASSED++)) || ((FAILED++))

# Test 7: Réseau
echo -e "\n${YELLOW}[7/10] Test réseau...${NC}"
ping -c 1 compute-01 && ((PASSED++)) || ((FAILED++))

# Test 8: Sécurité
echo -e "\n${YELLOW}[8/10] Test sécurité...${NC}"
systemctl is-active fail2ban && ((PASSED++)) || ((FAILED++))

# Test 9: Backup
echo -e "\n${YELLOW}[9/10] Test backup...${NC}"
[ -d /backup/cluster-hpc ] && ((PASSED++)) || ((FAILED++))

# Test 10: Performance
echo -e "\n${YELLOW}[10/10] Test performance...${NC}"
sysbench cpu --cpu-max-prime=1000 run > /dev/null 2>&1 && ((PASSED++)) || ((FAILED++))

# Résumé
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}RÉSUMÉ TESTS${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Réussis: $PASSED${NC}"
echo -e "${RED}❌ Échoués: $FAILED${NC}"
echo -e "${YELLOW}📊 Total: $((PASSED + FAILED))${NC}"
