# 📊 Cas d'Usage — Exemples d'utilisation

> **Exemples concrets d'utilisation du Cluster HPC Enterprise**

---

## 🎯 Vue d'ensemble

Cette page regroupe des **cas d'usage** typiques : simulation, calcul parallèle, big data / ML, visualisation, développement et tests.

---

## Exemples par domaine

| Domaine | Exemple | Ressources |
|--------|---------|-------------|
| **Simulation** | GROMACS, OpenFOAM, LAMMPS, NAMD | [Lancement de Jobs](Lancement-de-Jobs), [Applications Scientifiques](Applications-Scientifiques) |
| **Calcul parallèle** | MPI, OpenMP, jobs multi-nœuds | [Guide SLURM Complet](Guide-SLURM-Complet) |
| **Big Data / ML** | Spark, TensorFlow, PyTorch sur le cluster | [Applications Scientifiques](Applications-Scientifiques), docs Machine Learning / Big Data |
| **Visualisation** | ParaView, VisIt (rendu ou post-traitement) | [Lancement de Jobs](Lancement-de-Jobs) |
| **Dev / tests** | Compilation, tests unitaires, petits jobs | [Premiers Pas](Premiers-Pas), [Guide Utilisateur](Guide-Utilisateur) |
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

- **[Configurations Recommandées](Configurations-Recommandees)** — Configurations par scénario
- **[Retours d'Expérience](Retours-d-Experience)** — Partage d'expériences
- **[Home](Home)** — Accueil du wiki

---

[← Accueil](Home)
