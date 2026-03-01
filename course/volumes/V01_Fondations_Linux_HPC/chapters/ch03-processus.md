# Chapitre 3 — Processus et gestion des tâches

**Objectifs** : Comprendre ce qu’est un processus ; utiliser `ps`, `top`, `htop` ; envoyer des signaux (`kill`, `killall`).  
**Prérequis** : Chapitres 1–2. **Durée** : ~1 h.

---

## 3.1 Processus et PID

- Chaque programme en cours d’exécution est un **processus**, identifié par un **PID** (Process ID).
- Le processus père (souvent le shell) a un **PPID** (Parent PID).

```bash
ps -ef | head -10
ps aux | grep prometheus
```

---

## 3.2 Consulter l’état du système : top, htop

```bash
top          # Vue temps réel (tri par défaut : CPU)
htop         # Interface plus lisible (si installé)
```

Colonnes utiles : PID, USER, %CPU, %MEM, COMMAND.

---

## 3.3 Signaux et arrêt de processus

```bash
kill -15 PID   # SIGTERM (terminaison propre)
kill -9 PID    # SIGKILL (forcé, à utiliser en dernier recours)
killall -9 nom_processus
```

> **NOTE** — Sur un cluster, les jobs Slurm envoient des signaux pour limiter le temps ou arrêter un job ; l’utilisateur n’a pas à tuer manuellement les processus des autres.

---

## 3.4 Validation

- Lancer `top`, identifier le PID du processus `top` lui-même.
- Utiliser `ps aux | grep $USER` pour lister vos processus.
