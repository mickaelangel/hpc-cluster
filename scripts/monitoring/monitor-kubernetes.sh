#!/bin/bash
# ============================================================================
# Monitoring Kubernetes
# ============================================================================

set -euo pipefail

echo "Monitoring Kubernetes..."

if kubectl cluster-info &> /dev/null; then
    # Métriques Kubernetes
    PODS=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l || echo "0")
    NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/kubernetes.prom <<EOF
# TYPE kubernetes_pods_total gauge
kubernetes_pods_total $PODS

# TYPE kubernetes_nodes_total gauge
kubernetes_nodes_total $NODES
EOF
    
    echo "✅ Monitoring Kubernetes configuré"
else
    echo "⚠️  Kubernetes non disponible"
fi
