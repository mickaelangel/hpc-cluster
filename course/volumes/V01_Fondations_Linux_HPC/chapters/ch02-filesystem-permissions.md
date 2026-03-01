# Chapitre 2 — Système de fichiers et permissions

**Objectifs** :
- Comprendre le modèle de permissions Linux (u/g/o, rwx).
- Utiliser `chmod`, `chown`, `chgrp`.
- Interpréter la sortie de `ls -l` et les droits sur les répertoires.

**Prérequis** : Chapitre 1.  
**Durée indicative** : 1 h.

---

## 2.1 Lecture de `ls -l`

```bash
ls -l /etc/hostname
```

Exemple de sortie : `-rw-r--r-- 1 root root 12 Mar  1 10:00 /etc/hostname`

- **Premier caractère** : `-` = fichier, `d` = répertoire, `l` = lien symbolique.
- **Neuf caractères suivants** : droits en trois groupes (user, group, others) — `r` read, `w` write, `x` execute (ou `x` sur répertoire = droit d’entrée).
- **Propriétaire / groupe** : `root root` (user, group).
- **Taille, date, nom** : 12 octets, date de modification, chemin.

---

## 2.2 Modifier les permissions : chmod

- **Symbolique** : `chmod u+x script.sh` (ajouter l’exécution au propriétaire).
- **Numérique** : r=4, w=2, x=1. Ex. : `chmod 755 script.sh` → rwxr-xr-x.

```bash
chmod 644 fichier.txt   # rw-r--r--
chmod 750 script.sh     # rwxr-x--- (propriétaire tout, groupe lecture+exécution)
```

---

## 2.3 Propriétaire et groupe : chown, chgrp

```bash
# Changer le propriétaire (nécessite souvent root)
sudo chown utilisateur:fichier monfichier

# Changer le groupe
sudo chgrp groupe monfichier
# ou
sudo chown :groupe monfichier
```

> **ATTENTION** — Sur un cluster partagé, ne pas ouvrir largement les droits (ex. 777) pour éviter les risques de sécurité. Privilégier groupe et ACL si besoin.

---

## 2.4 À retenir

- **Répertoire** : `x` = droit d’entrée et d’accéder aux métadonnées ; sans `x` on ne peut pas lister le contenu même avec `r`.
- Les **scripts exécutables** doivent avoir le bit `x` (ex. `chmod +x script.sh`).
- Dans le projet hpc-cluster, les configs sous `configs/` sont souvent lues par des services (Slurm, Prometheus) ; les droits sont gérés par le déploiement (Docker, scripts).

---

## Exercices

Voir `exercises/ch01-exercises.md` (section Chapitre 2). Corrigés dans `solutions/ch01-solutions.md`.
