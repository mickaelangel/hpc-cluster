# Guide Détaillé des Applications - Cluster HPC
## Explication Complète de Chaque Application Open-Source

**Classification**: Documentation Technique Pédagogique  
**Public**: Tous les Niveaux  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [GROMACS](#gromacs)
2. [OpenFOAM](#openfoam)
3. [Quantum ESPRESSO](#quantum-espresso)
4. [ParaView](#paraview)
5. [Comparaison](#comparaison)
6. [Cas d'Usage](#cas-dusage)

---

## 🔬 GROMACS

### Qu'est-ce que c'est ?

**GROMACS** (GROningen MAchine for Chemical Simulations) est un package de simulation moléculaire haute performance.

**Fonctionnalités** :
- Dynamique moléculaire (MD)
- Minimisation d'énergie
- Analyse de trajectoires
- Calculs de propriétés

### Pourquoi l'utiliser ?

- ✅ **Performance** : Très optimisé, utilise SIMD
- ✅ **Standard** : Utilisé partout en biologie
- ✅ **Open-source** : Gratuit, code source disponible
- ✅ **Communauté** : Large communauté, support actif

### Comment ça marche ?

```
Fichiers d'entrée
    │
    ├─► Structure (.gro, .pdb)
    ├─► Topologie (.top)
    └─► Paramètres (.mdp)
    │
    ▼
grompp (préparation)
    │
    ▼
Fichier binaire (.tpr)
    │
    ▼
mdrun (simulation)
    │
    ▼
Trajectoire (.trr, .xtc)
    │
    ▼
Analyse
```

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-gromacs.sh
```

### Utilisation de Base

**Préparation** :
```bash
module load gromacs/2023.2

# Créer fichier de paramètres
gmx pdb2gmx -f protein.pdb -o protein.gro -p protein.top

# Préparation
gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr
```

**Simulation** :
```bash
# Single CPU
gmx mdrun -deffnm nvt

# MPI (multi-nœuds)
srun gmx_mpi mdrun -deffnm nvt -v
```

**Analyse** :
```bash
# RMSD
gmx rms -f traj.xtc -s nvt.tpr -o rmsd.xvg

# Énergie
gmx energy -f ener.edr -o energy.xvg
```

### Exemple de Job

```bash
#!/bin/bash
#SBATCH --job-name=gromacs-md
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=4:00:00

module load gromacs/2023.2
module load openmpi/4.1.5

# Préparation
gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr

# Simulation
srun gmx_mpi mdrun -deffnm nvt -v
```

### Domaines d'Application

- **Biologie structurale** : Protéines, ADN, ARN
- **Membranes** : Lipides, membranes cellulaires
- **Pharmacologie** : Interactions médicament-protéine
- **Matériaux** : Polymères, cristaux

### Ressources

- Site : https://www.gromacs.org/
- Documentation : https://manual.gromacs.org/
- Tutoriels : https://www.gromacs.org/Documentation/Tutorials

---

## 🌊 OpenFOAM

### Qu'est-ce que c'est ?

**OpenFOAM** (Open Field Operation and Manipulation) est un framework open-source pour la mécanique des fluides computationnelle (CFD).

**Fonctionnalités** :
- Résolution Navier-Stokes
- Turbulence
- Transfert de chaleur
- Multiphase

### Pourquoi l'utiliser ?

- ✅ **Complet** : Tous les outils CFD
- ✅ **Flexible** : Personnalisable
- ✅ **Open-source** : Gratuit
- ✅ **Standard** : Utilisé en industrie

### Comment ça marche ?

```
Maillage
    │
    ▼
blockMesh / snappyHexMesh
    │
    ▼
Configuration
    │
    ├─► Conditions limites
    ├─► Propriétés physiques
    └─► Schémas numériques
    │
    ▼
Résolution
    │
    ├─► simpleFoam (turbulent)
    ├─► pimpleFoam (transitoire)
    └─► ...
    │
    ▼
Post-traitement
    │
    └─► ParaView
```

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-openfoam.sh
```

### Utilisation de Base

**Préparation** :
```bash
module load openfoam/2312
source ${FOAM_INST_DIR}/etc/bashrc

# Créer maillage
blockMesh

# Vérifier maillage
checkMesh
```

**Résolution** :
```bash
# Turbulent stationnaire
simpleFoam

# Parallèle
srun simpleFoam -parallel
```

**Post-traitement** :
```bash
# ParaView
paraFoam
```

### Exemple de Job

```bash
#!/bin/bash
#SBATCH --job-name=openfoam-cfd
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=6:00:00

module load openfoam/2312
source ${FOAM_INST_DIR}/etc/bashrc

# Préparation
blockMesh
checkMesh

# Résolution
srun simpleFoam -parallel
```

### Domaines d'Application

- **Aérodynamique** : Avions, voitures
- **Hydrodynamique** : Navires, sous-marins
- **Transfert de chaleur** : Échangeurs, radiateurs
- **Turbulence** : Écoulements complexes

### Ressources

- Site : https://www.openfoam.com/
- Documentation : https://www.openfoam.com/documentation/
- Tutoriels : https://www.openfoam.com/documentation/tutorial-guide/

---

## ⚛️ Quantum ESPRESSO

### Qu'est-ce que c'est ?

**Quantum ESPRESSO** est une suite de codes pour calculs électroniques de structure basés sur la théorie de la fonctionnelle de la densité (DFT).

**Fonctionnalités** :
- Calculs DFT
- Structure électronique
- Propriétés optiques
- Propriétés magnétiques

### Pourquoi l'utiliser ?

- ✅ **Précis** : Calculs ab initio
- ✅ **Standard** : Utilisé en physique quantique
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Optimisé pour HPC

### Comment ça marche ?

```
Structure atomique
    │
    ▼
pw.x (calcul SCF)
    │
    ├─► Résolution Kohn-Sham
    └─► Auto-consistance
    │
    ▼
Propriétés
    │
    ├─► Bands (bandes.x)
    ├─► DOS (dos.x)
    └─► ...
```

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-quantum-espresso.sh
```

### Utilisation de Base

**Calcul SCF** :
```bash
module load quantum-espresso/7.2

# Fichier d'entrée scf.in
srun pw.x < scf.in > scf.out
```

**Calcul Bands** :
```bash
# Fichier d'entrée bands.in
srun pw.x < bands.in > bands.out

# Post-traitement
srun bands.x < bands_pp.in > bands_pp.out
```

### Exemple de Job

```bash
#!/bin/bash
#SBATCH --job-name=qe-dft
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --time=8:00:00

module load quantum-espresso/7.2
module load openmpi/4.1.5

# Calcul SCF
srun pw.x < scf.in > scf.out

# Calcul Bands
srun pw.x < bands.in > bands.out
```

### Domaines d'Application

- **Physique quantique** : Structure électronique
- **Matériaux** : Propriétés des matériaux
- **Chimie quantique** : Réactions chimiques
- **Optique** : Propriétés optiques

### Ressources

- Site : https://www.quantum-espresso.org/
- Documentation : https://www.quantum-espresso.org/documentation/
- Tutoriels : https://www.quantum-espresso.org/tutorials/

---

## 📊 ParaView

### Qu'est-ce que c'est ?

**ParaView** est un outil de visualisation scientifique open-source pour données volumétriques.

**Fonctionnalités** :
- Visualisation 3D
- Traitement de données
- Rendu haute performance
- Scripting Python

### Pourquoi l'utiliser ?

- ✅ **Puissant** : Visualisation complexe
- ✅ **Flexible** : Scriptable
- ✅ **Open-source** : Gratuit
- ✅ **Standard** : Utilisé partout

### Comment ça marche ?

```
Données
    │
    ├─► Fichiers (VTK, HDF5, etc.)
    └─► Résultats simulations
    │
    ▼
ParaView
    │
    ├─► Chargement
    ├─► Filtres
    └─► Rendu
    │
    ▼
Visualisation
    │
    └─► Images, animations
```

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-paraview.sh
```

### Utilisation de Base

**Interface Graphique** :
```bash
module load paraview/5.11.2

# Local
paraview

# Remote (X2Go/NoMachine)
ssh -X user@frontal-01
paraview
```

**Batch (Python)** :
```bash
# Script Python
pvpython script.py
```

**Serveur** :
```bash
# Serveur
pvserver --server-port=11111

# Client
paraview --server-url=cs://compute-node:11111
```

### Exemple de Job

```bash
#!/bin/bash
#SBATCH --job-name=paraview-viz
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=2:00:00

module load paraview/5.11.2

# Visualisation batch
pvpython my_visualization.py
```

### Domaines d'Application

- **Visualisation** : Résultats de simulations
- **Traitement** : Traitement de données
- **Rendu** : Images, animations
- **Analyse** : Analyse visuelle

### Ressources

- Site : https://www.paraview.org/
- Documentation : https://docs.paraview.org/
- Tutoriels : https://www.paraview.org/tutorials/

---

## 📊 Comparaison

| Application | Domaine | Performance | Parallélisation | Complexité |
|-------------|---------|-------------|-----------------|------------|
| **GROMACS** | Biologie | ⭐⭐⭐⭐⭐ | MPI + OpenMP | ⭐⭐⭐ |
| **OpenFOAM** | Mécanique des fluides | ⭐⭐⭐⭐ | MPI | ⭐⭐⭐⭐ |
| **Quantum ESPRESSO** | Physique quantique | ⭐⭐⭐⭐⭐ | MPI | ⭐⭐⭐⭐⭐ |
| **ParaView** | Visualisation | ⭐⭐⭐⭐ | OpenMP | ⭐⭐ |

---

## 🎯 Cas d'Usage

### Workflow Complet

**1. Simulation** :
- GROMACS : Simulation moléculaire
- OpenFOAM : Simulation CFD
- Quantum ESPRESSO : Calculs DFT

**2. Analyse** :
- Python : Analyse des résultats
- R : Statistiques

**3. Visualisation** :
- ParaView : Visualisation 3D
- Python/Matplotlib : Graphiques 2D

---

## 📚 Ressources Complémentaires

### Documentation

- `docs/APPLICATIONS_OPENSOURCE.md` - Guide complet
- `examples/jobs/` - Exemples de jobs

### Support

- Forums communautaires
- Documentation officielle
- Tutoriels en ligne

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
