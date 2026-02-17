#!/bin/bash
# ============================================================================
# Configuration GPG - Chiffrement Fichiers Sensibles
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION GPG${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation GPG...${NC}"

zypper install -y gpg2 || {
    echo -e "${RED}Erreur: Installation GPG échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ GPG installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration GPG...${NC}"

# Script helper pour chiffrer/déchiffrer
cat > /usr/local/bin/gpg-encrypt.sh <<'EOF'
#!/bin/bash
# Chiffrer un fichier avec GPG
FILE=$1
RECIPIENT=$2

if [ -z "$FILE" ] || [ -z "$RECIPIENT" ]; then
    echo "Usage: gpg-encrypt.sh file recipient@email.com"
    exit 1
fi

gpg --encrypt --recipient "$RECIPIENT" "$FILE"
echo "Fichier chiffré: ${FILE}.gpg"
EOF

cat > /usr/local/bin/gpg-decrypt.sh <<'EOF'
#!/bin/bash
# Déchiffrer un fichier avec GPG
FILE=$1

if [ -z "$FILE" ]; then
    echo "Usage: gpg-decrypt.sh file.gpg"
    exit 1
fi

gpg --decrypt "$FILE"
EOF

chmod +x /usr/local/bin/gpg-encrypt.sh
chmod +x /usr/local/bin/gpg-decrypt.sh

echo -e "${GREEN}  ✅ GPG configuré${NC}"

# ============================================================================
# 3. DOCUMENTATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Documentation...${NC}"

cat > /usr/local/share/doc/gpg-usage.txt <<'EOF'
# Utilisation GPG

## Générer une clé
gpg --gen-key

## Chiffrer un fichier
gpg-encrypt.sh fichier.txt recipient@email.com

## Déchiffrer un fichier
gpg-decrypt.sh fichier.txt.gpg
EOF

echo -e "${GREEN}  ✅ Documentation créée${NC}"

echo -e "\n${GREEN}=== GPG CONFIGURÉ ===${NC}"
echo "Scripts: /usr/local/bin/gpg-encrypt.sh, /usr/local/bin/gpg-decrypt.sh"
echo "Documentation: /usr/local/share/doc/gpg-usage.txt"
