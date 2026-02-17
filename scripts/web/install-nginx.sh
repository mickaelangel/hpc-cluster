#!/bin/bash
# ============================================================================
# Installation Nginx - Reverse Proxy et Serveur Web
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NGINX${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Nginx...${NC}"

zypper install -y nginx || {
    echo -e "${RED}Erreur: Installation Nginx échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Nginx installé${NC}"

# ============================================================================
# 2. CONFIGURATION REVERSE PROXY
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration reverse proxy...${NC}"

# Configuration reverse proxy pour services cluster
cat > /etc/nginx/conf.d/cluster-hpc.conf <<'EOF'
# Reverse Proxy pour Cluster HPC

upstream grafana {
    server localhost:3000;
}

upstream prometheus {
    server localhost:9090;
}

upstream jaeger {
    server localhost:16686;
}

upstream kibana {
    server localhost:5601;
}

upstream kong {
    server localhost:8001;
}

server {
    listen 80;
    server_name cluster.local;

    # Grafana
    location /grafana/ {
        proxy_pass http://grafana/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Prometheus
    location /prometheus/ {
        proxy_pass http://prometheus/;
        proxy_set_header Host $host;
    }

    # Jaeger
    location /jaeger/ {
        proxy_pass http://jaeger/;
        proxy_set_header Host $host;
    }

    # Kibana
    location /kibana/ {
        proxy_pass http://kibana/;
        proxy_set_header Host $host;
    }

    # Kong Admin
    location /kong/ {
        proxy_pass http://kong/;
        proxy_set_header Host $host;
    }
}
EOF

echo -e "${GREEN}  ✅ Configuration créée${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage Nginx...${NC}"

# Test configuration
nginx -t && {
    systemctl enable nginx
    systemctl start nginx
    echo -e "${GREEN}  ✅ Nginx démarré${NC}"
} || {
    echo -e "${RED}  ❌ Erreur configuration Nginx${NC}"
    exit 1
}

echo -e "\n${GREEN}=== NGINX INSTALLÉ ===${NC}"
echo "URL: http://cluster.local/grafana"
echo "Configuration: /etc/nginx/conf.d/cluster-hpc.conf"
