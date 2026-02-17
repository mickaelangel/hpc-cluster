# Guide Démo – Cluster HPC

Document de référence pour présenter le cluster HPC en conditions professionnelles.

---

## 1. Prérequis et démarrage

### Démarrer tout le cluster (démo)

```bash
cd "/home/teamhpc/Videos/hpc docker/cluster hpc"

# Stack Docker (monitoring + nœuds)
sudo docker compose -f docker/docker-compose-opensource.yml up -d

# FreeIPA (identité) – premier démarrage : 5–10 min
sudo bash scripts/install-freeipa.sh

# Services locaux (déjà installés, redémarrage si besoin)
sudo systemctl start munge slurmctld slurmd glusterd
sudo gluster volume start gv_hpc 2>/dev/null || true
```

### Vérification santé

```bash
sudo bash scripts/tests/test-cluster-health.sh
```

### Mettre tous les voyants au vert (avant démo)

Si le test affiche des avertissements (FreeIPA, Kerberos, GlusterFS, Prometheus, Grafana) :

1. **Démarrer tout le cluster** (Docker + FreeIPA + GlusterFS) :
   ```bash
   sudo ./cluster-start.sh
   ```

2. **Si GlusterFS n’est pas installé** (« Aucun FS distribué ») :
   ```bash
   sudo bash scripts/storage/install-glusterfs.sh
   ```

3. **Si FreeIPA n’apparaît pas** (conteneur pas encore créé) :
   ```bash
   sudo bash scripts/install-freeipa.sh
   ```
   Attendre 5–10 min puis relancer le test.

4. **Relancer la vérification** :
   ```bash
   sudo bash scripts/tests/test-cluster-health.sh
   ```

Le script de santé détecte désormais Prometheus et Grafana par HTTP (ports 9090 et 3000), et FreeIPA/LDAP par le port 389, même si Docker n’est pas visible (ex. exécution sous sudo).

---

## 2. Accès et identifiants (démo)

| Service | URL | Identifiant | Mot de passe |
|--------|-----|-------------|--------------|
| **Grafana** | http://localhost:3000 | admin | admin (ou demo-hpc-2024 selon config) |
| **Prometheus** | http://localhost:9090 | — | — |
| **JupyterHub** | http://localhost:8000 | démo | jupyter-demo |
| **FreeIPA** | https://ipa.cluster.local ou https://localhost | admin | AdminPassword123! |

---

## 3. Ordre recommandé pour la démo

1. **Monitoring** – Montrer Grafana (dashboards) et Prometheus (cibles, métriques).
2. **Calcul** – Slurm : `sinfo`, `squeue`, soumission d’un job (`srun hostname`).
3. **Stockage distribué** – GlusterFS : `gluster volume status`, montage optionnel de `gv_hpc`.
4. **Identité** – FreeIPA (si le conteneur est prêt) : interface web, utilisateurs/groupes.
5. **Notebooks** – JupyterHub : connexion et lancement d’un notebook.
6. **Santé globale** – Lancer `scripts/tests/test-cluster-health.sh` et commenter le résumé.

---

## 4. Commandes utiles

```bash
# État des conteneurs
sudo docker ps --format "table {{.Names}}\t{{.Status}}"

# Logs FreeIPA (suivi installation)
sudo docker logs -f freeipa-server

# Slurm
sinfo
squeue
srun -N1 hostname

# GlusterFS
sudo gluster volume status
```

---

## 5. Réinstallation propre FreeIPA (si besoin)

En cas d’échec d’installation (ex. IPv6) ou pour repartir de zéro :

```bash
FORCE_REINSTALL=1 sudo bash scripts/install-freeipa.sh
```

Le script supprime le conteneur et les données IPA puis recrée le conteneur avec les correctifs (IPv6 désactivé, cgroupns=host).

---

## 6. Arrêt propre

```bash
sudo gluster volume stop gv_hpc 2>/dev/null || true
sudo systemctl stop slurmd slurmctld
sudo docker compose -f docker/docker-compose-opensource.yml down
sudo docker stop freeipa-server 2>/dev/null || true
```

---

*Document maintenu par l’équipe HPC – cluster 100 % open-source.*
