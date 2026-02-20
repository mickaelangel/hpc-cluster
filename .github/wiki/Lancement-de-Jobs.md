# 🚀 Lancement de Jobs — Comment lancer des jobs

> **Slurm : soumission interactive, batch, et exemples (GROMACS, OpenFOAM, etc.)**

---

## Soumission rapide

### Job interactif (test, debug)

```bash
srun --partition=normal --time=00:30:00 --ntasks=1 --pty bash
# vous êtes sur un nœud de calcul ; tapez exit pour quitter
```

### Job batch (script)

```bash
# Exemple minimal
echo '#!/bin/bash
#SBATCH --job-name=mon-job
#SBATCH --partition=normal
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
hostname
echo "Hello from the cluster"
' > mon_script.sh
sbatch mon_script.sh
```

Consulter le résultat : `cat slurm-<jobid>.out`

---

## Commandes utiles

| Commande | Description |
|----------|-------------|
| `sbatch script.sh` | Soumettre un job batch |
| `srun ...` | Lancer un job interactif |
| `squeue -u $USER` | Voir vos jobs (pending + running) |
| `scancel <jobid>` | Annuler un job |
| `sinfo` | Partitions et nœuds disponibles |

---

## Exemples par type d'application

Le guide détaillé couvre : **GROMACS**, **OpenFOAM**, **Quantum ESPRESSO**, **ParaView**, **OpenM++**, applications graphiques, monitoring et dépannage.

➡️ **Guide complet** : [docs/GUIDE_LANCEMENT_JOBS.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_LANCEMENT_JOBS.md)

---

## Voir aussi

- **[Guide SLURM Complet](Guide-SLURM-Complet)** — Partitions, QoS, sbatch, bonnes pratiques
- **[Premiers Pas](Premiers-Pas)** — Connexion et premier job
- **[Commandes Utiles](Commandes-Utiles)** — Référence rapide

---

[← Accueil](Home)
