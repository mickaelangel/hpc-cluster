#!/bin/bash
# ============================================================================
# Installation SNMP Exporter - SNMP Monitoring
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SNMP EXPORTER${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger SNMP Exporter
cd /opt
wget -q https://github.com/prometheus/snmp_exporter/releases/download/v0.24.0/snmp_exporter-0.24.0.linux-amd64.tar.gz
tar -xzf snmp_exporter-0.24.0.linux-amd64.tar.gz
mv snmp_exporter-0.24.0.linux-amd64 snmp_exporter
ln -s /opt/snmp_exporter/snmp_exporter /usr/local/bin/

# Service systemd
cat > /etc/systemd/system/snmp-exporter.service <<EOF
[Unit]
Description=SNMP Exporter
After=network.target

[Service]
Type=simple
ExecStart=/opt/snmp_exporter/snmp_exporter --config.file=/opt/snmp_exporter/snmp.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable snmp-exporter
systemctl start snmp-exporter

echo -e "${GREEN}✅ SNMP Exporter installé${NC}"
echo "Port: 9116"
