# Exercices — Chapitres 1 et 2 (V01)

---

## Chapitre 1 — Introduction Linux et CLI

**Ex 1.1** — Dans un terminal, exécutez `pwd`, `ls -la`, puis `cd /etc` et `ls -la`. Quel répertoire contient les fichiers de configuration des services réseau ?

**Ex 1.2** — Sans quitter `/etc`, affichez le contenu du fichier `hostname`. Quelle commande utilisez-vous ?

**Ex 1.3** — Avec `find`, listez les fichiers dont le nom se termine par `.conf` dans `/etc` (limiter à 10 résultats). Indiquez la commande exacte.

**Ex 1.4** — Quelle est la différence entre un chemin absolu et un chemin relatif ? Donnez un exemple de chaque pour accéder au répertoire `/home`.

---

## Chapitre 2 — Système de fichiers et permissions

**Ex 2.1** — Interprétez la sortie suivante : `drwxr-xr-x 2 root root 4096 Jan 15 10:00 scripts`. Qui peut écrire dans ce répertoire ?

**Ex 2.2** — Vous voulez qu’un script `mon_script.sh` soit exécutable par le propriétaire uniquement (lecture+écriture+exécution), et lisible par le groupe et les autres. Donnez la commande `chmod` (forme numérique).

**Ex 2.3** — Pourquoi ne faut-il pas utiliser `chmod 777` sur un répertoire partagé en production ?

---

*Corrigés : voir `solutions/ch01-solutions.md`.*
