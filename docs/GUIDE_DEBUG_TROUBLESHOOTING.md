# Guide de Debug et Troubleshooting - Cluster HPC
## Diagnostic et Résolution de Problèmes

**Classification**: Documentation Opérationnelle  
**Public**: Administrateurs Système / Ingénieurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Outils de Diagnostic](#outils-de-diagnostic)
2. [Debug Système](#debug-système)
3. [Debug Applications](#debug-applications)
4. [Debug Performance](#debug-performance)
5. [Debug Réseau](#debug-réseau)
6. [Debug Stockage](#debug-stockage)
7. [Problèmes Courants](#problèmes-courants)

---

## 🔧 Outils de Diagnostic

### Scripts Automatisés

**Diagnostic Complet** :
```bash
# Diagnostic automatique
./scripts/troubleshooting/diagnose-cluster.sh

# Collecte logs
./scripts/troubleshooting/collect-logs.sh
```

**Tests de Santé** :
```bash
# Test complet
./scripts/tests/test-cluster-health.sh

# Tests spécifiques
./scripts/tests/test-ldap-kerberos.sh
./scripts/tests/test-slurm.sh
```

---

## 🖥️ Debug Système

### Vérification de Base

**État Système** :
```bash
# CPU
top
htop

# Mémoire
free -h
cat /proc/meminfo

# Disque
df -h
iostat -x 1

# Réseau
iftop
nethogs
```

**Services** :
```bash
# État des services
systemctl status SERVICE_NAME

# Logs
journalctl -u SERVICE_NAME -xe

# Dépendances
systemctl list-dependencies SERVICE_NAME
```

### Problèmes Système

**CPU Surchargé** :
```bash
# Identifier processus
top -o %CPU

# Limiter processus
nice -n 19 COMMAND
```

**Mémoire Surchargée** :
```bash
# Identifier processus
top -o %MEM

# Vérifier swap
swapon --show
```

**Disque Surchargé** :
```bash
# Identifier gros fichiers
du -sh /* | sort -h

# Nettoyer
# - Logs anciens
# - Fichiers temporaires
# - Cache
```

---

## 🔬 Debug Applications

### Debug Slurm

**Problème** : Job ne démarre pas

**Diagnostic** :
```bash
# Détails du job
scontrol show job JOB_ID

# Raison de l'attente
squeue -j JOB_ID -o "%.30R"

# Logs
cat slurm-JOB_ID.out
cat slurm-JOB_ID.err
```

**Solutions** :
- Vérifier ressources demandées
- Vérifier partitions disponibles
- Vérifier contraintes
- Vérifier quotas

---

### Debug GROMACS

**Problème** : Simulation échoue

**Diagnostic** :
```bash
# Vérifier installation
module load gromacs/2023.2
gmx --version

# Test simple
gmx grompp -f test.mdp -c test.gro -p test.top -o test.tpr

# Logs
tail -f md.log
```

**Solutions** :
- Vérifier fichiers d'entrée
- Vérifier ressources
- Vérifier modules chargés

---

### Debug OpenFOAM

**Problème** : Simulation échoue

**Diagnostic** :
```bash
# Vérifier installation
module load openfoam/2312
simpleFoam --help

# Vérifier cas
checkMesh

# Logs
tail -f log.simpleFoam
```

**Solutions** :
- Vérifier maillage
- Vérifier configuration
- Vérifier ressources

---

## ⚡ Debug Performance

### Outils de Profiling

**CPU** :
```bash
# Profiling
perf record APPLICATION
perf report

# Flamegraph
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg
```

**Mémoire** :
```bash
# Valgrind
valgrind --leak-check=full APPLICATION

# Massif
valgrind --tool=massif APPLICATION
```

**I/O** :
```bash
# iotop
iotop -o

# strace
strace -e trace=open,read,write APPLICATION
```

---

## 🌐 Debug Réseau

### Vérifications Réseau

**Connectivité** :
```bash
# Ping
ping NODE_NAME

# Traceroute
traceroute NODE_NAME

# Test port
nc -zv NODE_NAME PORT
```

**Performance** :
```bash
# iperf3
# Serveur
iperf3 -s

# Client
iperf3 -c SERVER_IP

# Latence
ping -c 100 NODE_NAME
```

**Problèmes Réseau** :
```bash
# Vérifier interfaces
ip addr show

# Vérifier routes
ip route show

# Vérifier firewall
iptables -L
firewall-cmd --list-all
```

---

## 💾 Debug Stockage

### Debug BeeGFS

**Problèmes** :
```bash
# État
beegfs-ctl --getentryinfo

# Services
systemctl status beegfs-mgmtd
systemctl status beegfs-meta
systemctl status beegfs-storage

# Performance
beegfs-ctl --getstats
```

**Solutions** :
- Redémarrer services
- Vérifier réseau
- Vérifier espace

---

## 🔍 Problèmes Courants

### 1. Job en Attente

**Diagnostic** :
```bash
squeue -j JOB_ID -o "%.30R"
scontrol show job JOB_ID
```

**Solutions** :
- Réduire ressources
- Changer partition
- Vérifier contraintes

### 2. Authentification Échoue

**Diagnostic** :
```bash
ldapsearch -x -b "dc=cluster,dc=local"
kinit USERNAME
```

**Solutions** :
- Vérifier credentials
- Renouveler ticket
- Redémarrer services

### 3. Performance Dégradée

**Diagnostic** :
```bash
htop
iostat -x 1
iftop
```

**Solutions** :
- Identifier processus
- Optimiser configuration
- Vérifier ressources

---

## 📊 Outils de Monitoring

### Prometheus

**Requêtes Utiles** :
```promql
# CPU utilisation
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Mémoire utilisation
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# Jobs en attente
slurm_jobs_pending
```

### Grafana

**Dashboards** :
- Vue d'ensemble
- Performance
- Sécurité
- Réseau

---

## ✅ Checklist de Debug

### Avant de Commencer
- [ ] Collecter informations
- [ ] Reproduire le problème
- [ ] Vérifier logs
- [ ] Vérifier configuration

### Pendant le Debug
- [ ] Utiliser outils appropriés
- [ ] Documenter les étapes
- [ ] Tester les solutions
- [ ] Vérifier l'impact

### Après le Debug
- [ ] Documenter la solution
- [ ] Mettre à jour documentation
- [ ] Prévenir récurrence

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
