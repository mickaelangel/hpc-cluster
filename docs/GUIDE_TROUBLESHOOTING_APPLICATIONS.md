# Guide Troubleshooting Applications - Cluster HPC
## Diagnostic et Résolution Problèmes Applications

**Classification**: Documentation Troubleshooting  
**Public**: Utilisateurs / Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [GROMACS](#gromacs)
2. [OpenFOAM](#openfoam)
3. [Quantum ESPRESSO](#quantum-espresso)

---

## 🔬 GROMACS

### Problèmes Courants

```bash
# Erreur mémoire
# Solution: Réduire -ntomp ou augmenter --mem

# Erreur MPI
# Solution: Vérifier --mpi=pmix
```

---

## 🌊 OpenFOAM

### Problèmes Courants

```bash
# Erreur décomposition
# Solution: Vérifier decomposeParDict

# Erreur solver
# Solution: Vérifier logs solver
```

---

**Version**: 1.0
