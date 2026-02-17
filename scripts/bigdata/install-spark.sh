#!/bin/bash
# ============================================================================
# Installation Apache Spark
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION APACHE SPARK${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger Spark
SPARK_VERSION="3.5.0"
cd /opt
wget -q "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" || {
    echo -e "${YELLOW}⚠️  Téléchargement échoué${NC}"
    exit 1
}

tar -xzf "spark-${SPARK_VERSION}-bin-hadoop3.tgz"
mv spark-${SPARK_VERSION}-bin-hadoop3 spark
ln -s /opt/spark/bin/spark-submit /usr/local/bin/

echo -e "${GREEN}✅ Spark installé${NC}"
echo "Spark: /opt/spark"
echo "Test: spark-submit --version"
