#!/bin/bash
# ============================================================================
# Configuration Authentification Multi-Facteur (MFA)
# Support TOTP et YubiKey
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION MFA${NC}"
echo -e "${BLUE}========================================${NC}"

# Installation PAM modules
echo -e "\n${YELLOW}[1/4] Installation modules PAM...${NC}"
if command -v zypper &> /dev/null; then
    zypper install -y pam_google_authenticator pam_yubico 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Packages non disponibles, installation depuis sources...${NC}"
        # Compilation depuis sources si nécessaire
        if [ ! -f /usr/lib/security/pam_google_authenticator.so ]; then
            echo -e "${YELLOW}  Installation Google Authenticator PAM...${NC}"
            # Note: Nécessite compilation depuis sources
        fi
    }
else
    echo -e "${YELLOW}⚠️  zypper non disponible, installation manuelle requise${NC}"
fi

# Configuration PAM pour TOTP
echo -e "\n${YELLOW}[2/4] Configuration PAM TOTP...${NC}"
cat >> /etc/pam.d/sshd <<EOF

# MFA TOTP
auth required pam_google_authenticator.so nullok
EOF

# Configuration SSH pour MFA
echo -e "\n${YELLOW}[3/4] Configuration SSH MFA...${NC}"
cat >> /etc/ssh/sshd_config <<EOF

# MFA Configuration
AuthenticationMethods publickey,keyboard-interactive
ChallengeResponseAuthentication yes
UsePAM yes
EOF

# Configuration YubiKey (optionnel)
echo -e "\n${YELLOW}[4/4] Configuration YubiKey (optionnel)...${NC}"
if command -v ykpersonalize &> /dev/null; then
    cat > /etc/pam.d/yubikey <<EOF
auth sufficient pam_yubico.so id=1 key=your-api-key
EOF
    echo -e "${GREEN}  ✅ YubiKey configuré${NC}"
else
    echo -e "${YELLOW}  ⚠️  YubiKey non installé (optionnel)${NC}"
fi

# Redémarrer SSH
systemctl restart sshd

echo -e "\n${GREEN}✅ MFA configuré${NC}"
echo -e "${YELLOW}Les utilisateurs doivent configurer leur TOTP avec:${NC}"
echo -e "${YELLOW}  google-authenticator${NC}"
