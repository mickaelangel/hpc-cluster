# MATLAB est Optionnel - Alternatives Disponibles
## Guide des Alternatives à MATLAB pour le Cluster HPC

**Classification**: Documentation Technique  
**Public**: Utilisateurs du Cluster  
**Version**: 1.0  
**Date**: 2024

---

## ❓ MATLAB est-il Obligatoire ?

### ✅ **NON, MATLAB n'est PAS obligatoire !**

Le cluster HPC fonctionne **parfaitement sans MATLAB**.** MATLAB est mentionné dans `instruction.txt` comme un **logiciel optionnel** pour les utilisateurs qui en ont besoin.

---

## 🎯 Alternatives à MATLAB

### 1. 🐍 Python (Recommandé)

**Avantages** :
- ✅ **Gratuit et open-source**
- ✅ **Très populaire** en calcul scientifique
- ✅ **Bibliothèques puissantes** : NumPy, SciPy, Pandas, Matplotlib
- ✅ **Parallélisation** : multiprocessing, joblib, Dask
- ✅ **Intégration Slurm** : Parfait pour les jobs batch

**Installation** :
```bash
# Python est déjà installé sur le cluster
python3 --version

# Installer des packages via Spack ou pip
module load python/3.11
pip install numpy scipy matplotlib pandas
```

**Exemple de job Python** :
```bash
#!/bin/bash
#SBATCH --job-name=python_calc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=02:00:00

module load python/3.11
python3 my_script.py
```

**Bibliothèques équivalentes MATLAB** :
- **NumPy** ≈ MATLAB arrays
- **SciPy** ≈ MATLAB toolboxes
- **Matplotlib** ≈ MATLAB plotting
- **Pandas** ≈ MATLAB tables
- **Scikit-learn** ≈ MATLAB Machine Learning Toolbox

---

### 2. 📊 R (Statistiques)

**Avantages** :
- ✅ **Gratuit et open-source**
- ✅ **Excellent pour statistiques** et analyse de données
- ✅ **Parallélisation** : parallel, foreach, doParallel
- ✅ **Intégration Slurm** : Parfait pour les jobs batch

**Installation** :
```bash
# R est déjà installé sur le cluster
R --version

# Installer des packages
module load R/4.3
Rscript -e "install.packages('dplyr')"
```

**Exemple de job R** :
```bash
#!/bin/bash
#SBATCH --job-name=r_analysis
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=02:00:00

module load R/4.3
Rscript my_analysis.R
```

---

### 3. 🔬 OpenM++ (Simulation)

**Avantages** :
- ✅ **Gratuit et open-source**
- ✅ **Spécialisé simulation** et modélisation
- ✅ **Parallélisation** : Multi-nœuds MPI
- ✅ **Déjà installé** sur le cluster

**Installation** :
```bash
# OpenM++ est déjà installé
module load openm/1.15.2
omc --version
```

**Exemple de job OpenM++** :
```bash
#!/bin/bash
#SBATCH --job-name=openm_sim
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=04:00:00

module load openm/1.15.2
omc run my_model.xml
```

---

### 4. 🔧 Julia (Calcul Haute Performance)

**Avantages** :
- ✅ **Gratuit et open-source**
- ✅ **Performance proche de C**
- ✅ **Parallélisation native**
- ✅ **Excellent pour HPC**

**Installation** :
```bash
# Installer via Spack
module load spack
spack install julia
```

**Exemple de job Julia** :
```bash
#!/bin/bash
#SBATCH --job-name=julia_calc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=02:00:00

module load julia/1.9
julia my_script.jl
```

---

### 5. 🐘 Octave (Alternative MATLAB)

**Avantages** :
- ✅ **Gratuit et open-source**
- ✅ **Syntaxe compatible MATLAB**
- ✅ **Pas besoin de licence**
- ✅ **Parfait pour migration MATLAB → Octave**

**Installation** :
```bash
# Installer via Spack ou zypper
zypper install octave
# ou
spack install octave
```

**Exemple de job Octave** :
```bash
#!/bin/bash
#SBATCH --job-name=octave_calc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=02:00:00

module load octave/8.2
octave --no-gui my_script.m
```

**Migration MATLAB → Octave** :
- La plupart du code MATLAB fonctionne directement
- Quelques différences mineures (voir documentation Octave)

---

### 6. 🔨 C/C++/Fortran (Performance Maximale)

**Avantages** :
- ✅ **Performance maximale**
- ✅ **Parallélisation MPI/OpenMP**
- ✅ **Compilateurs disponibles** : GCC, Intel, PGI

**Installation** :
```bash
# Compilateurs déjà installés
module load gcc/13.2.0
module load openmpi/4.1.5
```

**Exemple de job C/MPI** :
```bash
#!/bin/bash
#SBATCH --job-name=mpi_calc
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=04:00:00

module load gcc/13.2.0 openmpi/4.1.5
mpicc -o my_program my_program.c
srun ./my_program
```

---

## 📊 Comparaison des Alternatives

| Outil | Gratuit | Performance | Parallélisation | Compatibilité MATLAB |
|-------|---------|-------------|-----------------|---------------------|
| **Python** | ✅ | ⭐⭐⭐⭐ | ✅ | ❌ (mais équivalent) |
| **R** | ✅ | ⭐⭐⭐ | ✅ | ❌ |
| **OpenM++** | ✅ | ⭐⭐⭐⭐ | ✅ | ❌ |
| **Julia** | ✅ | ⭐⭐⭐⭐⭐ | ✅ | ❌ |
| **Octave** | ✅ | ⭐⭐⭐ | ⚠️ | ✅ (syntaxe) |
| **C/C++/Fortran** | ✅ | ⭐⭐⭐⭐⭐ | ✅ | ❌ |

---

## 🚀 Recommandations

### Pour Calcul Scientifique Général
→ **Python** avec NumPy/SciPy

### Pour Statistiques
→ **R**

### Pour Simulation/Modélisation
→ **OpenM++**

### Pour Performance Maximale
→ **C/C++/Fortran** avec MPI

### Pour Migration MATLAB
→ **Octave** (syntaxe compatible)

---

## 📝 Exemples de Jobs

### Python avec NumPy
```bash
#!/bin/bash
#SBATCH --job-name=python_numpy
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=02:00:00

module load python/3.11
python3 <<EOF
import numpy as np
import scipy.linalg

# Calcul scientifique
A = np.random.rand(1000, 1000)
result = scipy.linalg.solve(A, np.ones(1000))
print(result)
EOF
```

### R avec Parallélisation
```bash
#!/bin/bash
#SBATCH --job-name=r_parallel
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=02:00:00

module load R/4.3
Rscript <<EOF
library(parallel)
cl <- makeCluster(8)
result <- parLapply(cl, 1:100, function(x) x^2)
stopCluster(cl)
EOF
```

---

## ❌ Ce qui N'est PAS Nécessaire

### FlexLM (License Server)
- ❌ **Pas nécessaire** si vous n'utilisez pas MATLAB
- ✅ Le script `install-flexlm.sh` est optionnel

### MATLAB Runtime
- ❌ **Pas nécessaire** si vous n'utilisez pas MATLAB
- ✅ Vous pouvez ignorer les sections MATLAB dans la documentation

### MATLAB Jobs
- ❌ **Pas nécessaire** si vous n'utilisez pas MATLAB
- ✅ Utilisez Python, R, Octave, etc. à la place

---

## ✅ Installation du Cluster SANS MATLAB

Le cluster fonctionne **parfaitement** sans MATLAB :

1. ✅ **Slurm** : Fonctionne sans MATLAB
2. ✅ **BeeGFS/Lustre** : Fonctionne sans MATLAB
3. ✅ **LDAP/Kerberos/FreeIPA** : Fonctionne sans MATLAB
4. ✅ **Monitoring** : Fonctionne sans MATLAB
5. ✅ **TrinityX/Warewulf** : Fonctionne sans MATLAB
6. ✅ **Tous les autres composants** : Fonctionnent sans MATLAB

**Vous pouvez installer et utiliser le cluster sans installer MATLAB !**

---

## 📚 Ressources

### Python
- NumPy : https://numpy.org/
- SciPy : https://scipy.org/
- Documentation : `docs/GUIDE_LANCEMENT_JOBS.md`

### R
- R Project : https://www.r-project.org/
- CRAN : https://cran.r-project.org/

### Octave
- GNU Octave : https://www.gnu.org/software/octave/
- Migration MATLAB : https://wiki.octave.org/FAQ

### OpenM++
- OpenM++ : https://github.com/openmpp/main
- Documentation : `docs/TECHNOLOGIES_CLUSTER.md`

---

## 🎯 Conclusion

**MATLAB n'est PAS obligatoire !**

Le cluster HPC est **100% fonctionnel** sans MATLAB. Vous pouvez utiliser :
- ✅ **Python** (recommandé)
- ✅ **R** (statistiques)
- ✅ **OpenM++** (simulation)
- ✅ **Julia** (performance)
- ✅ **Octave** (alternative MATLAB)
- ✅ **C/C++/Fortran** (performance maximale)

**Tous ces outils sont gratuits et open-source !** 🚀

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
