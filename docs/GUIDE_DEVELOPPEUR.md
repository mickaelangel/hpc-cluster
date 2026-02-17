# Guide Développeur - Cluster HPC
## Guide pour les Développeurs d'Applications

**Classification**: Documentation Technique  
**Public**: Développeurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Environnement de Développement](#environnement-de-développement)
2. [Compilation](#compilation)
3. [Débogage](#débogage)
4. [Optimisation](#optimisation)
5. [Intégration Continue](#intégration-continue)

---

## 🛠️ Environnement de Développement

### Modules Disponibles

```bash
# Lister les modules disponibles
module avail

# Charger un module
module load gcc/11
module load openmpi/4.1
module load python/3.9

# Voir les modules chargés
module list
```

### Environnements Virtuels Python

```bash
# Créer un environnement virtuel
python -m venv mon-env
source mon-env/bin/activate

# Installer des packages
pip install numpy scipy matplotlib

# Utiliser Spack pour packages scientifiques
spack install gcc@11.2.0
spack load gcc@11.2.0
```

---

## 🔨 Compilation

### C/C++

```bash
# Compilation simple
gcc -o mon-programme mon-programme.c

# Compilation optimisée
gcc -O3 -march=native -o mon-programme mon-programme.c

# Compilation avec OpenMP
gcc -fopenmp -o mon-programme-omp mon-programme-omp.c
```

### Fortran

```bash
# Compilation Fortran
gfortran -o mon-programme mon-programme.f90

# Compilation optimisée
gfortran -O3 -march=native -o mon-programme mon-programme.f90
```

### MPI

```bash
# Compilation MPI C
mpicc -o mon-programme-mpi mon-programme-mpi.c

# Compilation MPI Fortran
mpifort -o mon-programme-mpi mon-programme-mpi.f90
```

---

## 🐛 Débogage

### GDB

```bash
# Compiler avec symboles de débogage
gcc -g -o mon-programme mon-programme.c

# Lancer GDB
gdb ./mon-programme

# Dans GDB
(gdb) run
(gdb) break main
(gdb) continue
(gdb) print variable
(gdb) quit
```

### Valgrind

```bash
# Détecter les fuites mémoire
valgrind --leak-check=full ./mon-programme

# Profiler
valgrind --tool=callgrind ./mon-programme
```

---

## ⚡ Optimisation

### Profiling

```bash
# Profiling avec gprof
gcc -pg -o mon-programme mon-programme.c
./mon-programme
gprof mon-programme gmon.out > profile.txt

# Profiling avec perf
perf record ./mon-programme
perf report
```

### Optimisation du Code

1. **Compiler avec optimisations** : `-O3 -march=native`
2. **Utiliser OpenMP** : Parallélisation automatique
3. **Utiliser MPI** : Parallélisation distribuée
4. **Vectorisation** : `-ftree-vectorize`

---

## 🔄 Intégration Continue

### Exemple de Pipeline CI/CD

```yaml
# .gitlab-ci.yml ou .github/workflows/ci.yml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - module load gcc
    - make

test:
  stage: test
  script:
    - sbatch test-job.sh
    - squeue -u $USER

deploy:
  stage: deploy
  script:
    - cp mon-programme /opt/cluster/bin/
```

---

## 📚 Ressources

- **Guide Utilisateur** : `docs/GUIDE_UTILISATEUR.md`
- **Guide Lancement Jobs** : `docs/GUIDE_LANCEMENT_JOBS.md`
- **Spack Documentation** : https://spack.readthedocs.io/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
