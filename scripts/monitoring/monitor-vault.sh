#!/bin/bash
# ============================================================================
# Monitoring Vault
# ============================================================================

set -euo pipefail

echo "Monitoring Vault..."

if curl -s http://localhost:8200/v1/sys/health &> /dev/null; then
    # Métriques Vault
    HEALTH=$(curl -s http://localhost:8200/v1/sys/health | jq -r '.initialized' || echo "false")
    
    cat > /var/lib/prometheus/node-exporter/vault.prom <<EOF
# TYPE vault_initialized gauge
vault_initialized{status="$HEALTH"} 1
EOF
    
    echo "✅ Monitoring Vault configuré"
else
    echo "⚠️  Vault non disponible"
fi
