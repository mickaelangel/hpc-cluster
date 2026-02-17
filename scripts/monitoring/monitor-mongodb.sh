#!/bin/bash
# ============================================================================
# Monitoring MongoDB
# ============================================================================

set -euo pipefail

echo "Monitoring MongoDB..."

if systemctl is-active --quiet mongod; then
    # Métriques MongoDB
    CONNECTIONS=$(mongo --quiet --eval "db.serverStatus().connections.current" 2>/dev/null || echo "0")
    DATABASES=$(mongo --quiet --eval "db.adminCommand('listDatabases').databases.length" 2>/dev/null || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/mongodb.prom <<EOF
# TYPE mongodb_connections_active gauge
mongodb_connections_active $CONNECTIONS

# TYPE mongodb_databases_total gauge
mongodb_databases_total $DATABASES
EOF
    
    echo "✅ Monitoring MongoDB configuré"
else
    echo "⚠️  MongoDB non disponible"
fi
