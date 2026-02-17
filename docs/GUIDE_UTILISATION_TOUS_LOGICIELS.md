# 📖 GUIDE D'UTILISATION - TOUS LES LOGICIELS
## Comment Utiliser Chaque Logiciel Installé

**Classification**: Guide Utilisateur Complet  
**Public**: Utilisateurs / Administrateurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Slurm - Gestion des Jobs](#1-slurm)
2. [Applications Scientifiques](#2-applications-scientifiques)
3. [Bases de Données](#3-bases-de-données)
4. [Monitoring](#4-monitoring)
5. [Stockage](#5-stockage)
6. [Remote Graphics](#6-remote-graphics)
7. [Gestion de Packages](#7-gestion-de-packages)
8. [Sécurité](#8-sécurité)

---

## 1. Slurm - Gestion des Jobs

### 1.1 Soumettre un Job

**Job simple** :
```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=01:00:00
#SBATCH --output=myjob.%j.out
#SBATCH --error=myjob.%j.err

# Votre code ici
echo "Hello from Slurm"
```

**Soumission** :
```bash
sbatch job.sh
```

**Job MPI** :
```bash
#!/bin/bash
#SBATCH --job-name=mpi-job
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=02:00:00

module load openmpi/4.1.5
mpirun -np 32 my_mpi_program
```

**Job GPU** :
```bash
#!/bin/bash
#SBATCH --job-name=gpu-job
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --time=01:00:00

module load cuda/12.0
./my_gpu_program
```

### 1.2 Voir les Jobs

```bash
# Tous les jobs
squeue

# Mes jobs
squeue -u $USER

# Job spécifique
squeue -j JOBID

# Format détaillé
squeue -l
```

### 1.3 Voir les Nœuds

```bash
# Tous les nœuds
sinfo

# Format détaillé
sinfo -N -l

# Par partition
sinfo -p normal
```

### 1.4 Annuler un Job

```bash
# Annuler un job
scancel JOBID

# Annuler tous mes jobs
scancel -u $USER

# Annuler par nom
scancel --name=myjob
```

### 1.5 Historique

```bash
# Tous les jobs
sacct

# Job spécifique
sacct -j JOBID

# Mes jobs
sacct -u $USER

# Format détaillé
sacct -l
```

---

## 2. Applications Scientifiques

### 2.1 GROMACS

**Installation** :
```bash
./scripts/applications/install-gromacs.sh
```

**Utilisation** :
```bash
# Job Slurm
#!/bin/bash
#SBATCH --job-name=gromacs
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=01:00:00

module load gromacs/2023.2

# Préparation
gmx grompp -f md.mdp -c conf.gro -p topol.top -o topol.tpr

# Exécution
gmx mdrun -s topol.tpr -v
```

**Commandes utiles** :
```bash
gmx --help
gmx pdb2gmx -f protein.pdb
gmx editconf -f conf.gro -o newbox.gro
```

---

### 2.2 OpenFOAM

**Installation** :
```bash
./scripts/applications/install-openfoam.sh
```

**Utilisation** :
```bash
# Job Slurm
#!/bin/bash
#SBATCH --job-name=openfoam
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=02:00:00

module load openfoam/2312

# Source environment
source $FOAM_BASH

# Exécution
mpirun -np 32 simpleFoam -parallel
```

**Commandes utiles** :
```bash
blockMesh
checkMesh
simpleFoam
paraFoam
```

---

### 2.3 Quantum ESPRESSO

**Installation** :
```bash
./scripts/applications/install-quantum-espresso.sh
```

**Utilisation** :
```bash
# Job Slurm
#!/bin/bash
#SBATCH --job-name=qe
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=01:00:00

module load quantum-espresso/7.2

# Exécution
mpirun -np 32 pw.x < input.in > output.out
```

**Commandes disponibles** :
```bash
pw.x      # Calcul électronique
ph.x      # Phonons
cp.x      # Car-Parrinello
neb.x     # Nudged Elastic Band
```

---

### 2.4 ParaView

**Installation** :
```bash
./scripts/applications/install-paraview.sh
```

**Utilisation** :
```bash
# Via X2Go (remote graphics)
paraview

# Ou batch
pvpython script.py
```

---

## 3. Bases de Données

### 3.1 PostgreSQL

**Installation** :
```bash
./scripts/database/install-postgresql.sh
```

**Utilisation** :
```bash
# Connexion
psql -U slurm -d slurm_acct_db

# Requêtes
SELECT * FROM job_table;
SELECT * FROM job_table WHERE user_name = 'jdoe';

# Créer table
CREATE TABLE mytable (id INT, name VARCHAR(50));

# Insérer
INSERT INTO mytable VALUES (1, 'test');
```

---

### 3.2 MongoDB

**Installation** :
```bash
./scripts/database/install-mongodb.sh
```

**Utilisation** :
```bash
# Connexion
mongo

# Requêtes
db.collection.find()
db.collection.insert({name: "test"})
db.collection.update({name: "test"}, {$set: {value: 123}})
```

---

## 4. Monitoring

### 4.1 Prometheus

**Accès** :
```bash
http://localhost:9090
```

**Requêtes PromQL** :
```promql
# Tous les targets
up

# CPU idle
node_cpu_seconds_total{mode="idle"}

# Mémoire disponible
node_memory_MemAvailable_bytes

# Taux réseau
rate(node_network_receive_bytes_total[5m])
```

---

### 4.2 Grafana

**Accès** :
```bash
http://localhost:3000
# Login: admin / admin
```

**Dashboards disponibles** :
- HPC Cluster Overview
- CPU/Memory by Node
- Network I/O
- Slurm Jobs
- Et 50+ autres...

**Créer un dashboard** :
1. Créer → Dashboard
2. Ajouter panel
3. Requête PromQL
4. Sauvegarder

---

## 5. Stockage

### 5.1 BeeGFS

**Utilisation** :
```bash
# Vérifier montage
df -h /mnt/beegfs

# Écrire
echo "test" > /mnt/beegfs/test.txt

# Lire
cat /mnt/beegfs/test.txt

# Performance test
dd if=/dev/zero of=/mnt/beegfs/test bs=1M count=1000
```

---

## 6. Remote Graphics

### 6.1 X2Go

**Utilisation** :
1. Télécharger X2Go Client
2. Nouvelle session
3. Serveur : frontal-01
4. Utilisateur : votre utilisateur
5. Session : XFCE
6. Connexion

**Lancer application** :
```bash
# Dans la session X2Go
paraview
```

---

## 7. Gestion de Packages

### 7.1 Spack

**Utilisation** :
```bash
# Installer
spack install openmpi@4.1.5

# Charger
spack load openmpi

# Environnement
spack env create myenv
spack env activate myenv
spack add openmpi hdf5
spack install
```

---

## 8. Sécurité

### 8.1 Vault

**Utilisation** :
```bash
# Initialiser
vault operator init

# Stocker secret
vault kv put secret/myapp password=secret123

# Lire secret
vault kv get secret/myapp
```

---

## 📚 Documentation Complémentaire

- `docs/GUIDE_LANCEMENT_JOBS.md` - Guide complet Slurm
- `docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md` - Applications scientifiques
- `docs/GUIDE_MONITORING_COMPLET.md` - Monitoring complet

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
