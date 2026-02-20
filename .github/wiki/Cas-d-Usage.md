# 📊 Cas d'Usage — Exemples d'utilisation

> **Exemples concrets d'utilisation du Cluster HPC Enterprise**

---

## 🎯 Vue d'ensemble

Cette page regroupe des **cas d'usage** typiques : simulation, calcul parallèle, big data / ML, visualisation, développement et tests.

---

## Exemples par domaine

| Domaine | Exemple | Ressources |
|--------|---------|-------------|
| **Simulation** | GROMACS, OpenFOAM, LAMMPS, NAMD | [Lancement de Jobs](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Lancement-de-Jobs.md), [Applications Scientifiques](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Applications-Scientifiques.md) |
| **Calcul parallèle** | MPI, OpenMP, jobs multi-nœuds | [Guide SLURM Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md) |
| **Big Data / ML** | Spark, TensorFlow, PyTorch sur le cluster | [Applications Scientifiques](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Applications-Scientifiques.md), docs Machine Learning / Big Data |
| **Visualisation** | ParaView, VisIt (rendu ou post-traitement) | [Lancement de Jobs](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Lancement-de-Jobs.md) |
| **Dev / tests** | Compilation, tests unitaires, petits jobs | [Premiers Pas](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Premiers-Pas.md), [Guide Utilisateur](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-Utilisateur.md) |
| **Haute disponibilité** | Bascule frontaux, services critiques | [Guide HA](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_HAUTE_DISPONIBILITE.md) |
| **Disaster recovery** | Scénarios sinistre, restauration | [Disaster Recovery](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_DISASTER_RECOVERY.md) |

---

## Workflow type

1. **Connexion** → `ssh user@frontal-01`
2. **Préparer données** → home ou espace projet / scratch
3. **Charger l’environnement** → `module load ...`
4. **Soumettre le job** → `sbatch script.sh` ou `srun ...`
5. **Suivre et récupérer** → `squeue`, fichiers de sortie, logs

---

## Documentation complète

- **Index documentation** : [docs/INDEX_DOCUMENTATION.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/INDEX_DOCUMENTATION.md)
- **Lancement de jobs** : [docs/GUIDE_LANCEMENT_JOBS.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_LANCEMENT_JOBS.md)
- **Applications scientifiques** : [docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md)

---

## Voir aussi

- **[Configurations Recommandées](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Configurations-Recommandees.md)** — Configurations par scénario
- **[Retours d'Expérience](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Retours-d-Experience.md)** — Partage d'expériences
- **[Home](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)** — Accueil du wiki

---

[← Accueil](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)
