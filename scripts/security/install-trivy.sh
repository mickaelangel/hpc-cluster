#!/bin/bash
# ============================================================================
# Installation Trivy - Scan Vulnérabilités Images Docker
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TRIVY${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Trivy...${NC}"

# Télécharger Trivy
TRIVY_VERSION="0.48.0"
TRIVY_TAR="trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
TRIVY_DIR="/usr/local/bin"

cd /tmp
if [ ! -f "$TRIVY_TAR" ]; then
    wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/${TRIVY_TAR}" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
        exit 1
    }
fi

tar -xzf "$TRIVY_TAR"
mv trivy "$TRIVY_DIR/"
chmod +x "$TRIVY_DIR/trivy"

echo -e "${GREEN}  ✅ Trivy installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Trivy...${NC}"

# Mettre à jour base de données vulnérabilités
trivy image --download-db-only || {
    echo -e "${YELLOW}  ⚠️  Mise à jour base de données échouée${NC}"
}

# Configuration Trivy
mkdir -p /etc/trivy
cat > /etc/trivy/trivy.yaml <<EOF
# Configuration Trivy

format: json
exit-code: 1
severity: CRITICAL,HIGH
ignorefile: .trivyignore
cache-dir: /var/cache/trivy
EOF

echo -e "${GREEN}  ✅ Trivy configuré${NC}"

# ============================================================================
# 3. SCRIPT SCAN AUTOMATIQUE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Création script scan automatique...${NC}"

# Script scan images
cat > /usr/local/bin/trivy-scan-images.sh <<'EOF'
#!/bin/bash
# Scan automatique toutes les images Docker

REPORT_DIR="/var/log/trivy-scans"
mkdir -p "$REPORT_DIR"

echo "Scanning Docker images..."

for image in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>"); do
    echo "Scanning: $image"
    trivy image --format json --output "$REPORT_DIR/$(echo $image | tr '/:' '_').json" "$image" || true
    trivy image --format table "$image" || true
done

echo "Scans completed. Reports in: $REPORT_DIR"
EOF

chmod +x /usr/local/bin/trivy-scan-images.sh

# Cron job pour scan quotidien
cat > /etc/cron.daily/trivy-scan <<'EOF'
#!/bin/bash
/usr/local/bin/trivy-scan-images.sh
EOF

chmod +x /etc/cron.daily/trivy-scan

echo -e "${GREEN}  ✅ Script scan créé${NC}"

echo -e "\n${GREEN}=== TRIVY INSTALLÉ ===${NC}"
echo "Scan image: trivy image <image-name>"
echo "Scan automatique: /usr/local/bin/trivy-scan-images.sh"
echo "Rapports: /var/log/trivy-scans/"
