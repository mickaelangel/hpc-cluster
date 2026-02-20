# 📋 Configurations Recommandées — Configurations par scénario

> **Configurations conseillées selon le type de charge (CPU, GPU, I/O, mémoire)**

---

## 🎯 Vue d'ensemble

Quelques **configurations recommandées** selon le scénario : job léger, calcul intensif CPU, GPU, I/O intensif, gros mémoire, multi-nœuds MPI.

---

## Par type de charge

| Scénario | Partition / QoS | Exemple typique |
|----------|------------------|------------------|
| **Test / debug** | `normal`, court (5–15 min) | `#SBATCH --time=00:15:00 --ntasks=1` |
| **CPU intensif** | Partition dédiée CPU, `--ntasks` ou `--cpus-per-task` selon le code | Ajuster `--cpus-per-task` pour OpenMP |
| **GPU** | Partition GPU, `--gres=gpu:N` | `#SBATCH --gres=gpu:1 --partition=gpu` |
| **I/O intensif** | Nœuds proches du stockage, scratch/BeeGFS/Lustre | Préférer scratch pour gros fichiers temporaires |
| **Grosse mémoire** | Partition ou nœuds « bigmem » si disponible | `#SBATCH --mem=64G` (selon politique cluster) |
| **MPI multi-nœuds** | `--nodes=N --ntasks-per-node=M` | Vérifier `srun` vs `mpirun` selon l’environnement |

---

## Bonnes pratiques

- **Walltime** : demander une durée réaliste pour éviter les annulations et libérer les ressources plus tôt si le job finit en avance.
- **Ressources** : demander CPU/GPU/mémoire en cohérence avec l’application (voir [Guide SLURM Complet](Guide-SLURM-Complet)).
- **Stockage** : utiliser le **scratch** pour les I/O temporaires, le **home** pour les scripts et petits fichiers, l’espace **projet** pour les données partagées.

---

## Documentation complète

- **Optimisation performance** : [docs/GUIDE_OPTIMISATION_PERFORMANCE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_OPTIMISATION_PERFORMANCE.md)
- **Scaling cluster** : [docs/GUIDE_SCALING_CLUSTER.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_SCALING_CLUSTER.md)
- **Gestion des capacités** : [docs/GUIDE_GESTION_CAPACITES.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_GESTION_CAPACITES.md)

---

## Voir aussi

- **[Cas d'Usage](Cas-d-Usage)** — Exemples d'utilisation
- **[Retours d'Expérience](Retours-d-Experience)** — Partage d'expériences
- **[Guide SLURM Complet](Guide-SLURM-Complet)** — Partitions, QoS, options sbatch
- **[Home](Home)** — Accueil du wiki

---

[← Accueil](Home)
