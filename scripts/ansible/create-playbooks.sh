#!/bin/bash
# ============================================================================
# Création Playbooks Ansible pour Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ANSIBLE_DIR="cluster hpc/ansible"
PLAYBOOKS_DIR="$ANSIBLE_DIR/playbooks"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CRÉATION PLAYBOOKS ANSIBLE${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$PLAYBOOKS_DIR"

# ============================================================================
# 1. PLAYBOOK DÉPLOIEMENT CLUSTER
# ============================================================================
echo -e "\n${YELLOW}[1/5] Création playbook déploiement...${NC}"

cat > "$PLAYBOOKS_DIR/deploy-cluster.yml" <<'EOF'
---
- name: Déploiement Cluster HPC
  hosts: all
  become: yes
  vars:
    cluster_name: hpc-cluster
    node_count: 8
  
  tasks:
    - name: Mettre à jour système
      zypper:
        update_cache: yes
        state: latest
    
    - name: Installer packages de base
      zypper:
        name:
          - docker
          - docker-compose
          - slurm
          - openssh
        state: present
    
    - name: Démarrer services
      systemd:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop:
        - docker
        - sshd
        - slurmctld
EOF

echo -e "${GREEN}  ✅ Playbook déploiement créé${NC}"

# ============================================================================
# 2. PLAYBOOK CONFIGURATION SÉCURITÉ
# ============================================================================
echo -e "\n${YELLOW}[2/5] Création playbook sécurité...${NC}"

cat > "$PLAYBOOKS_DIR/configure-security.yml" <<'EOF'
---
- name: Configuration Sécurité Cluster
  hosts: all
  become: yes
  
  tasks:
    - name: Configurer firewall
      shell: ./scripts/security/configure-firewall.sh
      args:
        chdir: /opt/hpc-cluster
    
    - name: Installer Fail2ban
      zypper:
        name: fail2ban
        state: present
    
    - name: Configurer Fail2ban
      template:
        src: fail2ban.conf.j2
        dest: /etc/fail2ban/jail.local
    
    - name: Démarrer Fail2ban
      systemd:
        name: fail2ban
        state: started
        enabled: yes
EOF

echo -e "${GREEN}  ✅ Playbook sécurité créé${NC}"

# ============================================================================
# 3. PLAYBOOK MAINTENANCE
# ============================================================================
echo -e "\n${YELLOW}[3/5] Création playbook maintenance...${NC}"

cat > "$PLAYBOOKS_DIR/maintenance.yml" <<'EOF'
---
- name: Maintenance Cluster HPC
  hosts: all
  become: yes
  
  tasks:
    - name: Nettoyer packages
      shell: zypper clean --all
    
    - name: Nettoyer logs anciens
      find:
        paths: /var/log
        patterns: "*.log"
        age: 30d
        state: absent
    
    - name: Vérifier espace disque
      shell: df -h
      register: disk_usage
    
    - name: Afficher utilisation disque
      debug:
        var: disk_usage.stdout_lines
EOF

echo -e "${GREEN}  ✅ Playbook maintenance créé${NC}"

# ============================================================================
# 4. INVENTAIRE ANSIBLE
# ============================================================================
echo -e "\n${YELLOW}[4/5] Création inventaire...${NC}"

cat > "$ANSIBLE_DIR/inventory.yml" <<'EOF'
all:
  children:
    frontals:
      hosts:
        frontal-01:
          ansible_host: 172.20.0.101
        frontal-02:
          ansible_host: 172.20.0.102
    
    compute:
      hosts:
        compute-01:
          ansible_host: 10.0.0.201
        compute-02:
          ansible_host: 10.0.0.202
        compute-03:
          ansible_host: 10.0.0.203
        compute-04:
          ansible_host: 10.0.0.204
        compute-05:
          ansible_host: 10.0.0.205
        compute-06:
          ansible_host: 10.0.0.206
EOF

echo -e "${GREEN}  ✅ Inventaire créé${NC}"

# ============================================================================
# 5. CONFIGURATION ANSIBLE
# ============================================================================
echo -e "\n${YELLOW}[5/5] Création configuration Ansible...${NC}"

cat > "$ANSIBLE_DIR/ansible.cfg" <<'EOF'
[defaults]
inventory = inventory.yml
host_key_checking = False
remote_user = root
private_key_file = ~/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

echo -e "${GREEN}  ✅ Configuration créée${NC}"

echo -e "\n${GREEN}=== PLAYBOOKS ANSIBLE CRÉÉS ===${NC}"
echo "Répertoire: $ANSIBLE_DIR"
echo "Utilisation: ansible-playbook playbooks/deploy-cluster.yml"
