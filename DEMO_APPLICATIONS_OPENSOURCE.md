# Démo Cluster HPC - 4 Applications Open-Source
## Remplacement de MATLAB par des Applications Gratuites

**Date**: 2024

---

## ✅ Modifications Effectuées

### ❌ MATLAB Retiré

- ✅ Fichier `examples/jobs/exemple-matlab.sh` **supprimé**
- ✅ Script `scripts/flexlm/install-flexlm.sh` **supprimé**
- ✅ Références MATLAB dans la documentation **mises à jour**

### ✅ 4 Applications Open-Source Ajoutées

1. **GROMACS** - Simulation Moléculaire
2. **OpenFOAM** - Computational Fluid Dynamics (CFD)
3. **Quantum ESPRESSO** - Calculs Quantiques (DFT)
4. **ParaView** - Visualisation Scientifique

---

## 📁 Fichiers Créés

### Scripts d'Installation

1. ✅ `scripts/software/install-gromacs.sh`
2. ✅ `scripts/software/install-openfoam.sh`
3. ✅ `scripts/software/install-quantum-espresso.sh`
4. ✅ `scripts/software/install-paraview.sh`

### Exemples de Jobs

1. ✅ `examples/jobs/exemple-gromacs.sh`
2. ✅ `examples/jobs/exemple-openfoam.sh`
3. ✅ `examples/jobs/exemple-quantum-espresso.sh`
4. ✅ `examples/jobs/exemple-paraview.sh`

### Documentation

1. ✅ `docs/APPLICATIONS_OPENSOURCE.md` - Guide complet
2. ✅ `DEMO_APPLICATIONS_OPENSOURCE.md` - Ce fichier

---

## 🚀 Installation des Applications

### Installation Complète

```bash
cd cluster\ hpc/scripts/software

# 1. GROMACS
sudo ./install-gromacs.sh

# 2. OpenFOAM
sudo ./install-openfoam.sh

# 3. Quantum ESPRESSO
sudo ./install-quantum-espresso.sh

# 4. ParaView
sudo ./install-paraview.sh
```

### Vérification

```bash
# GROMACS
module load gromacs/2023.2
gmx --version

# OpenFOAM
module load openfoam/2312
source ${FOAM_INST_DIR}/etc/bashrc
simpleFoam --help

# Quantum ESPRESSO
module load quantum-espresso/7.2
pw.x --help

# ParaView
module load paraview/5.11.2
paraview --version
```

---

## 📝 Utilisation

### Jobs Slurm

```bash
# GROMACS
sbatch examples/jobs/exemple-gromacs.sh

# OpenFOAM
sbatch examples/jobs/exemple-openfoam.sh

# Quantum ESPRESSO
sbatch examples/jobs/exemple-quantum-espresso.sh

# ParaView
sbatch examples/jobs/exemple-paraview.sh
```

---

## 📊 Comparaison

| Application | Domaine | Gratuit | Performance | Parallélisation |
|-------------|---------|---------|-------------|-----------------|
| **GROMACS** | Biologie | ✅ | ⭐⭐⭐⭐⭐ | MPI + OpenMP |
| **OpenFOAM** | Mécanique des fluides | ✅ | ⭐⭐⭐⭐ | MPI |
| **Quantum ESPRESSO** | Physique quantique | ✅ | ⭐⭐⭐⭐⭐ | MPI |
| **ParaView** | Visualisation | ✅ | ⭐⭐⭐⭐ | OpenMP |

---

## 🎯 Avantages

### Par Rapport à MATLAB

- ✅ **100% Gratuit** : Aucune licence requise
- ✅ **Open-Source** : Code source disponible
- ✅ **Performant** : Optimisé pour HPC
- ✅ **Communauté** : Support actif
- ✅ **Standards** : Formats standards

---

## 📚 Documentation

### Guide Complet

- `docs/APPLICATIONS_OPENSOURCE.md` - Guide détaillé de chaque application

### Exemples

- `examples/jobs/exemple-gromacs.sh`
- `examples/jobs/exemple-openfoam.sh`
- `examples/jobs/exemple-quantum-espresso.sh`
- `examples/jobs/exemple-paraview.sh`

---

## ✅ Résultat Final

**Le cluster HPC est maintenant équipé de 4 applications open-source** :

1. ✅ **GROMACS** - Simulation moléculaire
2. ✅ **OpenFOAM** - CFD
3. ✅ **Quantum ESPRESSO** - Calculs quantiques
4. ✅ **ParaView** - Visualisation

**Toutes sont gratuites, performantes et prêtes pour la démo !** 🚀

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
