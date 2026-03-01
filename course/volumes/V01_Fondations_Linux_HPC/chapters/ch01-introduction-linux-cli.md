# Chapitre 1 — Introduction au système Linux et à la ligne de commande

**Objectifs** :
- Comprendre le rôle d’un système d’exploitation en environnement HPC.
- Utiliser le terminal et les commandes de base (navigation, fichiers, recherche).
- Se repérer dans l’arborescence FHS (Filesystem Hierarchy Standard).

**Prérequis** : Aucun.  
**Durée indicative** : 1 h lecture + 30 min pratique.

---

## 1.1 Pourquoi Linux en HPC ?

Les clusters et supercalculateurs reposent presque tous sur **Linux** : stabilité, outillage en ligne de commande, support du parallélisme et des réseaux hautes performances. En tant qu’utilisateur ou administrateur, vous travaillerez essentiellement en **ligne de commande** (CLI).

> **NOTE** — Dans le projet hpc-cluster, les nœuds (frontal-01, frontal-02, compute-01 … compute-06) sont basés sur **openSUSE Leap 15.6**. Les commandes données ici sont valables sur openSUSE et la plupart des distributions Linux.

---

## 1.2 Terminal et shell

- **Terminal** : interface texte pour saisir des commandes.
- **Shell** : programme qui interprète les commandes (Bash par défaut sur openSUSE).
- Ouvrir un terminal : `Ctrl+Alt+T` (environnement graphique) ou connexion **SSH** sur un nœud frontal (ex. `ssh utilisateur@frontal-01`).

```bash
# Vérifier le shell utilisé
echo $SHELL

# Répertoire courant
pwd
```

---

## 1.3 Navigation et répertoires de base

| Commande | Description |
|----------|-------------|
| `pwd` | Afficher le répertoire de travail courant |
| `ls` | Lister le contenu d’un répertoire |
| `ls -la` | Liste détaillée (droits, propriétaire, taille) |
| `cd chemin` | Changer de répertoire |
| `cd ~` | Aller dans le répertoire personnel |
| `cd -` | Revenir au répertoire précédent |

Répertoires importants (FHS) :
- `/` : racine du système.
- `/home` : répertoires personnels des utilisateurs.
- `/etc` : configuration système.
- `/var` : données variables (logs, cache).
- `/usr` : programmes et binaires utilisateur.

---

## 1.4 Fichiers : affichage et recherche

```bash
# Afficher le contenu d’un fichier
cat fichier.txt
less fichier.txt   # défilement, recherche avec /

# Créer un fichier vide
touch monfichier.txt

# Rechercher un fichier par nom
find /etc -name "*.conf" 2>/dev/null | head -5
```

---

## 1.5 Erreurs fréquentes

- Oublier que Linux est **sensible à la casse** : `File.txt` et `file.txt` sont différents.
- Confondre **chemins absolus** (à partir de `/`) et **relatifs** (à partir du répertoire courant). Ex. : `cd /home/user` vs `cd home/user` (le second ne fonctionne que si vous êtes à la racine).
- Utiliser des **espaces** dans les noms de fichiers sans guillemets : préférer des tirets ou underscores, ou mettre le chemin entre guillemets.

---

## 1.6 Validation

Vérifier que vous savez :
- Ouvrir un terminal et afficher le répertoire courant.
- Lister le contenu de `/etc` avec `ls -la`.
- Afficher le contenu d’un fichier (ex. `/etc/hostname`) avec `cat`.

---

## Exercices

Voir `exercises/ch01-exercises.md`. Corrigés dans `solutions/ch01-solutions.md`.
