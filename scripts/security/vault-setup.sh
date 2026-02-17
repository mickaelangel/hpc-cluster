#!/bin/bash
# ============================================================================
# HashiCorp Vault Setup - Secrets Management
# Usage: sudo bash scripts/security/vault-setup.sh
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HASHICORP VAULT SETUP${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Installation Vault
if ! command -v vault &> /dev/null; then
    echo -e "${YELLOW}[1/4] Installation de Vault...${NC}"
    
    # Télécharger Vault
    VAULT_VERSION="1.15.0"
    wget -q "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
    unzip -q vault_${VAULT_VERSION}_linux_amd64.zip
    sudo mv vault /usr/local/bin/
    rm vault_${VAULT_VERSION}_linux_amd64.zip
    
    echo -e "${GREEN}✅ Vault installé${NC}"
else
    echo -e "${GREEN}✅ Vault déjà installé${NC}"
fi

# Configuration Vault
echo -e "${YELLOW}[2/4] Configuration de Vault...${NC}"

sudo mkdir -p /etc/vault.d
sudo mkdir -p /var/lib/vault

cat > /tmp/vault.hcl <<EOF
ui = true
disable_mlock = true

storage "file" {
  path = "/var/lib/vault"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"
EOF

sudo mv /tmp/vault.hcl /etc/vault.d/vault.hcl
sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl

echo -e "${GREEN}✅ Configuration créée${NC}"

# Service systemd
echo -e "${YELLOW}[3/4] Création du service systemd...${NC}"

cat > /tmp/vault.service <<EOF
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
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/vault.service /etc/systemd/system/vault.service
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

echo -e "${GREEN}✅ Service créé et démarré${NC}"

# Initialisation
echo -e "${YELLOW}[4/4] Initialisation de Vault...${NC}"
sleep 5

export VAULT_ADDR='http://127.0.0.1:8200'

# Initialiser Vault (première fois seulement)
if ! vault status &> /dev/null; then
    echo -e "${YELLOW}Initialisation de Vault (première fois)...${NC}"
    vault operator init -key-shares=5 -key-threshold=3 > /tmp/vault-init.txt
    
    echo -e "${YELLOW}⚠️  IMPORTANT: Sauvegarder les clés de déverrouillage et le token root${NC}"
    echo -e "${YELLOW}Fichier: /tmp/vault-init.txt${NC}"
else
    echo -e "${GREEN}✅ Vault déjà initialisé${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VAULT CONFIGURÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "1. Déverrouiller Vault: vault operator unseal"
echo "2. Se connecter: vault auth"
echo "3. Créer des secrets: vault kv put secret/hpc-cluster key=value"
echo ""
