#!/bin/bash
# ============================================================================
# Migration Automatisée - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Migration automatisée..."

# Migration utilisateurs LDAP vers FreeIPA
if command -v ipa &> /dev/null; then
    # Exporter utilisateurs LDAP
    ldapsearch -x -b "ou=people,dc=cluster,dc=local" > /tmp/ldap-users.ldif
    
    # Importer dans FreeIPA
    while read user; do
        ipa user-add "$user" --first="$user" --last="User"
    done < /tmp/ldap-users.ldif
fi

# Migration données BeeGFS vers Lustre
if mountpoint -q /mnt/beegfs && mountpoint -q /mnt/lustre; then
    rsync -avz /mnt/beegfs/ /mnt/lustre/
fi

echo "✅ Migration terminée"
