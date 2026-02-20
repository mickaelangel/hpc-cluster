# 🚀 Premiers pas sur le cluster HPC

> Guide minimal pour **démarrer en 5 minutes** : connexion, premier job, où trouver l’aide.

---

## 1. Se connecter

- **SSH** vers un nœud frontal (login) :
  ```bash
  ssh votre_utilisateur@frontal-01   # ou l’adresse fournie par l’admin
  ```
- Utilisez les clés SSH ou le mot de passe selon la configuration du cluster.

---

## 2. Vérifier l’environnement

```bash
# Voir les partitions et nœuds disponibles
sinfo

# Voir la file d’attente
squeue

# Charger un module (ex. un compilateur) si besoin
module avail
module load gcc/12   # exemple
```

---

## 3. Lancer votre premier job

**Option A — Job interactif** (pour tester) :
```bash
srun --partition=normal --time=00:05:00 --pty bash
# vous êtes sur un nœud de calcul ; tapez exit pour quitter
```

**Option B — Job batch** (script) :
```bash
echo '#!/bin/bash
#SBATCH --job-name=mon-premier-job
#SBATCH --partition=normal
#SBATCH --time=00:05:00
#SBATCH --ntasks=1
hostname
echo "Hello from the cluster"
' > mon_script.sh
sbatch mon_script.sh
```

Consulter le résultat : `cat slurm-<jobid>.out` (ou le fichier indiqué dans le script).

---

## 4. Où aller ensuite ?

| Besoin | Page |
|--------|------|
| Comprendre Slurm (partitions, QoS, sbatch) | [Guide SLURM Complet](Guide-SLURM-Complet) |
| Lancer des jobs (batch, exemples) | [Lancement de Jobs](Lancement-de-Jobs) |
| Utilisation quotidienne du cluster | [Guide Utilisateur](Guide-Utilisateur) |
| Commandes utiles au quotidien | [Commandes Utiles](Commandes-Utiles) |
| Problèmes courants | [Dépannage](Depannage) |
| Concepts HPC (cours) | [Cours HPC Complet](Cours-HPC-Complet) |
| Installation / configuration du cluster | [Installation Rapide](Installation-Rapide), [Configuration de Base](Configuration-de-Base) |

---

[← Accueil](Home)

**Bonne découverte du cluster.**
