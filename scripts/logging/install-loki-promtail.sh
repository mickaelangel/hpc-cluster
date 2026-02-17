#!/bin/bash
# ============================================================================
# Script d'Installation Loki + Promtail - Cluster HPC
# Logging centralisé pour logs Slurm/GPFS/applications
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
LOKI_VERSION="${LOKI_VERSION:-2.9.0}"
PROMTAIL_VERSION="${PROMTAIL_VERSION:-2.9.0}"
LOKI_PORT="${LOKI_PORT:-3100}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION LOKI + PROMTAIL${NC}"
echo -e "${GREEN}Loki: $LOKI_VERSION${NC}"
echo -e "${GREEN}Promtail: $PROMTAIL_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION LOKI
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation Loki...${NC}"

# Créer utilisateur Loki
useradd --no-create-home --shell /bin/false loki || true

# Télécharger Loki
cd /tmp
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
chmod +x loki-linux-amd64
mv loki-linux-amd64 /usr/local/bin/loki

# Configuration Loki
mkdir -p /etc/loki
mkdir -p /var/lib/loki
chown loki:loki /var/lib/loki

cat > /etc/loki/loki-config.yml <<EOF
auth_enabled: false

server:
  http_listen_port: ${LOKI_PORT}
  grpc_listen_port: 9096

common:
  path_prefix: /var/lib/loki
  storage:
    filesystem:
      chunks_directory: /var/lib/loki/chunks
      rules_directory: /var/lib/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093
EOF

# Service systemd Loki
cat > /etc/systemd/system/loki.service <<EOF
[Unit]
Description=Loki
After=network.target

[Service]
User=loki
Group=loki
ExecStart=/usr/local/bin/loki -config.file /etc/loki/loki-config.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable loki
systemctl start loki

echo -e "${GREEN}  ✅ Loki installé${NC}"

# ============================================================================
# 2. INSTALLATION PROMTAIL
# ============================================================================
echo -e "\n${YELLOW}[2/4] Installation Promtail...${NC}"

# Télécharger Promtail
cd /tmp
wget https://github.com/grafana/loki/releases/download/v${PROMTAIL_VERSION}/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
chmod +x promtail-linux-amd64
mv promtail-linux-amd64 /usr/local/bin/promtail

# Configuration Promtail
mkdir -p /etc/promtail

cat > /etc/promtail/promtail-config.yml <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:${LOKI_PORT}/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log

  - job_name: slurm
    static_configs:
      - targets:
          - localhost
        labels:
          job: slurm
          __path__: /var/log/slurm/*.log

  - job_name: gpfs
    static_configs:
      - targets:
          - localhost
        labels:
          job: gpfs
          __path__: /var/mmfs/log/*.log
EOF

# Service systemd Promtail
cat > /etc/systemd/system/promtail.service <<EOF
[Unit]
Description=Promtail
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/promtail -config.file /etc/promtail/promtail-config.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable promtail
systemctl start promtail

echo -e "${GREEN}  ✅ Promtail installé${NC}"

# ============================================================================
# 3. CONFIGURATION GRAFANA
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration Grafana...${NC}"

# Ajouter datasource Loki dans Grafana
mkdir -p /etc/grafana/provisioning/datasources
cat > /etc/grafana/provisioning/datasources/loki.yml <<EOF
apiVersion: 1

datasources:
  - name: Loki
    type: loki
    access: proxy
    url: http://localhost:${LOKI_PORT}
    isDefault: false
    editable: true
EOF

# Redémarrer Grafana si actif
if systemctl is-active grafana-server > /dev/null 2>&1; then
    systemctl restart grafana-server
fi

echo -e "${GREEN}  ✅ Grafana configuré pour Loki${NC}"

# ============================================================================
# 4. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[4/4] Vérification...${NC}"

# Vérifier Loki
if curl -s http://localhost:${LOKI_PORT}/ready > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Loki accessible${NC}"
else
    echo -e "${RED}  ❌ Loki non accessible${NC}"
fi

# Vérifier Promtail
if systemctl is-active promtail > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Promtail actif${NC}"
else
    echo -e "${RED}  ❌ Promtail inactif${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== LOKI + PROMTAIL INSTALLÉS ===${NC}"
echo "Loki: http://localhost:${LOKI_PORT}"
echo "Promtail: Port 9080"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  1. Accéder à Grafana: http://localhost:3000"
echo "  2. Ajouter datasource Loki (déjà configuré)"
echo "  3. Créer des dashboards de logs"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
