# Applications Open-Source pour Démo Cluster HPC
## 4 Applications Scientifiques Gratuites et Performantes

**Classification**: Documentation Technique  
**Public**: Utilisateurs du Cluster  
**Version**: 1.0  
**Date**: 2024

---

## 🎯 Vue d'ensemble

Le cluster HPC est configuré avec **4 applications open-source** pour démonstration :

1. **GROMACS** - Simulation Moléculaire
2. **OpenFOAM** - Computational Fluid Dynamics (CFD)
3. **Quantum ESPRESSO** - Calculs Quantiques (DFT)
4. **ParaView** - Visualisation Scientifique

**Toutes ces applications sont** :
- ✅ **100% gratuites** et open-source
- ✅ **Performantes** pour HPC
- ✅ **Parallélisables** (MPI/OpenMP)
- ✅ **Installées** via scripts automatisés

---

## 1. 🔬 GROMACS - Simulation Moléculaire

### Description

**GROMACS** est un package de simulation moléculaire haute performance utilisé pour :
- Simulation de dynamique moléculaire (MD)
- Analyse de systèmes biologiques
- Études de protéines, membranes, ADN
- Calculs de propriétés thermodynamiques

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-gromacs.sh
```

### Utilisation

```bash
# Charger le module
module load gromacs/2023.2

# Vérifier l'installation
gmx --version

# Exemple de job
sbatch examples/jobs/exemple-gromacs.sh
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

# Exécution MD
srun gmx_mpi mdrun -deffnm nvt -v
```

### Ressources

- Site web : https://www.gromacs.org/
- Documentation : https://manual.gromacs.org/
- Tutoriels : https://www.gromacs.org/Documentation/Tutorials

---

## 2. 🌊 OpenFOAM - Computational Fluid Dynamics

### Description

**OpenFOAM** est un framework open-source pour la mécanique des fluides computationnelle (CFD) :
- Résolution d'équations de Navier-Stokes
- Simulation de flux turbulents
- Aérodynamique, hydrodynamique
- Transfert de chaleur et de masse

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-openfoam.sh
```

### Utilisation

```bash
# Charger le module
module load openfoam/2312
source ${FOAM_INST_DIR}/etc/bashrc

# Vérifier l'installation
simpleFoam --help

# Exemple de job
sbatch examples/jobs/exemple-openfoam.sh
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

### Ressources

- Site web : https://www.openfoam.com/
- Documentation : https://www.openfoam.com/documentation/
- Tutoriels : https://www.openfoam.com/documentation/tutorial-guide/

---

## 3. ⚛️ Quantum ESPRESSO - Calculs Quantiques

### Description

**Quantum ESPRESSO** est une suite de codes pour calculs électroniques de structure (DFT) :
- Calculs DFT (Density Functional Theory)
- Structure électronique de matériaux
- Propriétés optiques et magnétiques
- Simulations ab initio

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-quantum-espresso.sh
```

### Utilisation

```bash
# Charger le module
module load quantum-espresso/7.2

# Vérifier l'installation
pw.x --help

# Exemple de job
sbatch examples/jobs/exemple-quantum-espresso.sh
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

### Ressources

- Site web : https://www.quantum-espresso.org/
- Documentation : https://www.quantum-espresso.org/documentation/
- Tutoriels : https://www.quantum-espresso.org/tutorials/

---

## 4. 📊 ParaView - Visualisation Scientifique

### Description

**ParaView** est un outil de visualisation scientifique open-source :
- Visualisation de données volumétriques
- Traitement de résultats de simulation
- Rendu haute performance
- Interface graphique et batch

### Installation

```bash
cd cluster\ hpc/scripts/software
sudo ./install-paraview.sh
```

### Utilisation

```bash
# Charger le module
module load paraview/5.11.2

# Vérifier l'installation
paraview --version

# Exemple de job
sbatch examples/jobs/exemple-paraview.sh
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

### Visualisation à Distance

```bash
# Sur le nœud de calcul (serveur)
pvserver --server-port=11111

# Sur machine locale (client)
paraview --server-url=cs://compute-node:11111
```

### Ressources

- Site web : https://www.paraview.org/
- Documentation : https://docs.paraview.org/
- Tutoriels : https://www.paraview.org/tutorials/

---

## 📊 Comparaison des Applications

| Application | Domaine | Parallélisation | Performance | Complexité |
|-------------|---------|-----------------|-------------|------------|
| **GROMACS** | Biologie | MPI + OpenMP | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **OpenFOAM** | Mécanique des fluides | MPI | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Quantum ESPRESSO** | Physique quantique | MPI | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **ParaView** | Visualisation | OpenMP | ⭐⭐⭐⭐ | ⭐⭐ |

---

## 🚀 Installation Complète

### Installation de Toutes les Applications

```bash
# 1. GROMACS
cd cluster\ hpc/scripts/software
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
# Vérifier toutes les installations
module load gromacs/2023.2 && gmx --version
module load openfoam/2312 && simpleFoam --help
module load quantum-espresso/7.2 && pw.x --help
module load paraview/5.11.2 && paraview --version
```

---

## 📝 Exemples de Jobs

Tous les exemples sont disponibles dans `examples/jobs/` :

- ✅ `exemple-gromacs.sh` - Simulation moléculaire
- ✅ `exemple-openfoam.sh` - Simulation CFD
- ✅ `exemple-quantum-espresso.sh` - Calculs DFT
- ✅ `exemple-paraview.sh` - Visualisation
- ✅ `exemple-python.sh` - Calcul Python
- ✅ `exemple-mpi.sh` - Calcul MPI générique
- ✅ `exemple-array.sh` - Jobs array

---

## 🎯 Cas d'Usage

### Workflow Complet

1. **Simulation** : GROMACS, OpenFOAM, Quantum ESPRESSO
2. **Analyse** : Python, R
3. **Visualisation** : ParaView

### Exemple de Pipeline

```bash
# 1. Simulation GROMACS
sbatch exemple-gromacs.sh

# 2. Analyse des résultats (Python)
sbatch exemple-python.sh

# 3. Visualisation (ParaView)
sbatch exemple-paraview.sh
```

---

## ✅ Avantages

### Par Rapport à MATLAB

- ✅ **Gratuit** : Aucune licence requise
- ✅ **Open-source** : Code source disponible
- ✅ **Performant** : Optimisé pour HPC
- ✅ **Communauté** : Support actif
- ✅ **Standards** : Formats standards

---

## 📚 Ressources Complémentaires

### Documentation

- `docs/GUIDE_LANCEMENT_JOBS.md` - Guide complet lancement jobs
- `docs/TECHNOLOGIES_CLUSTER.md` - Technologies du cluster
- `examples/jobs/` - Exemples de jobs

### Support

- Forums communautaires pour chaque application
- Documentation officielle
- Tutoriels en ligne

---

## 🎉 Conclusion

Le cluster HPC est maintenant équipé de **4 applications open-source** performantes :

1. ✅ **GROMACS** - Simulation moléculaire
2. ✅ **OpenFOAM** - CFD
3. ✅ **Quantum ESPRESSO** - Calculs quantiques
4. ✅ **ParaView** - Visualisation

**Toutes sont gratuites, performantes et prêtes pour la démo !** 🚀

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
