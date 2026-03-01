# Checklist PROD — Hardening et exploitation

> **Objectif** : Préparer le déploiement en **production** (sécurité, secrets, sauvegardes, upgrade/rollback).  
> **Public** : Administrateurs, DevOps.

---

## Sommaire

1. [Secrets et variables](#secrets-et-variables)
2. [Hardening (résumé)](#hardening-résumé)
3. [Sauvegardes](#sauvegardes)
4. [Upgrade et rollback](#upgrade-et-rollback)
5. [Vérifications avant mise en prod](#vérifications-avant-mise-en-prod)

---

## Secrets et variables

- [ ] Copier `.env.example` vers `.env` et **ne jamais commiter** `.env`.
- [ ] Remplacer toutes les valeurs par des secrets forts (Grafana, InfluxDB, etc.).
- [ ] En prod : exécuter `HPC_MODE=prod bash scripts/check-env-prod.sh` avant de lancer le compose.
- [ ] Ne pas utiliser les identifiants “démo” (voir [Quickstart DEMO](Quickstart-DEMO)).
- [ ] Documenter où sont stockés les secrets (gestionnaire de mots de passe, coffre) sans les écrire dans la doc.

**Lancer en prod** :

```bash
cp .env.example .env
# Éditer .env avec des mots de passe forts
make up-prod
# ou
docker compose -f docker/docker-compose-opensource.yml -f docker/docker-compose.prod.yml up -d
```

---

## Hardening (résumé)

- [ ] **SSH** : Désactiver `PermitRootLogin` et `PasswordAuthentication` sur les frontaux ; utiliser clés SSH.
- [ ] **Firewall** : Restreindre les ports exposés (3000, 9090, 8086, 2222, 2223) aux IP autorisées.
- [ ] **Réseau** : Isoler les réseaux management / cluster / stockage ; pas d’exposition directe des conteneurs à Internet si possible.
- [ ] **Mises à jour** : Planifier les mises à jour des images Docker et du système hôte (openSUSE 15.6).
- [ ] **Compliance** : Appliquer les bonnes pratiques (CIS, durcissement OS) selon la politique interne.

Détails : [Sécurité](Securite), [Guide Administrateur](Guide-Administrateur), README section « Mode démo vs production ».

---

## Sauvegardes

- [ ] **Volumes Docker** : `prometheus_data`, `grafana_data`, `influxdb_data`, `loki_data`, `jupyterhub_data` — définir une stratégie de sauvegarde (fréquence, rétention).
- [ ] **Configurations** : Sauvegarder `configs/`, `docker/*.yml`, `.env` (hors dépôt) et les clés.
- [ ] **Slurm** : État et config Slurm (si persistant) ; sauvegarder selon la doc Slurm.
- [ ] **Tests de restauration** : Tester régulièrement la restauration à partir des sauvegardes.

Scripts utiles (si présents dans le repo) : `scripts/backup/`, voir aussi [Maintenance](Maintenance).

---

## Upgrade et rollback

- [ ] **Images Docker** : Pincer les versions dans `docker-compose*.yml` ; tester les mises à jour en staging avant prod.
- [ ] **Rollback** : Garder les anciennes images/tags disponibles ; procédure documentée pour `docker compose down` puis `up` avec anciennes versions.
- [ ] **Slurm** : Suivre la doc officielle pour upgrade slurmctld/slurmd ; planifier fenêtre de maintenance.
- [ ] **Données** : Avant upgrade majeur, sauvegarder volumes et configs.

---

## Vérifications avant mise en prod

- [ ] `HPC_MODE=prod scripts/check-env-prod.sh` OK.
- [ ] Aucun identifiant démo dans `.env`.
- [ ] Firewall et accès SSH (clés uniquement) configurés.
- [ ] Sauvegardes et stratégie de rétention définies.
- [ ] Monitoring et alertes opérationnels (Prometheus/Grafana).
- [ ] Documentation interne : qui fait quoi, contacts, runbooks.

---

## Références

- [Status / Scope](Status-Scope) — ce qui est implémenté dans le repo
- [README](https://github.com/mickaelangel/hpc-cluster/blob/main/README.md) — section « Mode démo vs production »
- [Dépannage](Depannage) · [Troubleshooting](Troubleshooting)
