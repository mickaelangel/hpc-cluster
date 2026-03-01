# Chapitre 9 — Lab 2 : Installation d’un service type (Node Exporter)

**Objectif** : Comprendre comment un service de monitoring (Node Exporter) est installé et exposé, en lien avec le cluster.  
**Prérequis** : Chapitres 1–5, 6, 8. **Durée** : 45 min.

---

## 9.1 Contexte

Dans le projet hpc-cluster, **Node Exporter** est utilisé dans les images Docker (frontal, client) pour exposer les métriques système (CPU, RAM, disque) à Prometheus. Ce lab peut être fait soit dans un conteneur, soit sur une VM openSUSE pour reproduire l’installation manuelle.

---

## 9.2 Étapes (installation manuelle sur openSUSE)

1. **Installer Node Exporter** (si disponible dans les dépôts) :
   ```bash
   zypper search node_exporter
   # ou télécharger le binaire depuis https://prometheus.io/download/#node_exporter
   ```

2. **Lancer le service** (ex. en utilisateur ou via systemd) :
   ```bash
   # Exemple : exécution manuelle sur le port 9100
   ./node_exporter --web.listen-address=:9100
   ```

3. **Vérifier** :
   ```bash
   curl -s http://localhost:9100/metrics | head -20
   ```

4. **Dans le projet** : les Dockerfiles sous `docker/frontal/` et `docker/client/` intègrent Node Exporter ; Prometheus scrape les cibles définies dans `configs/prometheus/`. Pas besoin d’installer à la main si vous utilisez les conteneurs.

---

## 9.3 Critères de validation

- Vous avez vu au moins une fois la sortie de `/metrics` (format Prometheus).
- Vous comprenez que Prometheus « scrape » ces métriques à intervalle régulier pour les stocker et les afficher dans Grafana.
