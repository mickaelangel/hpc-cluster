#!/bin/bash
# ============================================================================
# Script de Vérification Santé - Cluster HPC
# Tests complets de tous les services
# Compatible SUSE 15 SP7
# ============================================================================

set -uo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compteurs
PASSED=0
FAILED=0
WARNINGS=0

# Docker (pour tests FreeIPA / Prometheus / Grafana) - chemin absolu pour sudo
DOCKER_CMD="$(command -v docker 2>/dev/null || echo /usr/bin/docker)"
[ -z "$DOCKER_CMD" ] && DOCKER_CMD="docker"
DOCKER_PS=""
[ -n "$DOCKER_CMD" ] && DOCKER_PS=$($DOCKER_CMD ps -a 2>/dev/null) || true

# Fonction de test
test_item() {
    local name="$1"
    local command="$2"
    local expected="${3:-}"
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ ${name}${NC}"
        ((PASSED++))
        return 0
    else
        if [ -n "$expected" ]; then
            echo -e "${RED}  ❌ ${name}${NC}"
            ((FAILED++))
            return 1
        else
            echo -e "${YELLOW}  ⚠️  ${name} (optionnel)${NC}"
            ((WARNINGS++))
            return 2
        fi
    fi
}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VÉRIFICATION SANTÉ CLUSTER HPC${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFICATION SERVICES SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/8] Services système...${NC}"

test_item "SSH actif" "systemctl is-active sshd 2>/dev/null || systemctl is-active ssh 2>/dev/null"
test_item "NetworkManager actif" "systemctl is-active NetworkManager"
test_item "Chronyd actif" "systemctl is-active chronyd"

# ============================================================================
# 2. VÉRIFICATION IDENTITY (FreeIPA ou LDAP)
# ============================================================================
echo -e "\n${YELLOW}[2/8] Identity (FreeIPA ou LDAP)...${NC}"
# Rafraîchir liste Docker (détection sous sudo)
[ -n "$DOCKER_CMD" ] && DOCKER_PS=$($DOCKER_CMD ps -a 2>/dev/null) || true
FREEIPA_DOCKER=false
echo "$DOCKER_PS" | grep -q freeipa-server && FREEIPA_DOCKER=true
# Détection par port si Docker liste vide (ex. sudo sans socket)
LDAP_PORT_OPEN=false
nc -z localhost 389 2>/dev/null || timeout 1 bash -c 'echo >/dev/tcp/localhost/389' 2>/dev/null && LDAP_PORT_OPEN=true

if command -v ipa &>/dev/null && ipa ping &>/dev/null; then
    test_item "FreeIPA actif" "ipa ping" "optional"
    test_item "LDAP (FreeIPA) accessible" "ldapsearch -x -H ldap://localhost -b 'dc=cluster,dc=local' -s base 2>/dev/null || ldapsearch -x -H ldap://localhost -s base 2>/dev/null" "optional"
elif [ "$FREEIPA_DOCKER" = "true" ]; then
    test_item "FreeIPA (conteneur) présent" "echo \"\$($DOCKER_CMD ps -a 2>/dev/null)\" | grep -q freeipa-server" "optional"
    test_item "LDAP (FreeIPA) port 389" "nc -z localhost 389 2>/dev/null || timeout 1 bash -c 'echo >/dev/tcp/localhost/389' 2>/dev/null"
elif systemctl list-unit-files 2>/dev/null | grep -q dirsrv@cluster; then
    test_item "Service LDAP actif" "systemctl is-active dirsrv@cluster" "optional"
    test_item "LDAP accessible" "ldapsearch -x -b 'dc=cluster,dc=local' -s base" "optional"
elif [ "$LDAP_PORT_OPEN" = "true" ]; then
    test_item "LDAP (port 389) accessible" "nc -z localhost 389 2>/dev/null || timeout 1 bash -c 'echo >/dev/tcp/localhost/389' 2>/dev/null" "optional"
else
    echo -e "${YELLOW}  ⚠️  FreeIPA/LDAP non installé${NC}"
    ((WARNINGS++))
fi

# ============================================================================
# 3. VÉRIFICATION KERBEROS (ou inclus dans FreeIPA)
# ============================================================================
echo -e "\n${YELLOW}[3/8] Kerberos...${NC}"

if command -v ipa &>/dev/null && ipa ping &>/dev/null; then
    test_item "Kerberos (FreeIPA) disponible" "ipa ping" "optional"
elif [ "$FREEIPA_DOCKER" = "true" ] || nc -z localhost 88 2>/dev/null || timeout 1 bash -c 'echo >/dev/tcp/localhost/88' 2>/dev/null; then
    test_item "Kerberos (FreeIPA) port 88" "nc -z localhost 88 2>/dev/null || timeout 1 bash -c 'echo >/dev/tcp/localhost/88' 2>/dev/null"
elif systemctl list-unit-files 2>/dev/null | grep -q krb5kdc; then
    test_item "KDC actif" "systemctl is-active krb5kdc" "optional"
    test_item "Kadmin actif" "systemctl is-active kadmin" "optional"
    test_item "Configuration Kerberos" "[ -f /etc/krb5.conf ]" "optional"
else
    echo -e "${YELLOW}  ⚠️  Kerberos non installé${NC}"
    ((WARNINGS++))
fi

# ============================================================================
# 4. VÉRIFICATION SLURM
# ============================================================================
echo -e "\n${YELLOW}[4/8] Slurm...${NC}"

if command -v scontrol > /dev/null 2>&1; then
    test_item "SlurmCTLD actif" "systemctl is-active slurmctld"
    test_item "Slurm accessible" "scontrol ping"
    test_item "Configuration Slurm" "[ -f /etc/slurm/slurm.conf ]"
    test_item "Munge actif" "systemctl is-active munge"
else
    echo -e "${YELLOW}  ⚠️  Slurm non installé${NC}"
    ((WARNINGS++))
fi

# ============================================================================
# 5. VÉRIFICATION FS DISTRIBUÉ (GlusterFS / Lustre / GPFS)
# ============================================================================
echo -e "\n${YELLOW}[5/8] FS distribué (GlusterFS/Lustre/GPFS)...${NC}"

if command -v gluster > /dev/null 2>&1 && systemctl is-active glusterd &>/dev/null; then
    test_item "GlusterFS (glusterd) actif" "systemctl is-active glusterd"
    test_item "GlusterFS volume(s)" "gluster volume status 2>/dev/null | grep -q Status || gluster volume list 2>/dev/null | grep -q ."
elif command -v lfs > /dev/null 2>&1; then
    test_item "Lustre client disponible" "command -v lfs" "optional"
elif command -v mmgetstate > /dev/null 2>&1; then
    test_item "GPFS actif" "mmgetstate -a" "optional"
else
    echo -e "${YELLOW}  ⚠️  Aucun FS distribué (GlusterFS/Lustre/GPFS) installé${NC}"
    ((WARNINGS++))
fi

# ============================================================================
# 6. VÉRIFICATION MONITORING
# ============================================================================
echo -e "\n${YELLOW}[6/8] Monitoring...${NC}"
# Rafraîchir la liste des conteneurs pour détecter Prometheus/Grafana (Docker)
[ -n "$DOCKER_CMD" ] && DOCKER_PS=$($DOCKER_CMD ps -a 2>/dev/null) || true

if command -v prometheus > /dev/null 2>&1 || echo "$DOCKER_PS" | grep -qi prometheus || [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:9090/-/healthy 2>/dev/null)" = "200" ]; then
    test_item "Prometheus accessible" "curl -s http://localhost:9090/-/healthy" "optional"
else
    echo -e "${YELLOW}  ⚠️  Prometheus non installé${NC}"
    ((WARNINGS++))
fi

if command -v grafana-server > /dev/null 2>&1 || echo "$DOCKER_PS" | grep -qi grafana || [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/api/health 2>/dev/null)" = "200" ]; then
    test_item "Grafana accessible" "curl -s http://localhost:3000/api/health"
else
    echo -e "${YELLOW}  ⚠️  Grafana non installé${NC}"
    ((WARNINGS++))
fi

# ============================================================================
# 7. VÉRIFICATION RÉSEAU
# ============================================================================
echo -e "\n${YELLOW}[7/8] Réseau...${NC}"

test_item "Interface réseau principale" "ip -4 addr show 2>/dev/null | grep -q inet"
test_item "Résolution DNS" "getent hosts localhost"
test_item "Connexion sortante" "ping -c 1 8.8.8.8" "optional"

# ============================================================================
# 8. VÉRIFICATION DISQUE
# ============================================================================
echo -e "\n${YELLOW}[8/8] Disque...${NC}"

DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${GREEN}  ✅ Espace disque suffisant (${DISK_USAGE}% utilisé)${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Espace disque faible (${DISK_USAGE}% utilisé)${NC}"
    ((FAILED++))
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}RÉSUMÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tests réussis: ${PASSED}${NC}"
echo -e "${RED}Tests échoués: ${FAILED}${NC}"
echo -e "${YELLOW}Avertissements: ${WARNINGS}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ Cluster en bonne santé!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Des problèmes ont été détectés${NC}"
    exit 1
fi
