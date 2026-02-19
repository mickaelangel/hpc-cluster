# Contenu Initial pour le Wiki GitHub

## Instructions

Pour créer le Wiki sur GitHub, copiez le contenu de ces fichiers dans les pages Wiki correspondantes.

**Pages formation (niveau Master/Doctorat & DevOps Senior)** — déjà dans `.github/wiki/` :
- **Cours-HPC-Complet.md** : Cours exhaustif HPC (concepts, architecture, MPI, stockage, GPU, conteneurs)
- **Guide-SLURM-Complet.md** : Guide détaillé Slurm (partitions, QoS, sbatch, srun, bonnes pratiques)
- **Glossaire-et-Acronymes.md** : Dictionnaire des acronymes et termes HPC (HPC, MPI, SLURM, Lustre, etc.)

Le script `scripts/upload-wiki.ps1` (ou `upload-wiki.sh`) copie tous les `*.md` de `.github/wiki/` vers le dépôt Wiki GitHub.

---

## Page 1 : Home (Page d'accueil)

Copier le contenu de `WIKI_HOME.md` dans la première page du Wiki.

---

## Page 2 : FAQ

```markdown
# FAQ - Questions Fréquentes

## Installation

### Q: Quelle version d'OS est supportée ?
**R:** openSUSE 15 (équivalent à SUSE 15 SP7). Voir [INSTALLATION_OPENSUSE15.md](../INSTALLATION_OPENSUSE15.md)

### Q: Puis-je installer sans Internet ?
**R:** Oui, le projet supporte le déploiement offline. Voir [docs/INSTALLATION_HORS_LIGNE.md](../docs/INSTALLATION_HORS_LIGNE.md)

### Q: Combien de RAM est nécessaire ?
**R:** Minimum 16GB, 32GB+ recommandé pour la production.

## Configuration

### Q: Quelle est la différence entre LDAP/Kerberos et FreeIPA ?
**R:** FreeIPA est une solution complète qui inclut LDAP, Kerberos, DNS et plus. LDAP/Kerberos est une configuration manuelle. Voir [docs/GUIDE_AUTHENTIFICATION.md](../docs/GUIDE_AUTHENTIFICATION.md)

### Q: Comment changer les mots de passe par défaut ?
**R:** Voir [docs/GUIDE_SECURITE_AVANCEE.md](../docs/GUIDE_SECURITE_AVANCEE.md) - Section "Changement des mots de passe"

## Utilisation

### Q: Comment lancer un job Slurm ?
**R:** Voir [docs/GUIDE_LANCEMENT_JOBS.md](../docs/GUIDE_LANCEMENT_JOBS.md)

### Q: Comment accéder à Grafana ?
**R:** http://localhost:3000 (admin/admin123 - ⚠️ À changer)

## Problèmes

### Q: Le cluster ne démarre pas
**R:** Voir [docs/GUIDE_TROUBLESHOOTING.md](../docs/GUIDE_TROUBLESHOOTING.md)

### Q: Erreur de connexion à InfluxDB
**R:** Vérifier que le conteneur InfluxDB est démarré : `docker ps` ou `podman ps`

---

**Plus de questions ?** [Créer une discussion](https://github.com/mickaelangel/hpc-cluster/discussions/new)
```

---

## Page 3 : Installation Rapide

```markdown
# Installation Rapide

## Prérequis

- openSUSE 15
- Docker 20.10+
- 16GB+ RAM
- 50GB+ disque

## Installation en 3 Étapes

### 1. Cloner le projet

```bash
git clone https://github.com/mickaelangel/hpc-cluster.git
cd hpc-cluster
```

### 2. Installer

```bash
chmod +x install-all.sh
sudo ./install-all.sh
```

### 3. Vérifier

```bash
# Vérifier les conteneurs
docker ps

# Accéder à Grafana
# http://localhost:3000 (admin/admin123)
```

## Documentation Complète

Pour plus de détails, voir :
- [INSTALLATION_OPENSUSE15.md](../INSTALLATION_OPENSUSE15.md)
- [docs/GUIDE_INSTALLATION_COMPLETE.md](../docs/GUIDE_INSTALLATION_COMPLETE.md)
```

---

## Page 4 : Configuration de Base

```markdown
# Configuration de Base

## Configuration Minimale

### 1. Docker

```bash
# Vérifier Docker
docker --version
docker-compose --version
```

### 2. Démarrer le Cluster

```bash
cd docker
docker-compose -f docker-compose-opensource.yml up -d
```

### 3. Accéder aux Services

- **Grafana** : http://localhost:3000
- **Prometheus** : http://localhost:9090
- **InfluxDB** : http://localhost:8086

## Configuration Production

Voir [docs/GUIDE_DEPLOIEMENT_PRODUCTION.md](../docs/GUIDE_DEPLOIEMENT_PRODUCTION.md)
```

---

## Page 5 : Dépannage Rapide

```markdown
# Dépannage Rapide

## Problèmes Courants

### Conteneurs ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs

# Redémarrer
docker-compose restart
```

### Port déjà utilisé

```bash
# Trouver le processus
sudo lsof -i :3000

# Arrêter le processus
sudo kill <PID>
```

### Erreur de permissions

```bash
# Vérifier les permissions
ls -la docker/

# Corriger si nécessaire
chmod +x install-all.sh
```

## Documentation Complète

Voir [docs/GUIDE_TROUBLESHOOTING.md](../docs/GUIDE_TROUBLESHOOTING.md)
```

---

## Page 6 : Astuces

```markdown
# Astuces et Trucs

## Optimisations

### Accélérer le démarrage

```bash
# Pré-charger les images
docker-compose pull
```

### Réduire l'utilisation mémoire

```bash
# Limiter les ressources dans docker-compose.prod.yml
```

## Commandes Utiles

### Voir les logs en temps réel

```bash
docker-compose logs -f
```

### Redémarrer un service spécifique

```bash
docker-compose restart grafana
```

## Partagez vos Astuces !

N'hésitez pas à ajouter vos propres astuces ici !
```

---

## Page 7 : Cas d'Usage

```markdown
# Cas d'Usage

## Exemples d'Utilisation

### Cluster de Calcul Scientifique

- Applications : GROMACS, OpenFOAM, Quantum ESPRESSO
- Stockage : BeeGFS
- Scheduler : Slurm

### Cluster Big Data

- Applications : Apache Spark, Hadoop
- Stockage : Ceph
- Notebooks : JupyterHub

## Partagez votre Cas d'Usage !

Décrivez comment vous utilisez le cluster HPC.
```
