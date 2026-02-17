#!/bin/bash
# ============================================================================
# Configuration Quotas Avancés - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Configuration quotas avancés..."

# BeeGFS quotas
beegfs-ctl --setquota --uid=1001 --limit=100G /mnt/beegfs

echo "✅ Quotas configurés"
