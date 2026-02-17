# Guide de Lancement de Jobs sur le Cluster HPC
## Slurm, GROMACS, OpenFOAM, Quantum ESPRESSO, ParaView, OpenM++, et Applications Graphiques

**Classification**: Documentation Utilisateur  
**Public**: Étudiants Master / Ingénieurs  
**Version**: 1.0

---

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Authentification](#authentification)
3. [Soumission de Jobs Slurm](#soumission-de-jobs-slurm)
4. [Jobs GROMACS](#jobs-gromacs-simulation-moléculaire)
5. [Jobs OpenFOAM](#jobs-openfoam-cfd)
6. [Jobs Quantum ESPRESSO](#jobs-quantum-espresso-calculs-quantiques)
7. [Jobs ParaView](#jobs-paraview-visualisation)
5. [Jobs OpenM++](#jobs-openm)
6. [Applications Graphiques (Exceed TurboX)](#applications-graphiques-exceed-turbox)
7. [Monitoring des Jobs](#monitoring-des-jobs)
8. [Dépannage](#dépannage)

---

## ✅ Prérequis

### 1. Authentification

**Obtenir un compte** :
- Contactez l'administrateur pour créer votre compte LDAP
- Votre compte sera automatiquement synchronisé avec Kerberos

**Première connexion** :
```bash
# Connexion SSH
ssh jdoe@frontal-01

# Obtenir un ticket Kerberos (si configuré)
kinit jdoe@CLUSTER.LOCAL
# Entrer votre mot de passe
```

### 2. Vérification de l'Environnement

```bash
# Vérifier que vous êtes connecté
whoami
hostname

# Vérifier l'accès au cluster
sinfo

# Vérifier votre quota GPFS
mmlsquota -u $USER /gpfs/gpfsfs1
```

---

## 🔐 Authentification

### Connexion avec LDAP/Kerberos

```bash
# Méthode 1: SSH direct (si Kerberos configuré)
ssh jdoe@node-01
# Pas de mot de passe si ticket valide

# Méthode 2: SSH avec mot de passe LDAP
ssh jdoe@node-01
# Entrer votre mot de passe LDAP

# Vérifier votre ticket Kerberos
klist
```

### Expiration des Tickets

```bash
# Vérifier l'expiration
klist -v

# Renouveler
kinit -R

# Détruire et recréer
kdestroy
kinit jdoe@CLUSTER.LOCAL
```

---

## ⚡ Soumission de Jobs Slurm

### Job Simple

**Créer un script** (`myjob.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=01:00:00
#SBATCH --partition=normal
#SBATCH --output=myjob-%j.out
#SBATCH --error=myjob-%j.err

# Votre code ici
echo "Hello from job $SLURM_JOB_ID"
echo "Running on node: $SLURM_NODELIST"
echo "Using $SLURM_CPUS_PER_TASK CPUs"

# Exemple: compilation et exécution
gcc -o myprogram myprogram.c
srun ./myprogram
```

**Soumission** :
```bash
sbatch myjob.sh
```

**Vérification** :
```bash
squeue -u $USER
```

### Job MPI (Multi-nœuds)

```bash
#!/bin/bash
#SBATCH --job-name=mpi_job
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=02:00:00
#SBATCH --partition=normal

# Charger OpenMPI
module load openmpi/4.1.5

# Lancer avec MPI
mpirun -np 32 ./my_mpi_program
```

### Job avec GPU

```bash
#!/bin/bash
#SBATCH --job-name=gpu_job
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:2
#SBATCH --time=04:00:00
#SBATCH --partition=gpu

# Votre code GPU
./my_gpu_program
```

### Commandes Utiles

```bash
# Voir la file d'attente
squeue

# Voir vos jobs
squeue -u $USER

# Annuler un job
scancel <job_id>

# Voir les détails d'un job
scontrol show job <job_id>

# Voir l'état des nœuds
sinfo

# Voir l'historique de vos jobs
sacct -u $USER
```

---

## 🔬 Jobs GROMACS (Simulation Moléculaire)

### GROMACS en Mode Batch

**Script** (`gromacs_job.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=gromacs-md
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=4:00:00
#SBATCH --partition=normal

# Charger GROMACS
module load gromacs/2023.2
module load openmpi/4.1.5

# Préparation du système
gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr

# Exécution MD avec MPI
srun gmx_mpi mdrun -deffnm nvt -v
```

**Voir** : `examples/jobs/exemple-gromacs.sh`

---

## 🌊 Jobs OpenFOAM (CFD)

### OpenFOAM en Mode Batch

**Script** (`openfoam_job.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=openfoam-cfd
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=6:00:00
#SBATCH --partition=normal

# Charger OpenFOAM
module load openfoam/2312
source ${FOAM_INST_DIR}/etc/bashrc

# Préparation
blockMesh
checkMesh

# Résolution
srun simpleFoam -parallel
```

**Voir** : `examples/jobs/exemple-openfoam.sh`

---

## ⚛️ Jobs Quantum ESPRESSO (Calculs Quantiques)

### Quantum ESPRESSO en Mode Batch

**Script** (`qe_job.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=qe-dft
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --time=8:00:00
#SBATCH --partition=normal

# Charger Quantum ESPRESSO
module load quantum-espresso/7.2
module load openmpi/4.1.5

# Calcul SCF
srun pw.x < scf.in > scf.out

# Calcul Bands
srun pw.x < bands.in > bands.out
```

**Voir** : `examples/jobs/exemple-quantum-espresso.sh`

---

## 📊 Jobs ParaView (Visualisation)

### ParaView en Mode Batch

**Script** (`paraview_job.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=paraview-viz
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=2:00:00
#SBATCH --partition=normal

# Charger ParaView
module load paraview/5.11.2

# Visualisation batch
pvpython my_visualization.py
```

**Voir** : `examples/jobs/exemple-paraview.sh`

---

## 🔬 Jobs OpenM++

### Configuration OpenM++

```bash
# Charger OpenM++
module load openm/1.15.2

# Vérifier l'installation
omc --version
```

### Job OpenM++ Simple

```bash
#!/bin/bash
#SBATCH --job-name=openm_simulation
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=06:00:00
#SBATCH --partition=normal

module load openm/1.15.2

# Lancer une simulation
omc -m RiskPaths -p "BaseCase" -o /gpfs/gpfsfs1/results/
```

### Job OpenM++ Multi-nœuds

```bash
#!/bin/bash
#SBATCH --job-name=openm_parallel
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00

module load openm/1.15.2

# Lancer plusieurs simulations en parallèle
srun omc -m RiskPaths -p "Scenario1" -o /gpfs/gpfsfs1/results/scenario1/ &
srun omc -m RiskPaths -p "Scenario2" -o /gpfs/gpfsfs1/results/scenario2/ &
srun omc -m RiskPaths -p "Scenario3" -o /gpfs/gpfsfs1/results/scenario3/ &
wait
```

---

## 🖥️ Applications Graphiques (X2Go / NoMachine)

### Connexion via X2Go (SSH X11 Forwarding)

**Sur Windows** :
1. Installer Xming ou VcXsrv (serveur X11)
2. Configurer SSH avec X11 forwarding
3. Se connecter via SSH avec `-X` option

**Sur Linux/Mac** :
```bash
# Connexion SSH avec X11 forwarding
ssh -X user@frontal-01

# Lancer applications graphiques
paraview
```

### Connexion via NoMachine

**Sur Windows/Linux/Mac** :
1. Installer client NoMachine
2. Se connecter à `frontal-01:4000`
3. Authentification avec LDAP/Kerberos

### Lancer ParaView

```bash
# Dans la session X2Go ou NoMachine
module load paraview/5.11.2
paraview
```

### Lancer GROMACS (si GUI disponible)

```bash
# Dans la session X2Go ou NoMachine
module load gromacs/2023.2
gmx (avec interface graphique si disponible)
```

### Lancer Jupyter avec Interface Graphique

```bash
# Dans la session X2Go ou NoMachine
jupyter lab --no-browser
# Ouvrir l'URL dans le navigateur du client
```

---

## 📈 Monitoring des Jobs

### Via Slurm

```bash
# État de vos jobs
squeue -u $USER

# Détails d'un job
scontrol show job <job_id>

# Historique
sacct -u $USER --format=JobID,JobName,State,ExitCode,Elapsed

# Utilisation des ressources
sstat -j <job_id> --format=MaxRSS,MaxVMSize,CPU
```

### Via Grafana

1. Accéder à `http://frontal-01:3000`
2. Naviguer vers le dashboard "Slurm Jobs"
3. Voir les métriques en temps réel

### Via Prometheus

```bash
# Requête PromQL
curl 'http://frontal-01:9090/api/v1/query?query=slurm_jobs_running'
```

---

## 🔧 Dépannage

### Job en Attente

```bash
# Voir pourquoi le job est en attente
scontrol show job <job_id>

# Vérifier les ressources disponibles
sinfo

# Vérifier les partitions
sinfo -o "%P %a %l %D %t %N"
```

### Job Échoué

```bash
# Voir les logs
cat myjob-<job_id>.err
cat myjob-<job_id>.out

# Voir les détails
scontrol show job <job_id>

# Vérifier les ressources utilisées
sstat -j <job_id>
```

### Problèmes d'Authentification

```bash
# Vérifier le ticket Kerberos
klist

# Renouveler
kinit -R

# Vérifier l'accès LDAP
ldapwhoami -x -H ldap://frontal-01
```

### Problèmes de Fichiers

```bash
# Vérifier les permissions
ls -la /gpfs/gpfsfs1/home/$USER

# Vérifier le quota
mmlsquota -u $USER /gpfs/gpfsfs1

# Vérifier l'espace disponible
df -h /gpfs/gpfsfs1
```

---

## 📚 Exemples Complets

### Exemple 1: Job Python avec NumPy

```bash
#!/bin/bash
#SBATCH --job-name=python_numpy
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=01:00:00

module load python/3.11
module load numpy/1.24.0

python my_script.py
```

### Exemple 2: Job R avec Parallel

```bash
#!/bin/bash
#SBATCH --job-name=r_parallel
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=02:00:00

module load r/4.3.0

Rscript my_parallel_script.R
```

### Exemple 3: Job avec Spack

```bash
#!/bin/bash
#SBATCH --job-name=spack_job
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=04:00:00

. /opt/spack/share/spack/setup-env.sh
spack load hdf5@1.14.0
spack load openmpi@4.1.5

mpirun -np 8 ./my_program
```

---

## 📚 Ressources

- **Slurm**: https://slurm.schedmd.com/documentation.html
- **MATLAB DCS**: https://www.mathworks.com/help/parallel-computing/
- **OpenM++**: https://github.com/openmpp/openmpp
- **Exceed TurboX**: Documentation OpenText

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
