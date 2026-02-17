# Guide de Lancement de Jobs avec FreeIPA
## Slurm, MATLAB, OpenM++, et Applications Graphiques

**Classification**: Documentation Utilisateur  
**Public**: Étudiants Master / Ingénieurs  
**Version**: 2.0 (FreeIPA)

---

## 📋 Table des Matières

1. [Prérequis](#prérequis)
2. [Authentification FreeIPA](#authentification-freeipa)
3. [Soumission de Jobs Slurm](#soumission-de-jobs-slurm)
4. [Jobs MATLAB](#jobs-matlab)
5. [Jobs OpenM++](#jobs-openm)
6. [Applications Graphiques (Exceed TurboX)](#applications-graphiques-exceed-turbox)
7. [Monitoring des Jobs](#monitoring-des-jobs)
8. [Dépannage](#dépannage)

---

## ✅ Prérequis

### 1. Authentification FreeIPA

**Obtenir un compte** :
- Contactez l'administrateur pour créer votre compte FreeIPA
- Votre compte sera automatiquement créé dans LDAP et Kerberos

**Première connexion** :
```bash
# Connexion SSH
ssh jdoe@frontal-01

# Obtenir un ticket Kerberos (via FreeIPA)
kinit jdoe@CLUSTER.LOCAL
# Entrer votre mot de passe FreeIPA
```

### 2. Vérification de l'Environnement

```bash
# Vérifier que vous êtes connecté
whoami
hostname

# Vérifier votre ticket FreeIPA
klist

# Vérifier l'accès au cluster
sinfo

# Vérifier votre quota GPFS
mmlsquota -u $USER /gpfs/gpfsfs1
```

---

## 🔐 Authentification FreeIPA

### Connexion avec FreeIPA

**Méthode 1 : SSH avec SSO (Recommandé)**

```bash
# Obtenir un ticket Kerberos
kinit jdoe@CLUSTER.LOCAL
# Entrer votre mot de passe FreeIPA

# Connexion SSH sans mot de passe (SSO)
ssh jdoe@node-01
# Pas de mot de passe demandé si ticket valide
```

**Méthode 2 : SSH avec mot de passe FreeIPA**

```bash
# Connexion directe
ssh jdoe@node-01
# Entrer votre mot de passe FreeIPA
```

### Gestion des Tickets

```bash
# Vérifier les tickets actifs
klist

# Vérifier les détails
klist -v

# Renouveler un ticket
kinit -R

# Détruire et recréer
kdestroy
kinit jdoe@CLUSTER.LOCAL
```

### Interface Web FreeIPA

1. **Accès** : `https://ipa.cluster.local` ou `https://frontal-01`
2. **Login** : Votre username FreeIPA
3. **Password** : Votre mot de passe FreeIPA
4. **Fonctionnalités** :
   - Voir vos informations
   - Changer votre mot de passe
   - Voir vos groupes
   - Gérer vos clés SSH

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
echo "User: $USER (authenticated via FreeIPA)"

# Exemple: compilation et exécution
gcc -o myprogram myprogram.c
srun ./myprogram
```

**Soumission** :
```bash
# S'assurer d'avoir un ticket valide
kinit jdoe@CLUSTER.LOCAL

# Soumettre le job
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

## 📊 Jobs MATLAB

### MATLAB en Mode Batch

**Script** (`matlab_job.sh`) :
```bash
#!/bin/bash
#SBATCH --job-name=matlab_batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=02:00:00
#SBATCH --partition=normal

# Charger MATLAB
module load matlab/R2023b

# Exécuter le script MATLAB
matlab -nodisplay -nosplash -r "run('my_script.m'); exit"
```

### MATLAB avec Parallel Computing Toolbox

**Script MATLAB** (`my_parallel_script.m`) :
```matlab
% Créer un pool de workers
parpool('local', 16);

% Code parallèle
parfor i = 1:100
    result(i) = compute(i);
end

% Fermer le pool
delete(gcp('nocreate'));
```

**Script Slurm** :
```bash
#!/bin/bash
#SBATCH --job-name=matlab_parallel
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=04:00:00

module load matlab/R2023b
matlab -nodisplay -r "my_parallel_script; exit"
```

### MATLAB Distributed Computing Server (MDCS)

Pour utiliser plusieurs nœuds avec MATLAB :

```bash
#!/bin/bash
#SBATCH --job-name=matlab_dcs
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=08:00:00

module load matlab/R2023b

# Créer un cluster profile pour Slurm
matlab -nodisplay -r "
    profile = parallel.cluster.Generic;
    profile.JobStorageLocation = '/gpfs/gpfsfs1/matlab/jobs';
    profile.HasSharedFilesystem = true;
    profile.NumWorkers = 32;
    saveProfile(profile, 'slurm-cluster');
    exit
"

# Utiliser le cluster
matlab -nodisplay -r "
    cluster = parcluster('slurm-cluster');
    job = batch(cluster, @my_function, 1, {arg1, arg2});
    wait(job);
    results = fetchOutputs(job);
    exit
"
```

**Intégration FreeIPA** :
- Authentification via FreeIPA
- SSO avec tickets Kerberos

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

## 🖥️ Applications Graphiques (Exceed TurboX)

### Connexion à Exceed TurboX avec FreeIPA

**Sur Windows** :
1. Installer le client Exceed TurboX
2. Lancer ETX Client
3. Se connecter à `frontal-01:9443`
4. **Authentification FreeIPA** : Utiliser votre username et mot de passe FreeIPA
5. SSO automatique si ticket Kerberos valide

**Sur Linux** :
```bash
# Obtenir un ticket FreeIPA
kinit jdoe@CLUSTER.LOCAL

# Lancer le client ETX
etx-client connect frontal-01:9443
# SSO automatique avec ticket Kerberos
```

### Lancer MATLAB GUI

```bash
# Dans la session ETX
module load matlab/R2023b
matlab -desktop
```

### Lancer ParaView

```bash
# Dans la session ETX
module load paraview/5.11.0
paraview
```

### Lancer Jupyter avec Interface Graphique

```bash
# Dans la session ETX
jupyter lab --no-browser
# Ouvrir l'URL dans le navigateur du client
```

**Intégration FreeIPA** :
- Authentification via FreeIPA
- SSO automatique avec tickets Kerberos

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

### Problèmes d'Authentification FreeIPA

```bash
# Vérifier le ticket Kerberos
klist

# Renouveler
kinit -R

# Vérifier l'utilisateur dans FreeIPA
ipa user-find jdoe

# Vérifier l'état du client FreeIPA
ipa-client-status

# Réinitialiser le client (si nécessaire)
ipa-client-install --uninstall
ipa-client-install ...
```

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

### Problèmes de Fichiers

```bash
# Vérifier les permissions
ls -la /gpfs/gpfsfs1/home/$USER

# Vérifier le quota
mmlsquota -u $USER /gpfs/gpfsfs1

# Vérifier l'espace disponible
df -h /gpfs/gpfsfs1
```

### Problèmes FreeIPA

```bash
# Vérifier l'état du serveur
systemctl status ipa
ipa ping

# Vérifier les logs
tail -f /var/log/ipaserver-install.log
tail -f /var/log/ipaclient-install.log

# Vérifier la connectivité
ldapsearch -x -b "dc=cluster,dc=local" -s base
```

---

## 📚 Exemples Complets avec FreeIPA

### Exemple 1: Job Python avec Authentification FreeIPA

```bash
#!/bin/bash
#SBATCH --job-name=python_freeipa
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=01:00:00

# Le ticket FreeIPA est automatiquement utilisé
module load python/3.11
module load numpy/1.24.0

python my_script.py
```

### Exemple 2: Job avec SSO FreeIPA

```bash
# Obtenir un ticket avant la soumission
kinit jdoe@CLUSTER.LOCAL

# Soumettre le job (SSO automatique)
sbatch myjob.sh

# Le job utilisera automatiquement le ticket pour les accès réseau
```

---

## 📚 Ressources

- **FreeIPA**: https://www.freeipa.org/page/Documentation
- **Slurm**: https://slurm.schedmd.com/documentation.html
- **MATLAB DCS**: https://www.mathworks.com/help/parallel-computing/
- **OpenM++**: https://github.com/openmpp/openmpp
- **Exceed TurboX**: Documentation OpenText

---

**Version**: 2.0 (FreeIPA)  
**Dernière mise à jour**: 2024
