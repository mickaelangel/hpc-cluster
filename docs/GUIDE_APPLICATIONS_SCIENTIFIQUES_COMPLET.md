# Guide Applications Scientifiques Complet - Cluster HPC
## Guide Exhaustif des Applications Scientifiques

**Classification**: Documentation Applications  
**Public**: Utilisateurs / Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Applications Mathématiques](#applications-mathématiques)
2. [Applications Chimie Quantique](#applications-chimie-quantique)
3. [Applications Dynamique Moléculaire](#applications-dynamique-moléculaire)
4. [Applications CFD](#applications-cfd)
5. [Applications Visualisation](#applications-visualisation)
6. [Applications Data Science](#applications-data-science)

---

## 🔢 Applications Mathématiques

### R
- **Installation**: `scripts/applications/install-r.sh`
- **Utilisation**: `R --version`
- **RStudio**: `scripts/applications/install-rstudio.sh`

### Julia
- **Installation**: `scripts/applications/install-julia.sh`
- **Utilisation**: `julia --version`

### GNU Octave
- **Installation**: `scripts/applications/install-octave.sh`
- **Utilisation**: `octave --version`

### Scilab
- **Installation**: `scripts/applications/install-scilab.sh`
- **Utilisation**: `scilab -version`

### Maxima
- **Installation**: `scripts/applications/install-maxima.sh`
- **Utilisation**: `maxima --version`

### SageMath
- **Installation**: `scripts/applications/install-sage.sh`
- **Utilisation**: `sage --version`

---

## ⚛️ Applications Chimie Quantique

### Quantum ESPRESSO
- **Installation**: `scripts/software/install-quantum-espresso.sh`
- **Plus**: `scripts/applications/install-espresso-plus.sh`
- **Utilisation**: `pw.x --version`

### CP2K
- **Installation**: `scripts/applications/install-cp2k.sh`
- **CUDA**: `scripts/applications/install-cp2k-cuda.sh`

### ABINIT
- **Installation**: `scripts/applications/install-abinit.sh`

**Note** : VASP et Gaussian nécessitent des licences commerciales et ne sont pas inclus dans ce projet 100% open-source. Utilisez Quantum ESPRESSO, CP2K ou ABINIT comme alternatives open-source.

---

## 🧬 Applications Dynamique Moléculaire

### GROMACS
- **Installation**: `scripts/software/install-gromacs.sh`
- **CUDA**: `scripts/applications/install-gromacs-cuda.sh`

### LAMMPS
- **Installation**: `scripts/applications/install-lammps.sh`
- **CUDA**: `scripts/applications/install-lammps-cuda.sh`

### NAMD
- **Installation**: `scripts/applications/install-namd.sh`
- **CUDA**: `scripts/applications/install-namd-cuda.sh`

### AMBER
- **Installation**: `scripts/applications/install-amber.sh`

**Note** : CHARMM nécessite une licence commerciale et n'est pas inclus dans ce projet 100% open-source. Utilisez GROMACS, LAMMPS, NAMD ou AMBER comme alternatives open-source.

---

## 🌊 Applications CFD

### OpenFOAM
- **Installation**: `scripts/software/install-openfoam.sh`
- **CUDA**: `scripts/applications/install-openfoam-cuda.sh`

### WRF
- **Installation**: `scripts/applications/install-wrf.sh`

---

## 🎨 Applications Visualisation

### ParaView
- **Installation**: `scripts/software/install-paraview.sh`

### VisIt
- **Installation**: `scripts/applications/install-visit.sh`

### VMD
- **Installation**: `scripts/applications/install-vmd.sh`

### OVITO
- **Installation**: `scripts/applications/install-ovito.sh`

---

## 📊 Applications Data Science

### Python Packages
- **Installation**: `scripts/applications/install-python-packages.sh`
- **Packages**: NumPy, SciPy, Matplotlib, Pandas, Scikit-learn, etc.

### JupyterHub
- **Installation**: `scripts/jupyterhub/install-jupyterhub.sh`

### RStudio Server
- **Installation**: `scripts/applications/install-rstudio.sh`

---

## 🚀 Installation Complète

### Installation Toutes les Applications

```bash
./scripts/applications/install-all-scientific-apps.sh
```

---

## 📚 Documentation Complémentaire

- `docs/GUIDE_APPLICATIONS_DETAILLE.md` - Applications détaillées
- `docs/GUIDE_LANCEMENT_JOBS.md` - Lancement jobs

---

**Version**: 1.0
