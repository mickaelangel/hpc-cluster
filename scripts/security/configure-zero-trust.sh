#!/bin/bash
# ============================================================================
# Configuration Zero Trust Architecture - Cluster HPC
# Micro-segmentation et Vérification Continue
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION ZERO TRUST${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Micro-segmentation Réseau
echo -e "\n${YELLOW}[1/3] Micro-segmentation Réseau...${NC}"

# Créer répertoire si nécessaire
mkdir -p /etc/nftables

# Créer zones réseau isolées
cat > /etc/nftables/zero-trust.nft <<EOF
# Zero Trust - Micro-segmentation
table inet zero_trust {
    chain frontend {
        type filter hook input priority 0;
        # Autoriser uniquement services nécessaires
        tcp dport { 22, 443 } accept;
        drop;
    }
    
    chain compute {
        type filter hook input priority 0;
        # Communication MPI uniquement
        tcp dport { 1024-65535 } accept;
        drop;
    }
}
EOF

# 2. Vérification Continue
echo -e "\n${YELLOW}[2/3] Configuration Vérification Continue...${NC}"

cat > /usr/local/bin/zero-trust-verify.sh <<'EOF'
#!/bin/bash
# Vérification continue Zero Trust
echo "=== Zero Trust Verification ==="
echo "Date: $(date)"
echo ""

# Vérifier identité
echo "Identité:"
whoami
id

# Vérifier permissions
echo ""
echo "Permissions:"
sudo -l

# Vérifier accès réseau
echo ""
echo "Connexions réseau:"
ss -tuln | head -20
EOF

chmod +x /usr/local/bin/zero-trust-verify.sh

# 3. Monitoring Comportemental
echo -e "\n${YELLOW}[3/3] Configuration Monitoring Comportemental...${NC}"

# Créer règles Falco pour Zero Trust
cat > /etc/falco/rules/zero-trust.yaml <<EOF
- rule: Zero Trust - Accès Non Autorisé
  desc: Détecter accès non autorisé
  condition: >
    evt.type = open and
    not user.name in (authorized_users)
  output: >
    Accès non autorisé détecté
    (user=%user.name file=%fd.name)
  priority: WARNING
EOF

echo -e "\n${GREEN}✅ Zero Trust configuré${NC}"
