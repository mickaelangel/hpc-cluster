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

Voir **[Premiers Pas](Premiers-Pas)** et **[Lancement de Jobs](Lancement-de-Jobs)** pour les détails.

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
- **[FAQ](FAQ)** · **[Dépannage](Depannage)** · **[Commandes Utiles](Commandes-Utiles)**

---

[← Accueil](Home)
