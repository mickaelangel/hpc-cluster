# Guide Utilisateur Avancé - Cluster HPC
## Guide Complet pour Utilisateurs Expérimentés

**Classification**: Documentation Utilisateur  
**Public**: Utilisateurs Expérimentés  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Optimisation Jobs](#optimisation-jobs)
2. [Gestion Avancée Fichiers](#gestion-avancée-fichiers)
3. [Performance Tuning](#performance-tuning)
4. [Debugging Avancé](#debugging-avancé)
5. [Scripts Personnalisés](#scripts-personnalisés)
6. [Intégration Applications](#intégration-applications)

---

## 🚀 Optimisation Jobs

### Allocation Ressources Optimale

**GROMACS** :
```bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
```

**OpenFOAM** :
```bash
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=2
```

### Utilisation MPI

```bash
# Compilation avec MPI
mpicc -o mon_programme mon_programme.c

# Exécution
srun --mpi=pmix ./mon_programme
```

---

## 💾 Gestion Avancée Fichiers

### Quotas Utilisateurs

```bash
# Vérifier quota
quota -s

# Vérifier utilisation
du -sh ~/
```

### Synchronisation Fichiers

```bash
# rsync entre nœuds
rsync -avz /path/local/ compute-01:/path/remote/
```

---

## ⚡ Performance Tuning

### Variables d'Environnement

```bash
export OMP_NUM_THREADS=24
export MKL_NUM_THREADS=24
export NUMEXPR_NUM_THREADS=24
```

### Profiling

```bash
# Avec gprof
gcc -pg mon_programme.c
./mon_programme
gprof mon_programme gmon.out
```

---

## 🔧 Debugging Avancé

### Debug MPI

```bash
# Avec gdb
srun --mpi=pmix gdb ./mon_programme

# Avec valgrind
srun --mpi=pmix valgrind ./mon_programme
```

### Logs Détaillés

```bash
# Activer logs détaillés
export SLURM_DEBUG=1
sbatch mon_job.sh
```

---

## 📚 Documentation Complémentaire

- `GUIDE_UTILISATEUR.md` - Guide utilisateur de base
- `GUIDE_DEVELOPPEUR.md` - Guide développeur
- `GUIDE_LANCEMENT_JOBS.md` - Lancement jobs

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
