#!/bin/bash
# ============================================================================
# Monitoring PostgreSQL
# ============================================================================

set -euo pipefail

echo "Monitoring PostgreSQL..."

if systemctl is-active --quiet postgresql; then
    # Métriques PostgreSQL
    CONNECTIONS=$(psql -U postgres -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null || echo "0")
    DATABASES=$(psql -U postgres -t -c "SELECT count(*) FROM pg_database;" 2>/dev/null || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/postgresql.prom <<EOF
# TYPE postgresql_connections_active gauge
postgresql_connections_active $CONNECTIONS

# TYPE postgresql_databases_total gauge
postgresql_databases_total $DATABASES
EOF
    
    echo "✅ Monitoring PostgreSQL configuré"
else
    echo "⚠️  PostgreSQL non disponible"
fi
