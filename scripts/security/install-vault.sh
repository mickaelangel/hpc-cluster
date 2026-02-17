#!/bin/bash
# ============================================================================
# Installation HashiCorp Vault - Gestion Secrets
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION VAULT${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VAULT
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation Vault...${NC}"

VAULT_VERSION="1.15.0"
VAULT_ZIP="vault_${VAULT_VERSION}_linux_amd64.zip"
VAULT_DIR="/usr/local/bin"

cd /tmp
if [ ! -f "$VAULT_ZIP" ]; then
    wget -q "https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
        exit 1
    }
fi

unzip -q "$VAULT_ZIP"
mv vault "$VAULT_DIR/"
chmod +x "$VAULT_DIR/vault"

echo -e "${GREEN}  ✅ Vault installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/4] Configuration Vault...${NC}"

# Créer utilisateur vault
useradd --system --home /etc/vault.d --shell /bin/false vault

# Créer répertoires
mkdir -p /etc/vault.d
mkdir -p /var/lib/vault/data
chown -R vault:vault /var/lib/vault

# Configuration Vault
cat > /etc/vault.d/vault.hcl <<EOF
ui = true

storage "file" {
  path = "/var/lib/vault/data"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
EOF

chown vault:vault /etc/vault.d/vault.hcl

# Service systemd
cat > /etc/systemd/system/vault.service <<EOF
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30s
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}  ✅ Vault configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/4] Démarrage Vault...${NC}"

systemctl daemon-reload
systemctl enable vault
systemctl start vault

sleep 3

echo -e "${GREEN}  ✅ Vault démarré${NC}"

# ============================================================================
# 4. INITIALISATION
# ============================================================================
echo -e "\n${YELLOW}[4/4] Initialisation Vault...${NC}"

# Initialiser Vault (si pas déjà fait)
if ! vault status &> /dev/null; then
    echo -e "${YELLOW}  ⚠️  Initialisation manuelle requise:${NC}"
    echo -e "${YELLOW}  vault operator init${NC}"
    echo -e "${YELLOW}  vault operator unseal <key>${NC}"
else
    echo -e "${GREEN}  ✅ Vault initialisé${NC}"
fi

echo -e "\n${GREEN}=== VAULT INSTALLÉ ===${NC}"
echo "URL: http://localhost:8200"
echo "CLI: vault"
echo "Documentation: https://www.vaultproject.io/docs/"
