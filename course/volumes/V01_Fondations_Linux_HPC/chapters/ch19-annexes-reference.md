# Chapitre 19 — Annexes (référence commandes, FHS)

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Fournir une référence condensée des commandes vues dans le volume (sans remplacer man).
- Rappeler l’arborescence FHS (répertoires principaux : /, /etc, /var, /usr, /home).
- Tableaux de synthèse (options courantes tar, find, grep, chmod, etc.).
- Renvoyer aux manpages et à la documentation officielle pour le détail.

---

## Prérequis

- Avoir parcouru les chapitres 1–18.

---

## Plan détaillé

1. **FHS (Filesystem Hierarchy Standard)** — tableau /, /bin, /etc, /home, /var, /usr, /tmp ; rôle de chaque répertoire.
2. **Commandes fichiers et répertoires** — ls, cd, pwd, cp, mv, rm, mkdir, touch ; options courantes.
3. **Commandes permissions et propriété** — chmod, chown, chgrp ; forme symbolique et numérique.
4. **Commandes processus** — ps, top, kill, killall ; signaux courants.
5. **Commandes paquets (openSUSE)** — zypper refresh, search, install, update, remove ; rpm -qa, -ql, -qf.
6. **Commandes services (systemd)** — systemctl status, start, stop, enable, disable ; journalctl.
7. **Commandes réseau** — ip, ss, ping, curl ; exemples basiques.
8. **Commandes recherche et filtres** — find, grep, xargs ; options essentielles.
9. **Archives et compression** — tar, gzip, xz ; combinaisons courantes.
10. **Références** — liste des manpages à consulter ; liens docs distribution (openSUSE).

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–9 sous forme de tableaux et listes — 15–25 pp.
- [ ] **TODO** : Pas de contenu spécifique au dépôt inventé ; si exemples cluster, renvoyer à SOURCE_INDEX.

---

## Exercices

**Facile** : Retrouver dans cette annexe la syntaxe de chmod en numérique pour rwxr-xr-x.

**Moyen** : Construire un aide-mémoire personnel (1 page) à partir de cette annexe.

**Challenge** : Comparer cette annexe au sommaire des chapitres ; identifier une commande vue en cours non listée ici et l’ajouter (proposition de mise à jour).

---

## Validation

- Utiliser l’annexe pour retrouver rapidement une option (ex. find -mtime, grep -E).
- Aucune exécution sensible ; référence uniquement.

---

## Références

- `man hier` (FHS) ; manpages des commandes listées
- https://refspecs.linuxfoundation.org/FHS.html (FHS)
- Documentation openSUSE (ou distribution cible) — pas de copier-coller.
