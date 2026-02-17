#!/bin/bash
# ============================================================================
# Création Interface Web de Gestion Cluster
# ============================================================================

set -euo pipefail

WEB_DIR="cluster hpc/web-interface"

mkdir -p "$WEB_DIR"

# Créer interface HTML simple
cat > "$WEB_DIR/index.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Cluster HPC Management</title>
</head>
<body>
    <h1>Cluster HPC Management</h1>
    <div id="status"></div>
    <script>
        fetch('/api/cluster/status')
            .then(r => r.json())
            .then(d => document.getElementById('status').innerHTML = JSON.stringify(d));
    </script>
</body>
</html>
EOF

echo "✅ Interface web créée"
