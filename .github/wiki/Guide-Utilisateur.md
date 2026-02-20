# 👥 Guide Utilisateur — Utilisation du cluster

> **Utilisation quotidienne du Cluster HPC Enterprise**

---

## 🚀 Premiers pas

### Connexion

```bash
ssh votre-utilisateur@frontal-01   # ou l'adresse fournie par l'admin
```

### Vérifier l'environnement

```bash
whoami
sinfo          # partitions et nœuds
squeue         # file d'attente des jobs
module avail   # modules disponibles
```

---

## 📤 Soumission de jobs

- **Job interactif** : `srun --partition=normal --time=00:30:00 --pty bash`
- **Job batch** : rédiger un script avec `#SBATCH` puis `sbatch mon_script.sh`

Voir **[Premiers Pas](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Premiers-Pas.md)** et **[Lancement de Jobs](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Lancement-de-Jobs.md)** pour les détails.

---

## 📁 Fichiers et stockage

| Espace | Usage |
|--------|--------|
| **Home** | Fichiers personnels, sauvegardes |
| **Scratch / work** | Données de calcul, I/O intensif (purge possible) |
| **Project** | Données de projet partagées |

---

## 📚 Documentation complète

- **Guide détaillé** (connexion, auth, jobs, bonnes pratiques) : [docs/GUIDE_UTILISATEUR.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_UTILISATEUR.md)
- **[FAQ](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/FAQ.md)** · **[Dépannage](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Depannage.md)** · **[Commandes Utiles](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Commandes-Utiles.md)**

---

[← Accueil](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)
