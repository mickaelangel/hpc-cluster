# Guide Utilisateur - Cluster HPC
## Guide pour les Utilisateurs Finaux

**Classification**: Documentation Utilisateur  
**Public**: Utilisateurs du Cluster  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Premiers Pas](#premiers-pas)
2. [Authentification](#authentification)
3. [Soumission de Jobs](#soumission-de-jobs)
4. [Gestion des Fichiers](#gestion-des-fichiers)
5. [Exemples de Jobs](#exemples-de-jobs)
6. [Bonnes Pratiques](#bonnes-pratiques)

---

## 🚀 Premiers Pas

### Connexion au Cluster

```bash
# Connexion SSH
ssh votre-utilisateur@frontal-01.cluster.local

# Ou directement sur un nœud de calcul
ssh votre-utilisateur@node-01.cluster.local
```

### Vérifier Votre Compte

```bash
# Vérifier votre identité
whoami
id

# Vérifier votre quota
quota -s
```

---

## 🔐 Authentification

### Avec LDAP + Kerberos

```bash
# Obtenir un ticket Kerberos
kinit votre-utilisateur@CLUSTER.LOCAL
# Entrer votre mot de passe

# Vérifier le ticket
klist

# Le ticket permet l'authentification SSO (pas besoin de mot de passe pour SSH)
```

### Avec FreeIPA

```bash
# Obtenir un ticket Kerberos
kinit votre-utilisateur@CLUSTER.LOCAL
# Entrer votre mot de passe

# Vérifier le ticket
klist
```

---

## ⚡ Soumission de Jobs

### Job Simple

**Fichier** : `mon-job.sh`
```bash
#!/bin/bash
#SBATCH --job-name=mon-job
#SBATCH --output=mon-job-%j.out
#SBATCH --error=mon-job-%j.err
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

echo "Bonjour depuis le cluster HPC!"
hostname
date
```

**Soumission** :
```bash
sbatch mon-job.sh
```

**Vérification** :
```bash
squeue -u $USER
```

### Job avec Plusieurs Cœurs

```bash
#!/bin/bash
#SBATCH --job-name=job-parallele
#SBATCH --output=job-parallele-%j.out
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1

# Job utilisant 4 cœurs
./mon-programme-parallele
```

### Job MPI

```bash
#!/bin/bash
#SBATCH --job-name=job-mpi
#SBATCH --output=job-mpi-%j.out
#SBATCH --time=4:00:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4

# Job MPI sur 2 nœuds, 4 processus par nœud
srun ./mon-programme-mpi
```

---

## 📁 Gestion des Fichiers

### Espace de Travail

```bash
# Votre répertoire home
cd ~
pwd  # /home/votre-utilisateur

# Espace de travail partagé (GPFS)
cd /gpfs/home/votre-utilisateur
```

### Transfert de Fichiers

**Depuis votre machine locale** :
```bash
# SCP
scp fichier.txt votre-utilisateur@frontal-01:/home/votre-utilisateur/

# SFTP
sftp votre-utilisateur@frontal-01
put fichier.txt
```

### Quotas

```bash
# Vérifier votre quota
quota -s

# Vérifier l'utilisation
du -sh ~
du -sh /gpfs/home/votre-utilisateur
```

---

## 💡 Exemples de Jobs

### Job Python

```bash
#!/bin/bash
#SBATCH --job-name=python-job
#SBATCH --output=python-%j.out
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

# Charger l'environnement Python
module load python/3.9

# Exécuter le script
python mon-script.py
```

### Job MATLAB

```bash
#!/bin/bash
#SBATCH --job-name=matlab-job
#SBATCH --output=matlab-%j.out
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

# Charger MATLAB
module load matlab

# Exécuter le script MATLAB
matlab -batch "run('mon-script.m')"
```

### Job avec Array

```bash
#!/bin/bash
#SBATCH --job-name=array-job
#SBATCH --output=array-%A-%a.out
#SBATCH --array=1-10
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

# Job array : 10 jobs identiques avec paramètres différents
echo "Job $SLURM_ARRAY_JOB_ID, Task $SLURM_ARRAY_TASK_ID"
./mon-programme --param $SLURM_ARRAY_TASK_ID
```

---

## ✅ Bonnes Pratiques

### Avant de Soumettre un Job

1. **Tester localement** : Vérifier que votre code fonctionne
2. **Estimer le temps** : Utiliser `--time` approprié
3. **Vérifier les ressources** : CPU, mémoire, GPU si nécessaire
4. **Vérifier les fichiers** : S'assurer que tous les fichiers sont accessibles

### Pendant l'Exécution

1. **Surveiller** : Utiliser `squeue` pour vérifier l'état
2. **Consulter les logs** : Vérifier les fichiers `.out` et `.err`
3. **Ne pas surcharger** : Ne pas soumettre trop de jobs simultanément

### Après l'Exécution

1. **Vérifier les résultats** : S'assurer que le job a réussi
2. **Nettoyer** : Supprimer les fichiers temporaires
3. **Archiver** : Sauvegarder les résultats importants

---

## 🔧 Commandes Utiles

### Slurm

```bash
# Soumettre un job
sbatch mon-job.sh

# Vérifier l'état
squeue -u $USER

# Annuler un job
scancel <job-id>

# Détails d'un job
scontrol show job <job-id>

# Historique
sacct -u $USER
```

### Fichiers

```bash
# Taille des fichiers
du -sh *

# Rechercher des fichiers
find . -name "*.out"

# Compresser
tar -czf archive.tar.gz dossier/
```

---

## 📚 Ressources

- **Guide Lancement Jobs** : `docs/GUIDE_LANCEMENT_JOBS.md`
- **Guide Authentification** : `docs/GUIDE_AUTHENTIFICATION.md`
- **Support** : contact-admin@cluster.local

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
