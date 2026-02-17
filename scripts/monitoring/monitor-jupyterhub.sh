#!/bin/bash
# ============================================================================
# Monitoring JupyterHub
# ============================================================================

set -euo pipefail

echo "Monitoring JupyterHub..."

if systemctl is-active --quiet jupyterhub; then
    # Métriques JupyterHub
    USERS=$(jupyterhub list-users 2>/dev/null | wc -l || echo "0")
    SERVERS=$(jupyterhub list-servers 2>/dev/null | wc -l || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/jupyterhub.prom <<EOF
# TYPE jupyterhub_active_users gauge
jupyterhub_active_users $USERS

# TYPE jupyterhub_running_servers gauge
jupyterhub_running_servers $SERVERS
EOF
    
    echo "✅ Monitoring JupyterHub configuré"
else
    echo "⚠️  JupyterHub non disponible"
fi
