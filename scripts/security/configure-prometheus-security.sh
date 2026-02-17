#!/bin/bash
# ============================================================================
# Configuration Prometheus pour Métriques Sécurité
# Ajoute les scrape configs pour les métriques sécurité
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROMETHEUS_CONFIG="${PROMETHEUS_CONFIG:-/etc/prometheus/prometheus.yml}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION PROMETHEUS SÉCURITÉ${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFIER CONFIGURATION EXISTANTE
# ============================================================================
echo -e "\n${YELLOW}[1/3] Vérification configuration Prometheus...${NC}"

if [ ! -f "$PROMETHEUS_CONFIG" ]; then
    echo -e "${YELLOW}  ⚠️  Fichier Prometheus non trouvé: $PROMETHEUS_CONFIG${NC}"
    echo -e "${YELLOW}  Création configuration de base...${NC}"
    
    mkdir -p "$(dirname "$PROMETHEUS_CONFIG")"
    cat > "$PROMETHEUS_CONFIG" <<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
fi

echo -e "${GREEN}  ✅ Configuration trouvée${NC}"

# ============================================================================
# 2. AJOUTER SCRAPE CONFIGS SÉCURITÉ
# ============================================================================
echo -e "\n${YELLOW}[2/3] Ajout scrape configs sécurité...${NC}"

# Vérifier si node-exporter job existe
if ! grep -q "job_name: 'node-exporter'" "$PROMETHEUS_CONFIG"; then
    cat >> "$PROMETHEUS_CONFIG" <<EOF

  # Node Exporter avec métriques sécurité
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
    file_sd_configs:
      - files:
          - '/var/lib/prometheus/node-exporter/security.prom'
EOF
    echo -e "${GREEN}  ✅ Node Exporter ajouté${NC}"
else
    echo -e "${YELLOW}  ⚠️  Node Exporter déjà configuré${NC}"
fi

# Ajouter alertes sécurité
ALERTS_FILE="$(dirname "$PROMETHEUS_CONFIG")/alerts-security.yml"
if [ ! -f "$ALERTS_FILE" ]; then
    echo -e "${YELLOW}  ⚠️  Fichier alertes sécurité non trouvé${NC}"
    echo -e "${YELLOW}  Créer: $ALERTS_FILE${NC}"
fi

# Ajouter rule_files si pas présent
if ! grep -q "rule_files:" "$PROMETHEUS_CONFIG"; then
    sed -i '/global:/a rule_files:\n  - "alerts-security.yml"' "$PROMETHEUS_CONFIG" || true
fi

echo -e "${GREEN}  ✅ Scrape configs ajoutés${NC}"

# ============================================================================
# 3. VALIDATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Validation configuration...${NC}"

if command -v promtool &> /dev/null; then
    promtool check config "$PROMETHEUS_CONFIG" && {
        echo -e "${GREEN}  ✅ Configuration valide${NC}"
    } || {
        echo -e "${YELLOW}  ⚠️  Configuration nécessite vérification${NC}"
    }
else
    echo -e "${YELLOW}  ⚠️  promtool non disponible pour validation${NC}"
fi

echo -e "\n${GREEN}=== CONFIGURATION TERMINÉE ===${NC}"
echo "Fichier: $PROMETHEUS_CONFIG"
echo "Recharger Prometheus: systemctl reload prometheus"
