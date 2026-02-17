#!/bin/bash
# ============================================================================
# Installation PostgreSQL - Base de Données Relationnelle
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION POSTGRESQL${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation PostgreSQL...${NC}"

zypper install -y postgresql15 postgresql15-server || {
    echo -e "${RED}Erreur: Installation PostgreSQL échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ PostgreSQL installé${NC}"

# ============================================================================
# 2. INITIALISATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Initialisation base de données...${NC}"

# Initialiser cluster PostgreSQL (openSUSE: initdb, pas postgresql-setup)
PGDATA="${PGDATA:-/var/lib/pgsql/data}"
if [ ! -f "$PGDATA/postgresql.conf" ]; then
    su - postgres -c "/usr/bin/initdb -D $PGDATA" || {
        echo -e "${YELLOW}  ⚠️  Initialisation peut nécessiter configuration manuelle${NC}"
    }
fi

# Configuration PostgreSQL (si le répertoire existe)
if [ -d "$PGDATA" ]; then
cat >> "$PGDATA/postgresql.conf" <<EOF
# Configuration PostgreSQL pour Cluster HPC
listen_addresses = 'localhost'
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 4MB
min_wal_size = 1GB
max_wal_size = 4GB
EOF

# Configuration accès
cat >> "$PGDATA/pg_hba.conf" <<EOF
# Accès local
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
EOF
fi

echo -e "${GREEN}  ✅ Base de données initialisée${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage PostgreSQL...${NC}"

systemctl enable postgresql
systemctl start postgresql

# Créer base de données pour cluster
su - postgres -c "createdb cluster_hpc" || {
    echo -e "${YELLOW}  ⚠️  Base de données peut nécessiter création manuelle${NC}"
}

echo -e "${GREEN}  ✅ PostgreSQL démarré${NC}"

echo -e "\n${GREEN}=== POSTGRESQL INSTALLÉ ===${NC}"
echo "Service: systemctl status postgresql"
echo "Connexion: psql -U postgres -d cluster_hpc"
