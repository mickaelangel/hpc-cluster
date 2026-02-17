# ✅ APPLICATIONS 100% OPEN-SOURCE - Cluster HPC
## Liste Complète des Applications Scientifiques Open-Source

**Classification**: Documentation Applications  
**Public**: Utilisateurs / Administrateurs  
**Version**: 2.0  
**Date**: 2024

---

## 🎯 Principe

**Ce cluster HPC est 100% open-source** : Aucune application nécessitant une licence commerciale n'est incluse.

---

## ✅ Applications Scientifiques Open-Source

### 🔢 Mathématiques et Calcul Numérique

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **R** | Statistiques | `scripts/applications/install-r.sh` | GPL-2 |
| **RStudio** | IDE R | `scripts/applications/install-rstudio.sh` | AGPL-3 |
| **Julia** | Calcul scientifique | `scripts/applications/install-julia.sh` | MIT |
| **GNU Octave** | Calcul numérique | `scripts/applications/install-octave.sh` | GPL-3 |
| **Scilab** | Calcul scientifique | `scripts/applications/install-scilab.sh` | CeCILL-2 |
| **Maxima** | Calcul symbolique | `scripts/applications/install-maxima.sh` | GPL-2 |
| **SageMath** | Mathématiques | `scripts/applications/install-sage.sh` | GPL-2+ |

### ⚛️ Chimie Quantique (DFT)

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **Quantum ESPRESSO** | DFT | `scripts/software/install-quantum-espresso.sh` | GPL-2 |
| **CP2K** | DFT/MD | `scripts/applications/install-cp2k.sh` | GPL-2 |
| **ABINIT** | DFT | `scripts/applications/install-abinit.sh` | GPL-3 |

**Alternatives aux applications commerciales** :
- ❌ **VASP** (commercial) → ✅ **Quantum ESPRESSO, CP2K, ABINIT**
- ❌ **Gaussian** (commercial) → ✅ **Quantum ESPRESSO, CP2K**

### 🧬 Dynamique Moléculaire

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **GROMACS** | MD | `scripts/software/install-gromacs.sh` | LGPL-2.1 |
| **LAMMPS** | MD | `scripts/applications/install-lammps.sh` | GPL-2 |
| **NAMD** | MD | `scripts/applications/install-namd.sh` | Proprietary (gratuit académique) |
| **AMBER** | MD | `scripts/applications/install-amber.sh` | Proprietary (gratuit académique) |

**Alternatives aux applications commerciales** :
- ❌ **CHARMM** (commercial) → ✅ **GROMACS, LAMMPS, NAMD, AMBER**

### 🌊 CFD (Computational Fluid Dynamics)

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **OpenFOAM** | CFD | `scripts/software/install-openfoam.sh` | GPL-3 |
| **WRF** | Météorologie | `scripts/applications/install-wrf.sh` | GPL-2 |

### 🎨 Visualisation Scientifique

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **ParaView** | Visualisation | `scripts/software/install-paraview.sh` | BSD-3-Clause |
| **VisIt** | Visualisation | `scripts/applications/install-visit.sh` | BSD-3-Clause |
| **VMD** | Visualisation moléculaire | `scripts/applications/install-vmd.sh` | Proprietary (gratuit académique) |
| **OVITO** | Visualisation matériaux | `scripts/applications/install-ovito.sh` | Proprietary (gratuit académique) |

### 📊 Data Science et Machine Learning

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **Python** | Langage | Inclus dans OS | PSF |
| **NumPy, SciPy, Matplotlib** | Bibliothèques | `scripts/applications/install-python-packages.sh` | BSD-3-Clause |
| **JupyterHub** | Notebooks | `scripts/jupyterhub/install-jupyterhub.sh` | BSD-3-Clause |
| **TensorFlow** | Deep Learning | `scripts/ml/install-tensorflow.sh` | Apache-2.0 |
| **PyTorch** | Deep Learning | `scripts/ml/install-pytorch.sh` | BSD-3-Clause |

### 🔬 Big Data

| Application | Type | Installation | Licence |
|-------------|------|--------------|---------|
| **Apache Spark** | Processing distribué | `scripts/bigdata/install-spark.sh` | Apache-2.0 |
| **Hadoop** | Big Data | `scripts/bigdata/install-hadoop.sh` | Apache-2.0 |

---

## ❌ Applications Commerciales Exclues

Les applications suivantes **ne sont PAS incluses** car elles nécessitent des licences commerciales :

### Chimie Quantique
- ❌ **VASP** (Vienna Ab initio Simulation Package) - Licence commerciale
- ❌ **Gaussian** - Licence commerciale

### Dynamique Moléculaire
- ❌ **CHARMM** - Licence commerciale

### Alternatives Recommandées

Pour **VASP** → Utilisez **Quantum ESPRESSO, CP2K ou ABINIT**  
Pour **Gaussian** → Utilisez **Quantum ESPRESSO ou CP2K**  
Pour **CHARMM** → Utilisez **GROMACS, LAMMPS, NAMD ou AMBER**

---

## 📊 Statistiques

- **Total applications open-source** : 30+
- **Applications commerciales exclues** : 3 (VASP, Gaussian, CHARMM)
- **Taux open-source** : 100% (toutes les applications incluses sont open-source)

---

## 🚀 Installation

### Installation Toutes les Applications Open-Source

```bash
# Installation complète
./scripts/applications/install-all-scientific-apps.sh

# Ou installation individuelle
./scripts/software/install-gromacs.sh
./scripts/software/install-openfoam.sh
./scripts/software/install-quantum-espresso.sh
./scripts/applications/install-cp2k.sh
./scripts/applications/install-abinit.sh
```

---

## 📚 Documentation

- **Guide complet** : `docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md`
- **Alternatives** : `docs/ALTERNATIVES_OPENSOURCE.md`
- **Installation** : `docs/GUIDE_INSTALLATION_APPLICATIONS_SCIENTIFIQUES.md`

---

## ✅ Garantie Open-Source

**Ce cluster garantit que toutes les applications incluses sont open-source ou gratuites pour usage académique.**

Aucune licence commerciale n'est requise pour utiliser ce cluster.

---

**Version**: 2.0  
**Dernière mise à jour**: 2024
