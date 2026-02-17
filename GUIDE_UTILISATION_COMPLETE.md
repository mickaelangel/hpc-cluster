# Guide d'Utilisation Complète - Cluster HPC
## Comment Utiliser le Cluster de A à Z

**Classification**: Documentation Utilisateur  
**Public**: Tous les Utilisateurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Première Connexion](#première-connexion)
2. [Soumettre un Job](#soumettre-un-job)
3. [Utiliser les Applications](#utiliser-les-applications)
4. [Gérer les Fichiers](#gérer-les-fichiers)
5. [Monitoring](#monitoring)
6. [Problèmes Courants](#problèmes-courants)

---

## 🔐 Première Connexion

### Se Connecter

```bash
# Connexion SSH
ssh user@frontal-01

# Vérifier l'accès
hostname
whoami
pwd
```

### Vérifier l'Accès au Cluster

```bash
# Voir les nœuds disponibles
sinfo

# Voir les jobs en cours
squeue

# Voir mon quota
beegfs-ctl --getquota --uid $USER
```

---

## 📝 Soumettre un Job

### Job Simple

**Créer un script** (`mon_job.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=mon-premier-job
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

echo "Bonjour depuis le cluster HPC !"
echo "Je suis sur le nœud: $(hostname)"
date
```

**Soumettre** :
```bash
sbatch mon_job.sh
```

**Voir le statut** :
```bash
squeue -u $USER
```

**Voir les résultats** :
```bash
cat slurm-*.out
```

---

### Job avec GROMACS

```bash
#!/bin/bash
#SBATCH --job-name=gromacs-md
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=4:00:00

module load gromacs/2023.2
module load openmpi/4.1.5

gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr
srun gmx_mpi mdrun -deffnm nvt -v
```

**Voir** : `examples/jobs/exemple-gromacs.sh`

---

### Job avec OpenFOAM

```bash
#!/bin/bash
#SBATCH --job-name=openfoam-cfd
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=6:00:00

module load openfoam/2312
source ${FOAM_INST_DIR}/etc/bashrc

blockMesh
checkMesh
srun simpleFoam -parallel
```

**Voir** : `examples/jobs/exemple-openfoam.sh`

---

## 💾 Gérer les Fichiers

### Espace Disponible

```bash
# Voir l'espace
df -h /mnt/beegfs

# Voir mon quota
beegfs-ctl --getquota --uid $USER
```

### Copier des Fichiers

```bash
# Depuis machine locale
scp fichier.txt user@frontal-01:/mnt/beegfs/home/$USER/

# Entre nœuds
scp fichier.txt compute-01:/mnt/beegfs/home/$USER/
```

---

## 📊 Monitoring

### Grafana

**Accès** : http://frontal-01:3000

**Login** : admin / admin (changer au premier accès)

**Dashboards** :
- Vue d'ensemble cluster
- Performance par nœud
- Jobs Slurm
- Sécurité
- Réseau

### Commandes Slurm

```bash
# Mes jobs
squeue -u $USER

# Détails d'un job
scontrol show job JOB_ID

# Annuler un job
scancel JOB_ID

# Historique
sacct -u $USER
```

---

## ❓ Problèmes Courants

### Job en Attente

**Vérifier** :
```bash
squeue -j JOB_ID -o "%.30R"
scontrol show job JOB_ID
```

**Solutions** :
- Réduire ressources demandées
- Changer de partition
- Vérifier contraintes

### Espace Disque Plein

**Vérifier** :
```bash
df -h
beegfs-ctl --getquota --uid $USER
```

**Solutions** :
- Nettoyer fichiers temporaires
- Archiver anciens résultats
- Demander augmentation quota

---

## 📚 Ressources

### Documentation

- `docs/GUIDE_UTILISATEUR.md` - Guide utilisateur détaillé
- `docs/GUIDE_LANCEMENT_JOBS.md` - Guide lancement jobs
- `examples/jobs/` - Exemples de jobs

### Support

- Documentation officielle
- Forums communautaires
- Logs : `/var/log/`

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
