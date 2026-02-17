#!/bin/bash
# ============================================================================
# Script d'Installation JupyterHub - Cluster HPC
# Calcul interactif avec intégration Slurm
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
JUPYTERHUB_PORT="${JUPYTERHUB_PORT:-8000}"
LDAP_SERVER="${LDAP_SERVER:-frontal-01.cluster.local}"
LDAP_BASE="${LDAP_BASE:-dc=cluster,dc=local}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION JUPYTERHUB${NC}"
echo -e "${GREEN}Port: $JUPYTERHUB_PORT${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION PYTHON ET DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation Python et dépendances...${NC}"

zypper install -y python3 python3-pip nodejs npm || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

# ============================================================================
# 2. INSTALLATION JUPYTERHUB
# ============================================================================
echo -e "\n${YELLOW}[2/4] Installation JupyterHub...${NC}"

# Installation via pip
pip3 install --upgrade pip
pip3 install jupyterhub jupyterlab batchspawner ldapauthenticator || {
    echo -e "${RED}Erreur: Installation JupyterHub échouée${NC}"
    exit 1
}

# Installation configurable-http-proxy
npm install -g configurable-http-proxy || {
    echo -e "${YELLOW}  ⚠️  Installation configurable-http-proxy échouée${NC}"
}

echo -e "${GREEN}  ✅ JupyterHub installé${NC}"

# ============================================================================
# 3. CONFIGURATION JUPYTERHUB
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration JupyterHub...${NC}"

mkdir -p /etc/jupyterhub
mkdir -p /var/log/jupyterhub

# Configuration JupyterHub
cat > /etc/jupyterhub/jupyterhub_config.py <<EOF
# Configuration JupyterHub - Cluster HPC
import os

c = get_config()

# Authentification LDAP
c.JupyterHub.authenticator_class = 'ldapauthenticator.LDAPAuthenticator'
c.LDAPAuthenticator.server_address = '${LDAP_SERVER}'
c.LDAPAuthenticator.bind_dn_template = 'uid={username},ou=users,${LDAP_BASE}'
c.LDAPAuthenticator.use_ssl = False
c.LDAPAuthenticator.lookup_dn = True
c.LDAPAuthenticator.user_search_base = 'ou=users,${LDAP_BASE}'
c.LDAPAuthenticator.user_attribute = 'uid'

# Spawner Slurm
c.JupyterHub.spawner_class = 'batchspawner.SlurmSpawner'
c.SlurmSpawner.batch_script = '/etc/jupyterhub/slurm_batch.sh'
c.SlurmSpawner.req_partition = 'normal'
c.SlurmSpawner.req_nprocs = '1'
c.SlurmSpawner.req_runtime = '2:00:00'

# Répertoires
c.Spawner.notebook_dir = '/gpfs/home/{username}'
c.Spawner.default_url = '/lab'

# Port
c.JupyterHub.port = ${JUPYTERHUB_PORT}

# Logs
c.JupyterHub.log_level = 'INFO'
c.JupyterHub.log_file = '/var/log/jupyterhub/jupyterhub.log'
EOF

# Script batch Slurm
cat > /etc/jupyterhub/slurm_batch.sh <<'EOF'
#!/bin/bash
#SBATCH --job-name=jupyterhub
#SBATCH --output=/var/log/jupyterhub/jupyter-%j.out
#SBATCH --error=/var/log/jupyterhub/jupyter-%j.err
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# Démarrer JupyterLab
exec jupyter-lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=''
EOF

chmod +x /etc/jupyterhub/slurm_batch.sh

echo -e "${GREEN}  ✅ JupyterHub configuré${NC}"

# ============================================================================
# 4. SERVICE SYSTEMD
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration service systemd...${NC}"

cat > /etc/systemd/system/jupyterhub.service <<EOF
[Unit]
Description=JupyterHub
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable jupyterhub
systemctl start jupyterhub

echo -e "${GREEN}  ✅ Service JupyterHub démarré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== JUPYTERHUB INSTALLÉ ===${NC}"
echo "Port: $JUPYTERHUB_PORT"
echo "LDAP Server: $LDAP_SERVER"
echo ""
echo -e "${YELLOW}ACCÈS:${NC}"
echo "  URL: http://$(hostname):${JUPYTERHUB_PORT}"
echo "  Authentification: LDAP"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
