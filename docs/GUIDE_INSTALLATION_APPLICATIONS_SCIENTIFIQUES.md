# Guide Installation Applications Scientifiques - Cluster HPC
## Installation Complète de Toutes les Applications

**Classification**: Documentation Installation  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Installation Automatique](#installation-automatique)
2. [Installation Manuelle](#installation-manuelle)
3. [Applications Mathématiques](#applications-mathématiques)
4. [Applications Chimie Quantique](#applications-chimie-quantique)
5. [Applications Dynamique Moléculaire](#applications-dynamique-moléculaire)
6. [Applications CFD](#applications-cfd)
7. [Applications Visualisation](#applications-visualisation)

---

## 🚀 Installation Automatique

### Installation Toutes les Applications

```bash
cd "cluster hpc"
chmod +x scripts/applications/install-all-scientific-apps.sh
sudo ./scripts/applications/install-all-scientific-apps.sh
```

---

## 📦 Applications Mathématiques

### R
```bash
./scripts/applications/install-r.sh
```

### RStudio Server
```bash
./scripts/applications/install-rstudio.sh
```

### Julia
```bash
./scripts/applications/install-julia.sh
```

### GNU Octave
```bash
./scripts/applications/install-octave.sh
```

### Scilab
```bash
./scripts/applications/install-scilab.sh
```

### Maxima
```bash
./scripts/applications/install-maxima.sh
```

### SageMath
```bash
./scripts/applications/install-sage.sh
```

---

## ⚛️ Applications Chimie Quantique

### Quantum ESPRESSO
```bash
./scripts/software/install-quantum-espresso.sh
```

### Quantum ESPRESSO Plus
```bash
./scripts/applications/install-espresso-plus.sh
```

### CP2K
```bash
./scripts/applications/install-cp2k.sh
```

### CP2K CUDA
```bash
./scripts/applications/install-cp2k-cuda.sh
```

### ABINIT
```bash
./scripts/applications/install-abinit.sh
```

---

## 🧬 Applications Dynamique Moléculaire

### GROMACS
```bash
./scripts/software/install-gromacs.sh
```

### GROMACS CUDA
```bash
./scripts/applications/install-gromacs-cuda.sh
```

### LAMMPS
```bash
./scripts/applications/install-lammps.sh
```

### LAMMPS CUDA
```bash
./scripts/applications/install-lammps-cuda.sh
```

### NAMD
```bash
./scripts/applications/install-namd.sh
```

### NAMD CUDA
```bash
./scripts/applications/install-namd-cuda.sh
```

### AMBER
```bash
./scripts/applications/install-amber.sh
```

---

## 🌊 Applications CFD

### OpenFOAM
```bash
./scripts/software/install-openfoam.sh
```

### OpenFOAM CUDA
```bash
./scripts/applications/install-openfoam-cuda.sh
```

### WRF
```bash
./scripts/applications/install-wrf.sh
```

---

## 🎨 Applications Visualisation

### ParaView
```bash
./scripts/software/install-paraview.sh
```

### VisIt
```bash
./scripts/applications/install-visit.sh
```

### VMD
```bash
./scripts/applications/install-vmd.sh
```

### OVITO
```bash
./scripts/applications/install-ovito.sh
```

---

## 📚 Documentation Complémentaire

- `GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md` - Guide complet
- `GUIDE_LANCEMENT_JOBS.md` - Lancement jobs

---

**Version**: 1.0
