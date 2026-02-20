# 🔬 Applications Scientifiques — Utilisation des applications

> **Accès et utilisation des applications scientifiques sur le cluster**

---

## Applications disponibles

Le cluster propose **27+ applications** scientifiques et de calcul, notamment :

| Domaine | Exemples |
|---------|----------|
| **Simulation** | GROMACS, OpenFOAM, LAMMPS, NAMD, CP2K, Quantum ESPRESSO, ABINIT |
| **Visualisation** | ParaView, VisIt |
| **Big Data / ML** | Apache Spark, TensorFlow, PyTorch |
| **Outils** | OpenMPI, Intel MPI, GCC, modules (Lmod) |

---

## Charger une application (modules)

```bash
module avail                    # lister les modules
module load gromacs/2024        # exemple
module list                     # voir les modules chargés
```

---

## Lancer une application avec Slurm

Toujours passer par le scheduler (pas d’exécution longue sur les nœuds de connexion) :

```bash
# Exemple : job GROMACS
sbatch mon_script_gromacs.sh
```

Voir **[Lancement de Jobs](Lancement-de-Jobs)** pour les exemples détaillés par application.

---

## Documentation complète

- **Guide applications scientifiques** : [docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md)
- **Installation des applications** : [docs/GUIDE_INSTALLATION_APPLICATIONS_SCIENTIFIQUES.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_INSTALLATION_APPLICATIONS_SCIENTIFIQUES.md)

---

## Voir aussi

- **[Lancement de Jobs](Lancement-de-Jobs)** — Soumission Slurm, exemples GROMACS, OpenFOAM, etc.
- **[Guide Utilisateur](Guide-Utilisateur)** — Utilisation quotidienne du cluster
- **[FAQ](FAQ)** — Questions fréquentes

---

[← Accueil](Home)
