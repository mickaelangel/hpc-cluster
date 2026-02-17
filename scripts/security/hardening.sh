#!/bin/bash
# ============================================================================
# Script de Hardening - Cluster HPC
# DISA STIG + CIS Level 2 + ANSSI BP-028
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}HARDENING CLUSTER HPC${NC}"
echo -e "${GREEN}DISA STIG + CIS Level 2${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. HARDENING KERNEL (sysctl)
# ============================================================================
echo -e "\n${YELLOW}[1/8] Hardening kernel (sysctl)...${NC}"

cat > /etc/sysctl.d/99-hpc-hardening.conf <<'EOF'
# Protection contre attaques réseau
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1

# Protection IPv6
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Protection contre Spectre/Meltdown
kernel.unprivileged_bpf_disabled = 1
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.unprivileged_userns_clone = 0

# Protection mémoire
vm.mmap_rnd_bits = 32
vm.mmap_rnd_compat_bits = 16
vm.swappiness = 10
EOF

sysctl -p /etc/sysctl.d/99-hpc-hardening.conf

# ============================================================================
# 2. HARDENING SSH
# ============================================================================
echo -e "\n${YELLOW}[2/8] Hardening SSH...${NC}"

# Backup configuration SSH
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)

# Configuration SSH sécurisée
cat >> /etc/ssh/sshd_config <<'EOF'

# Hardening SSH - DISA STIG
Protocol 2
PermitRootLogin no
PermitEmptyPasswords no
PasswordAuthentication yes
PubkeyAuthentication yes
PermitUserEnvironment no
X11Forwarding no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
AllowTcpForwarding no
AllowStreamLocalForwarding no
GatewayPorts no
PermitTunnel no

# Algorithmes sécurisés
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
EOF

systemctl restart sshd

# ============================================================================
# 3. CONFIGURATION FAIL2BAN
# ============================================================================
echo -e "\n${YELLOW}[3/8] Configuration Fail2ban...${NC}"

zypper install -y fail2ban

cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = root@localhost
sendername = Fail2Ban
action = %(action_)s

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
maxretry = 3
bantime = 3600

[slurm]
enabled = true
port = 6817,6818,6819,6820
logpath = /var/log/slurm/*.log
maxretry = 5
bantime = 7200
EOF

systemctl enable fail2ban
systemctl start fail2ban

# ============================================================================
# 4. CONFIGURATION AUDITD
# ============================================================================
echo -e "\n${YELLOW}[4/8] Configuration Auditd...${NC}"

zypper install -y audit

cat > /etc/audit/rules.d/hpc-hardening.rules <<'EOF'
# Audit des modifications système critiques
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /etc/slurm/slurm.conf -p wa -k slurm_config
-w /etc/krb5.conf -p wa -k kerberos_config
-w /etc/ldap/ldap.conf -p wa -k ldap_config

# Audit des accès privilégiés
-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -k privileged
-a always,exit -F arch=b32 -S execve -F euid=0 -F auid>=1000 -k privileged

# Audit des modifications réseau
-w /etc/hosts -p wa -k network_mod
-w /etc/sysconfig/network -p wa -k network_mod
-w /etc/sysconfig/network-scripts -p wa -k network_mod

# Audit des montages
-a always,exit -F arch=b64 -S mount -F auid>=1000 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=1000 -k mounts
EOF

systemctl enable auditd
systemctl start auditd

# ============================================================================
# 5. CONFIGURATION AIDE (Intégrité Fichiers)
# ============================================================================
echo -e "\n${YELLOW}[5/8] Configuration AIDE...${NC}"

zypper install -y aide

# Initialisation base de données AIDE
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Configuration cron pour vérification quotidienne
cat > /etc/cron.daily/aide-check <<'EOF'
#!/bin/bash
/usr/bin/aide --check > /var/log/aide/aide-check-$(date +%Y%m%d).log 2>&1
EOF

chmod +x /etc/cron.daily/aide-check

# ============================================================================
# 6. DÉSACTIVATION SERVICES INUTILES
# ============================================================================
echo -e "\n${YELLOW}[6/8] Désactivation services inutiles...${NC}"

# Services à désactiver
SERVICES_TO_DISABLE=(
    "ctrl-alt-del.target"
    "debug-shell.service"
    "kdump.service"
    "bluetooth.service"
    "avahi-daemon.service"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl list-unit-files | grep -q "$service"; then
        systemctl mask "$service" 2>/dev/null || true
        systemctl stop "$service" 2>/dev/null || true
    fi
done

# ============================================================================
# 7. CONFIGURATION PAM
# ============================================================================
echo -e "\n${YELLOW}[7/8] Configuration PAM...${NC}"

# Configuration mot de passe fort
cat > /etc/security/pwquality.conf <<'EOF'
minlen = 12
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
minclass = 3
maxrepeat = 2
EOF

# Configuration limites de connexion
cat >> /etc/security/limits.conf <<'EOF'
# Limites sécurité
* soft core 0
* hard core 0
* soft nproc 4096
* hard nproc 8192
EOF

# ============================================================================
# 8. PERMISSIONS FICHIERS SENSIBLES
# ============================================================================
echo -e "\n${YELLOW}[8/8] Configuration permissions fichiers sensibles...${NC}"

# Permissions fichiers critiques
chmod 600 /etc/ssh/sshd_config
chmod 600 /etc/shadow
chmod 644 /etc/passwd
chmod 644 /etc/group
chmod 600 /etc/slurm/slurm.conf
chmod 600 /etc/krb5.conf

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== HARDENING TERMINÉ ===${NC}"
echo "Configuration appliquée:"
echo "  ✅ Kernel (sysctl)"
echo "  ✅ SSH"
echo "  ✅ Fail2ban"
echo "  ✅ Auditd"
echo "  ✅ AIDE"
echo "  ✅ Services désactivés"
echo "  ✅ PAM"
echo "  ✅ Permissions fichiers"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Redémarrer le système pour appliquer tous les changements"
echo "  - Vérifier la configuration SSH avant déconnexion"
echo "  - Tester l'accès SSH après redémarrage"
echo ""
echo -e "${GREEN}Hardening terminé!${NC}"
