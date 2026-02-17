#!/bin/bash
# ============================================================================
# Script d'Installation HAProxy - Cluster HPC
# Load Balancing et SSL/TLS Termination
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
HAProxy_PORT_HTTP="${HAPROXY_PORT_HTTP:-80}"
HAProxy_PORT_HTTPS="${HAPROXY_PORT_HTTPS:-443}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION HAPROXY${NC}"
echo -e "${GREEN}Ports: HTTP $HAProxy_PORT_HTTP, HTTPS $HAProxy_PORT_HTTPS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION HAPROXY
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation HAProxy...${NC}"

zypper install -y haproxy openssl || {
    echo -e "${RED}Erreur: Installation HAProxy échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ HAProxy installé${NC}"

# ============================================================================
# 2. CONFIGURATION HAPROXY
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration HAProxy...${NC}"

# Backup configuration
if [ -f /etc/haproxy/haproxy.cfg ]; then
    cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.backup.$(date +%Y%m%d)
fi

# Configuration HAProxy
cat > /etc/haproxy/haproxy.cfg <<'EOF'
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 4096

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

# Frontend HTTP
frontend http_frontend
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }

# Frontend HTTPS
frontend https_frontend
    bind *:443 ssl crt /etc/haproxy/certs/cluster.pem
    mode http
    
    # JupyterHub
    acl is_jupyter path_beg /jupyter
    use_backend jupyter_backend if is_jupyter
    
    # Exceed TurboX
    acl is_etx path_beg /etx
    use_backend etx_backend if is_etx
    
    # Grafana
    acl is_grafana path_beg /grafana
    use_backend grafana_backend if is_grafana
    
    # Default
    default_backend jupyter_backend

# Backend JupyterHub
backend jupyter_backend
    balance roundrobin
    option httpchk GET /hub/health
    server jupyter1 frontal-01:8000 check
    server jupyter2 frontal-02:8000 check backup

# Backend Exceed TurboX
backend etx_backend
    balance roundrobin
    server etx1 frontal-01:9443 check ssl verify none

# Backend Grafana
backend grafana_backend
    balance roundrobin
    server grafana1 frontal-01:3000 check

# Stats
listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
EOF

# Créer répertoires nécessaires
mkdir -p /etc/haproxy/errors
mkdir -p /etc/haproxy/certs
mkdir -p /var/lib/haproxy

# Créer certificat auto-signé (à remplacer en production)
if [ ! -f /etc/haproxy/certs/cluster.pem ]; then
    openssl req -x509 -newkey rsa:4096 -keyout /etc/haproxy/certs/cluster.key \
        -out /etc/haproxy/certs/cluster.crt -days 365 -nodes \
        -subj "/CN=cluster.local/O=HPC Cluster"
    cat /etc/haproxy/certs/cluster.crt /etc/haproxy/certs/cluster.key > /etc/haproxy/certs/cluster.pem
    chmod 600 /etc/haproxy/certs/cluster.pem
fi

echo -e "${GREEN}  ✅ HAProxy configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE SERVICE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage service...${NC}"

# Test configuration
haproxy -f /etc/haproxy/haproxy.cfg -c || {
    echo -e "${RED}Erreur: Configuration HAProxy invalide${NC}"
    exit 1
}

systemctl enable haproxy
systemctl restart haproxy

echo -e "${GREEN}  ✅ HAProxy démarré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== HAPROXY INSTALLÉ ===${NC}"
echo "HTTP: Port $HAProxy_PORT_HTTP (redirige vers HTTPS)"
echo "HTTPS: Port $HAProxy_PORT_HTTPS"
echo "Stats: http://$(hostname):8404/stats"
echo ""
echo -e "${YELLOW}SERVICES PROXYFIÉS:${NC}"
echo "  - JupyterHub: /jupyter"
echo "  - Exceed TurboX: /etx"
echo "  - Grafana: /grafana"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
