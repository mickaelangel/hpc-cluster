#!/bin/bash
# ============================================================================
# Configuration Firewall Avancée - Cluster HPC
# iptables/nftables avec règles strictes et Zero Trust
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION FIREWALL AVANCÉE${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation outils firewall...${NC}"

zypper install -y firewalld nftables iptables-services || {
    echo -e "${RED}Erreur: Installation firewall échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Outils firewall installés${NC}"

# ============================================================================
# 2. CONFIGURATION NFTABLES (MODERNE)
# ============================================================================
echo -e "\n${YELLOW}[2/4] Configuration nftables...${NC}"

# Créer configuration nftables
cat > /etc/nftables/cluster-hpc.nft <<'EOF'
#!/usr/sbin/nft -f

# Flush existing rules
flush ruleset

# Tables
table inet filter {
    # Chains
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Loopback
        iif lo accept
        
        # Established/Related connections
        ct state established,related accept
        
        # ICMP (ping)
        icmp type echo-request limit rate 1/second accept
        icmpv6 type echo-request limit rate 1/second accept
        
        # SSH (port 22) - Rate limiting
        tcp dport 22 ct state new limit rate 3/minute accept
        
        # Prometheus (port 9090) - Internal only
        tcp dport 9090 ip saddr { 172.20.0.0/24, 10.0.0.0/24 } accept
        
        # Grafana (port 3000) - Internal only
        tcp dport 3000 ip saddr { 172.20.0.0/24, 10.0.0.0/24 } accept
        
        # Slurm (ports 6817-6819) - Internal only
        tcp dport { 6817-6819 } ip saddr { 10.0.0.0/24 } accept
        
        # LDAP (port 389) - Internal only
        tcp dport 389 ip saddr { 172.20.0.0/24, 10.0.0.0/24 } accept
        
        # Kerberos (port 88) - Internal only
        tcp dport 88 ip saddr { 172.20.0.0/24, 10.0.0.0/24 } accept
        udp dport 88 ip saddr { 172.20.0.0/24, 10.0.0.0/24 } accept
        
        # Drop all other
        drop
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
        
        # Allow established/related
        ct state established,related accept
        
        # Internal network forwarding
        ip saddr { 172.20.0.0/24, 10.0.0.0/24 } ip daddr { 172.20.0.0/24, 10.0.0.0/24 } accept
        
        # Drop all other
        drop
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# Logging chain for security events
table inet security_log {
    chain input_log {
        type filter hook input priority 10; policy accept;
        
        # Log dropped packets
        limit rate 10/minute log prefix "FIREWALL-DROP: " drop
    }
}
EOF

chmod +x /etc/nftables/cluster-hpc.nft

# Activer nftables
systemctl enable nftables
systemctl start nftables
nft -f /etc/nftables/cluster-hpc.nft

echo -e "${GREEN}  ✅ nftables configuré${NC}"

# ============================================================================
# 3. CONFIGURATION FIREWALLD (ALTERNATIVE)
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration firewalld...${NC}"

systemctl enable firewalld
systemctl start firewalld

# Zones
firewall-cmd --permanent --new-zone=cluster-internal
firewall-cmd --permanent --new-zone=cluster-external

# Configuration zone interne
firewall-cmd --permanent --zone=cluster-internal --add-source=172.20.0.0/24
firewall-cmd --permanent --zone=cluster-internal --add-source=10.0.0.0/24
firewall-cmd --permanent --zone=cluster-internal --add-service=ssh
firewall-cmd --permanent --zone=cluster-internal --add-service=ldap
firewall-cmd --permanent --zone=cluster-internal --add-port=9090/tcp  # Prometheus
firewall-cmd --permanent --zone=cluster-internal --add-port=3000/tcp  # Grafana

# Configuration zone externe (restrictive)
firewall-cmd --permanent --zone=cluster-external --add-service=ssh
firewall-cmd --permanent --zone=cluster-external --set-target=drop

# Recharger
firewall-cmd --reload

echo -e "${GREEN}  ✅ firewalld configuré${NC}"

# ============================================================================
# 4. RÈGLES IPTABLES (COMPATIBILITÉ)
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration iptables (compatibilité)...${NC}"

# Script iptables
cat > /etc/iptables/rules.v4 <<'EOF'
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

# Loopback
-A INPUT -i lo -j ACCEPT

# Established/Related
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# ICMP (ping) - Rate limited
-A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/sec -j ACCEPT

# SSH - Rate limited
-A INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 3/min -j ACCEPT

# Prometheus - Internal only
-A INPUT -p tcp --dport 9090 -s 172.20.0.0/24 -j ACCEPT
-A INPUT -p tcp --dport 9090 -s 10.0.0.0/24 -j ACCEPT

# Grafana - Internal only
-A INPUT -p tcp --dport 3000 -s 172.20.0.0/24 -j ACCEPT
-A INPUT -p tcp --dport 3000 -s 10.0.0.0/24 -j ACCEPT

# Slurm - Internal only
-A INPUT -p tcp --dport 6817:6819 -s 10.0.0.0/24 -j ACCEPT

# LDAP - Internal only
-A INPUT -p tcp --dport 389 -s 172.20.0.0/24 -j ACCEPT
-A INPUT -p tcp --dport 389 -s 10.0.0.0/24 -j ACCEPT

# Kerberos - Internal only
-A INPUT -p tcp --dport 88 -s 172.20.0.0/24 -j ACCEPT
-A INPUT -p udp --dport 88 -s 172.20.0.0/24 -j ACCEPT

# Log dropped packets
-A INPUT -j LOG --log-prefix "FIREWALL-DROP: " --log-level 4
-A INPUT -j DROP

COMMIT
EOF

# Activer iptables
systemctl enable iptables
systemctl start iptables
iptables-restore < /etc/iptables/rules.v4

echo -e "${GREEN}  ✅ iptables configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== FIREWALL CONFIGURÉ ===${NC}"
echo "nftables: /etc/nftables/cluster-hpc.nft"
echo "firewalld: Zones cluster-internal, cluster-external"
echo "iptables: /etc/iptables/rules.v4"
echo ""
echo -e "${YELLOW}Vérification:${NC}"
echo "  nft list ruleset"
echo "  firewall-cmd --list-all"
echo "  iptables -L -n -v"
