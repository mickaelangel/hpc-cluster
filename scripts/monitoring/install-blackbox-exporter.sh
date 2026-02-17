#!/bin/bash
# ============================================================================
# Installation Blackbox Exporter - Blackbox Monitoring
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION BLACKBOX EXPORTER${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger Blackbox Exporter
cd /opt
wget -q https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.linux-amd64.tar.gz
tar -xzf blackbox_exporter-0.24.0.linux-amd64.tar.gz
mv blackbox_exporter-0.24.0.linux-amd64 blackbox_exporter
ln -s /opt/blackbox_exporter/blackbox_exporter /usr/local/bin/

# Service systemd
cat > /etc/systemd/system/blackbox-exporter.service <<EOF
[Unit]
Description=Blackbox Exporter
After=network.target

[Service]
Type=simple
ExecStart=/opt/blackbox_exporter/blackbox_exporter --config.file=/opt/blackbox_exporter/blackbox.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable blackbox-exporter
systemctl start blackbox-exporter

echo -e "${GREEN}✅ Blackbox Exporter installé${NC}"
echo "Port: 9115"
