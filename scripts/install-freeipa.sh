#!/bin/bash
# ============================================================================
# Script d'Installation FreeIPA - Cluster HPC
# Compatible SUSE 15 SP7 / CentOS 8+ / RHEL 8+
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REALM=${REALM:-CLUSTER.LOCAL}
DOMAIN=${DOMAIN:-cluster.local}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-AdminPassword123!}
DS_PASSWORD=${DS_PASSWORD:-DSPassword123!}
IPA_SERVER=${IPA_SERVER:-ipa.cluster.local}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION FREEIPA${NC}"
echo -e "${GREEN}Realm: ${REALM}${NC}"
echo -e "${GREEN}Domain: ${DOMAIN}${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFICATION PRÉREQUIS
# ============================================================================
echo -e "\n${YELLOW}[1/7] Vérification des prérequis...${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Erreur: Ce script doit être exécuté en tant que root${NC}"
    exit 1
fi

# Vérifier le nom d'hôte
if [ -z "$(hostname -f)" ]; then
    echo -e "${RED}Erreur: Le nom d'hôte FQDN doit être configuré${NC}"
    exit 1
fi

# ============================================================================
# 2. INSTALLATION DES DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[2/7] Installation des dépendances...${NC}"

# Détection de la distribution
if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS_ID=${ID:-}
    OS_VERSION=${VERSION_ID:-}
fi

# SUSE / openSUSE : Docker recommandé (FreeIPA natif compliqué sur Leap)
if [ "$OS_ID" = "opensuse-leap" ] || [ "$OS_ID" = "sles" ]; then
    echo -e "${YELLOW}Installation FreeIPA via Docker (recommandé sur openSUSE/SUSE)${NC}"
    USE_DOCKER=true
# CentOS/RHEL
elif [ "$OS_ID" = "centos" ] || [ "$OS_ID" = "rhel" ]; then
    yum install -y freeipa-server freeipa-server-dns freeipa-client
    USE_DOCKER=false
else
    echo -e "${YELLOW}Distribution non supportée pour installation native${NC}"
    echo -e "${YELLOW}Utilisation de Docker (recommandé)${NC}"
    USE_DOCKER=true
fi

# ============================================================================
# 3. INSTALLATION VIA DOCKER (Recommandé)
# ============================================================================
if [ "${USE_DOCKER:-true}" = "true" ]; then
    echo -e "\n${YELLOW}[3/7] Installation FreeIPA via Docker...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Erreur: Docker n'est pas installé${NC}"
        exit 1
    fi
    
    # Réinstallation propre si demandé (démo / dépannage)
    if [ "${FORCE_REINSTALL:-0}" = "1" ]; then
        echo -e "${YELLOW}Réinstallation propre (FORCE_REINSTALL=1)...${NC}"
        docker rm -f freeipa-server 2>/dev/null || true
        rm -rf /var/lib/ipa-data
    fi
    
    systemctl stop dirsrv@cluster 2>/dev/null || true
    systemctl stop krb5kdc kadmin 2>/dev/null || true

    # Démarrer si le conteneur existe déjà et tourne, sinon créer ou redémarrer
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx freeipa-server; then
        echo -e "${YELLOW}Conteneur FreeIPA déjà en cours d'exécution.${NC}"
    elif docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx freeipa-server; then
        echo -e "${YELLOW}Conteneur FreeIPA existant (arrêté), démarrage...${NC}"
        docker start freeipa-server
    else
        echo -e "${YELLOW}Création du conteneur FreeIPA (installation ~5–10 min au premier démarrage)...${NC}"
        # Désactiver IPv6 dans le conteneur pour éviter l'échec ipa-server-install (::1 manquant)
        # --cgroupns=host pour compatibilité cgroups v2 (systemd dans le conteneur)
        docker run -d --name freeipa-server \
            -h ${IPA_SERVER} \
            -e IPA_SERVER_HOSTNAME=${IPA_SERVER} \
            -e IPA_SERVER_INSTALL_OPTS="--realm=${REALM} --domain=${DOMAIN} --ds-password=${DS_PASSWORD} --admin-password=${ADMIN_PASSWORD} --setup-dns --forwarder=8.8.8.8 --unattended --no-ntp" \
            --sysctl net.ipv6.conf.all.disable_ipv6=1 \
            --sysctl net.ipv6.conf.lo.disable_ipv6=1 \
            --cgroupns=host \
            -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
            --tmpfs /run --tmpfs /tmp \
            -v /var/lib/ipa-data:/data:Z \
            -p 80:80 -p 443:443 \
            -p 389:389 -p 636:636 \
            -p 88:88 -p 464:464 \
            -p 53:53/udp -p 53:53 \
            --restart unless-stopped \
            freeipa/freeipa-server:rocky-8
    fi
    
    # Résolution locale pour l'interface web
    if ! grep -q "ipa.cluster.local" /etc/hosts 2>/dev/null; then
        echo "127.0.0.1 ipa.cluster.local" >> /etc/hosts
    fi

    echo -e "${GREEN}FreeIPA déployé via Docker${NC}"
    echo -e "${YELLOW}Premier démarrage: l'installation IPA dure 5–10 min. Suivi: docker logs -f freeipa-server${NC}"
    echo -e "${GREEN}Une fois prêt: https://${IPA_SERVER} ou https://localhost (admin / ${ADMIN_PASSWORD})${NC}"
    
    exit 0
fi

# ============================================================================
# 4. INSTALLATION NATIVE (Si Docker non utilisé)
# ============================================================================
echo -e "\n${YELLOW}[4/7] Installation FreeIPA native...${NC}"

ipa-server-install \
    --realm=${REALM} \
    --domain=${DOMAIN} \
    --ds-password="${DS_PASSWORD}" \
    --admin-password="${ADMIN_PASSWORD}" \
    --setup-dns \
    --forwarder=8.8.8.8 \
    --no-ntp \
    --unattended || {
    echo -e "${RED}Erreur lors de l'installation${NC}"
    exit 1
}

# ============================================================================
# 5. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[5/7] Vérification de l'installation...${NC}"

# Attendre que le service soit prêt
sleep 10

# Test de connectivité
ipa ping || {
    echo -e "${YELLOW}FreeIPA n'est pas encore prêt, attente...${NC}"
    sleep 20
    ipa ping || {
        echo -e "${RED}Erreur: FreeIPA non accessible${NC}"
        exit 1
    }
}

# ============================================================================
# 6. CONFIGURATION INITIALE
# ============================================================================
echo -e "\n${YELLOW}[6/7] Configuration initiale...${NC}"

# Obtenir un ticket admin
echo "${ADMIN_PASSWORD}" | kinit admin@${REALM} || {
    echo -e "${YELLOW}Impossible d'obtenir un ticket, continuer...${NC}"
}

# Créer un groupe HPC par défaut
ipa group-add hpc-users --desc="HPC Users Group" || {
    echo -e "${YELLOW}Groupe hpc-users existe déjà${NC}"
}

# ============================================================================
# 7. RÉSUMÉ
# ============================================================================
echo -e "\n${YELLOW}[7/7] Résumé de l'installation...${NC}"

echo -e "\n${GREEN}=== FREEIPA INSTALLÉ AVEC SUCCÈS ===${NC}"
echo "Realm: ${REALM}"
echo "Domain: ${DOMAIN}"
echo "Server: ${IPA_SERVER}"
echo "Web UI: https://${IPA_SERVER}"
echo "Login: admin"
echo "Password: ${ADMIN_PASSWORD}"
echo ""
echo "Commandes utiles:"
echo "  ipa ping              # Test de connectivité"
echo "  ipa user-find         # Lister les utilisateurs"
echo "  ipa group-find        # Lister les groupes"
echo "  kinit admin@${REALM}  # Obtenir un ticket"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
