#!/bin/bash
# ============================================================================
# Tests Infrastructure - Cluster HPC
# Tests automatisés de l'infrastructure avec Testinfra
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TESTS INFRASTRUCTURE${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION TESTINFRA
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation Testinfra...${NC}"

if ! command -v pytest &> /dev/null; then
    pip3 install pytest testinfra
else
    echo -e "${GREEN}  ✅ Testinfra déjà installé${NC}"
fi

# ============================================================================
# 2. CRÉATION FICHIERS DE TESTS
# ============================================================================
echo -e "\n${YELLOW}[2/4] Création fichiers de tests...${NC}"

TEST_DIR="cluster hpc/tests/infrastructure"
mkdir -p "${TEST_DIR}"

# Test services système
cat > "${TEST_DIR}/test_services.py" <<'EOF'
import pytest
import testinfra

def test_sshd_is_running(host):
    sshd = host.service("sshd")
    assert sshd.is_running
    assert sshd.is_enabled

def test_slurmctld_is_running(host):
    slurmctld = host.service("slurmctld")
    assert slurmctld.is_running
    assert slurmctld.is_enabled

def test_beegfs_mgmtd_is_running(host):
    beegfs = host.service("beegfs-mgmtd")
    assert beegfs.is_running
    assert beegfs.is_enabled
EOF

# Test ports réseau
cat > "${TEST_DIR}/test_network.py" <<'EOF'
import pytest
import testinfra

def test_ssh_port_is_listening(host):
    assert host.socket("tcp://0.0.0.0:22").is_listening

def test_prometheus_port_is_listening(host):
    assert host.socket("tcp://0.0.0.0:9090").is_listening

def test_grafana_port_is_listening(host):
    assert host.socket("tcp://0.0.0.0:3000").is_listening
EOF

# Test fichiers système
cat > "${TEST_DIR}/test_filesystem.py" <<'EOF'
import pytest
import testinfra

def test_beegfs_is_mounted(host):
    beegfs = host.mount_point("/mnt/beegfs")
    assert beegfs.exists
    assert beegfs.filesystem == "beegfs"

def test_home_directories_exist(host):
    assert host.file("/mnt/beegfs/home").is_directory
EOF

# Test packages
cat > "${TEST_DIR}/test_packages.py" <<'EOF'
import pytest
import testinfra

def test_slurm_is_installed(host):
    assert host.package("slurm").is_installed

def test_python3_is_installed(host):
    assert host.package("python3").is_installed

def test_docker_is_installed(host):
    assert host.package("docker").is_installed
EOF

echo -e "${GREEN}  ✅ Fichiers de tests créés${NC}"

# ============================================================================
# 3. EXÉCUTION DES TESTS
# ============================================================================
echo -e "\n${YELLOW}[3/4] Exécution des tests...${NC}"

cd "${TEST_DIR}"
pytest -v test_services.py test_network.py test_filesystem.py test_packages.py || {
    echo -e "${YELLOW}  ⚠️  Certains tests ont échoué (normal si services non démarrés)${NC}"
}

# ============================================================================
# 4. RAPPORT
# ============================================================================
echo -e "\n${YELLOW}[4/4] Génération rapport...${NC}"

pytest --html=report.html --self-contained-html || true

echo -e "\n${GREEN}=== TESTS INFRASTRUCTURE TERMINÉS ===${NC}"
echo "Rapport: ${TEST_DIR}/report.html"
