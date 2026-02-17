#!/bin/bash
# ============================================================================
# Création Système de Reporting Automatique
# ============================================================================

set -euo pipefail

REPORT_DIR="cluster hpc/reports"

mkdir -p "$REPORT_DIR"

# Script génération rapport
cat > "$REPORT_DIR/generate-report.sh" <<'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
REPORT_FILE="report-$DATE.html"

cat > "$REPORT_FILE" <<HTML
<!DOCTYPE html>
<html>
<head><title>Cluster HPC Report - $DATE</title></head>
<body>
    <h1>Cluster HPC Report</h1>
    <p>Date: $DATE</p>
    <h2>Jobs</h2>
    <pre>$(squeue)</pre>
    <h2>Nodes</h2>
    <pre>$(sinfo)</pre>
</body>
</html>
HTML

echo "Rapport généré: $REPORT_FILE"
EOF

chmod +x "$REPORT_DIR/generate-report.sh"

echo "✅ Système reporting créé"
