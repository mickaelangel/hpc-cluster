#!/bin/bash
# ============================================================================
# Création API REST pour Gestion Cluster
# ============================================================================

set -euo pipefail

API_DIR="cluster hpc/api"

mkdir -p "$API_DIR"

# Créer API Flask simple
cat > "$API_DIR/app.py" <<'EOF'
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/api/cluster/status')
def cluster_status():
    return jsonify({"status": "ok", "nodes": 8})

@app.route('/api/jobs')
def jobs():
    return jsonify({"jobs": []})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

echo "✅ API REST créée"
