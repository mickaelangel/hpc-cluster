#!/bin/bash
# ============================================================================
# Installation Hadoop
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION HADOOP${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger Hadoop
HADOOP_VERSION="3.3.6"
cd /opt
wget -q "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" || {
    echo -e "${YELLOW}⚠️  Téléchargement échoué${NC}"
    exit 1
}

tar -xzf "hadoop-${HADOOP_VERSION}.tar.gz"
mv hadoop-${HADOOP_VERSION} hadoop

echo -e "${GREEN}✅ Hadoop installé${NC}"
echo "Hadoop: /opt/hadoop"
echo "Test: /opt/hadoop/bin/hadoop version"
