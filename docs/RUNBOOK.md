# Runbook Opérationnel - Cluster HPC

## 📋 Table des Matières

- [Procédures Quotidiennes](#procédures-quotidiennes)
- [Procédures Hebdomadaires](#procédures-hebdomadaires)
- [Procédures Mensuelles](#procédures-mensuelles)
- [Incidents Courants](#incidents-courants)
- [Escalade](#escalade)

## 🔄 Procédures Quotidiennes

### Vérification Matinale (08:00)

```bash
# 1. Vérifier l'état du cluster
sudo bash scripts/tests/test-cluster-health.sh

# 2. Vérifier les conteneurs
cd docker && docker-compose ps

# 3. Vérifier les logs d'erreur
docker-compose logs --tail=100 | grep -i error

# 4. Vérifier l'espace disque
df -h

# 5. Vérifier la charge système
uptime
```

### Monitoring Continu

- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000
- **Alertes** : Vérifier les alertes actives

## 📅 Procédures Hebdomadaires

### Lundi - Review de la Semaine

- Analyser les métriques de la semaine précédente
- Vérifier les alertes récurrentes
- Planifier les maintenances

### Mercredi - Sauvegarde

```bash
# Sauvegarde complète
sudo bash scripts/backup/backup-cluster.sh

# Vérifier l'intégrité
sudo bash scripts/backup/verify-backup.sh
```

### Vendredi - Maintenance Préventive

- Nettoyage des logs
- Rotation des fichiers temporaires
- Vérification des mises à jour de sécurité

## 📆 Procédures Mensuelles

### Premier du Mois - Audit Complet

```bash
# Audit de sécurité
sudo bash scripts/security/audit-security-automated.sh

# Scan de vulnérabilités
sudo bash scripts/security/scan-vulnerabilities.sh

# Review des permissions
sudo bash scripts/security/monitor-compliance.sh
```

### Mise à Jour Mensuelle

```bash
# Mise à jour des images Docker
docker-compose pull

# Mise à jour du système
sudo zypper update

# Redémarrage contrôlé
sudo bash scripts/maintenance/update-cluster.sh
```

## 🚨 Incidents Courants

### Service Prometheus Down

**Symptômes** : Grafana ne peut pas récupérer les métriques

**Actions** :
```bash
# 1. Vérifier le conteneur
docker ps | grep prometheus

# 2. Redémarrer si nécessaire
cd docker
docker-compose restart prometheus

# 3. Vérifier les logs
docker-compose logs prometheus

# 4. Vérifier la santé
curl http://localhost:9090/-/healthy
```

### Nœud de Calcul Non Répondant

**Symptômes** : Jobs en attente, nœud marqué DOWN dans Slurm

**Actions** :
```bash
# 1. Vérifier le nœud
ssh compute-01
systemctl status slurmd

# 2. Redémarrer le service
sudo systemctl restart slurmd

# 3. Vérifier la connectivité réseau
ping frontal-01

# 4. Si problème persiste, redémarrer le conteneur
cd docker
docker-compose restart compute-01
```

### Espace Disque Faible

**Symptômes** : Alertes Prometheus, jobs échouent

**Actions** :
```bash
# 1. Identifier les gros fichiers
du -sh /* | sort -h

# 2. Nettoyer les logs
sudo journalctl --vacuum-time=7d

# 3. Nettoyer Docker
docker system prune -a --volumes

# 4. Nettoyer Prometheus (si nécessaire)
# Modifier retention dans prometheus.yml
```

## 📞 Escalade

### Niveau 1 - Support (24/7)
- Email : support@example.com
- Tél : +33 X XX XX XX XX

### Niveau 2 - Ingénieur DevOps
- Disponibilité : 08:00 - 20:00
- Escalade automatique après 2h sans résolution

### Niveau 3 - Architecte Senior
- Disponibilité : Sur appel
- Escalade pour incidents critiques

## 📊 Métriques Clés (SLA)

- **Disponibilité** : 99.9% (8.76h downtime/an)
- **Temps de réponse** : < 5s pour API
- **Récupération** : < 1h pour incidents majeurs
- **Backup** : Quotidien, rétention 30 jours

## 🔗 Liens Utiles

- **Documentation** : `docs/`
- **Troubleshooting** : `docs/GUIDE_TROUBLESHOOTING.md`
- **Maintenance** : `docs/GUIDE_MAINTENANCE_COMPLETE.md`
- **Sécurité** : `docs/GUIDE_SECURITE_AVANCEE.md`
