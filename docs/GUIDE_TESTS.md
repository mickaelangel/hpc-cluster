# Guide de Tests - Cluster HPC
## Suite de Tests Automatisés

**Classification**: Documentation Technique  
**Public**: Administrateurs Système / Ingénieurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Tests de Santé](#tests-de-santé)
3. [Tests LDAP + Kerberos](#tests-ldap--kerberos)
4. [Tests Slurm](#tests-slurm)
5. [Tests GPFS](#tests-gpfs)
6. [Tests Réseau](#tests-réseau)
7. [Exécution Complète](#exécution-complète)

---

## 🎯 Vue d'ensemble

Ce guide explique comment utiliser la suite de tests automatisés pour valider le cluster HPC.

### Scripts Disponibles

- `test-cluster-health.sh` - Vérification santé complète
- `test-ldap-kerberos.sh` - Tests authentification
- `test-slurm.sh` - Tests scheduler
- `test-gpfs.sh` - Tests stockage (à créer)
- `test-network.sh` - Tests réseau (à créer)

---

## ✅ Tests de Santé

### Exécution

```bash
cd cluster\ hpc/scripts/tests
sudo ./test-cluster-health.sh
```

### Tests Effectués

- Services système (SSH, NetworkManager, Chronyd)
- LDAP (service, accessibilité)
- Kerberos (KDC, Kadmin, configuration)
- Slurm (SlurmCTLD, accessibilité, Munge)
- GPFS (état, configuration)
- Monitoring (Prometheus, Grafana)
- Réseau (interfaces, DNS, connectivité)
- Disque (espace disponible)

### Sortie

- ✅ Tests réussis
- ❌ Tests échoués
- ⚠️ Avertissements

---

## 🔐 Tests LDAP + Kerberos

### Exécution

```bash
cd cluster\ hpc/scripts/tests
sudo ./test-ldap-kerberos.sh
```

### Tests Effectués

**LDAP** :
- Service actif
- Connexion
- Recherche utilisateur
- Authentification

**Kerberos** :
- Services KDC et Kadmin
- Configuration
- Tickets admin et utilisateur

**Intégration** :
- SSSD
- PAM
- SSH avec Kerberos

---

## ⚡ Tests Slurm

### Exécution

```bash
cd cluster\ hpc/scripts/tests
sudo ./test-slurm.sh
```

### Tests Effectués

- Services (SlurmCTLD, SlurmDBD, Munge)
- Configuration
- Connectivité
- Nœuds
- Soumission de jobs

### Test de Job

Le script soumet automatiquement un job de test et vérifie :
- Soumission réussie
- Exécution
- Sortie du job

---

## 📊 Tests GPFS

### À Créer

```bash
# Script à créer: test-gpfs.sh
cd cluster\ hpc/scripts/tests
# TODO: Implémenter tests GPFS
```

### Tests Recommandés

- Service GPFS actif
- Configuration
- Montages
- Quotas
- I/O performance

---

## 🌐 Tests Réseau

### À Créer

```bash
# Script à créer: test-network.sh
cd cluster\ hpc/scripts/tests
# TODO: Implémenter tests réseau
```

### Tests Recommandés

- Interfaces réseau
- Connectivité inter-nœuds
- Latence
- Bande passante
- DNS

---

## 🚀 Exécution Complète

### Script de Tous les Tests

```bash
#!/bin/bash
# test-all.sh

cd cluster\ hpc/scripts/tests

echo "=== Tests Santé ==="
./test-cluster-health.sh

echo "=== Tests LDAP + Kerberos ==="
./test-ldap-kerberos.sh

echo "=== Tests Slurm ==="
./test-slurm.sh

echo "=== Tests GPFS ==="
# ./test-gpfs.sh

echo "=== Tests Réseau ==="
# ./test-network.sh
```

### Cron Quotidien

```bash
# /etc/cron.daily/test-cluster
0 2 * * * root /path/to/test-cluster-health.sh >> /var/log/cluster-tests.log 2>&1
```

---

## 📊 Interprétation des Résultats

### Codes de Sortie

- **0** : Tous les tests passent
- **1** : Des tests ont échoué

### Messages

- **✅ Vert** : Test réussi
- **❌ Rouge** : Test échoué (critique)
- **⚠️ Jaune** : Avertissement (non critique)

---

## 🔧 Dépannage

### Tests Échoués

1. **Vérifier les services** :
   ```bash
   systemctl status <service>
   ```

2. **Vérifier les logs** :
   ```bash
   journalctl -u <service> -n 50
   ```

3. **Relancer les tests** :
   ```bash
   ./test-cluster-health.sh
   ```

---

## 📚 Ressources

- **Slurm Documentation** : https://slurm.schedmd.com/
- **LDAP Documentation** : https://directory.fedoraproject.org/docs/
- **Kerberos Documentation** : https://web.mit.edu/kerberos/krb5-latest/doc/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
