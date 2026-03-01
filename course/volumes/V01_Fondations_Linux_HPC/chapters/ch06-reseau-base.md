# Chapitre 6 — Réseau de base (IP, ping, curl)

**Objectifs** : Vérifier la connectivité (**ping**, **curl**) ; comprendre les notions d’IP, port, résolution de noms.  
**Prérequis** : Chapitres 1–5. **Durée** : ~45 min.

---

## 6.1 Adresses et ports

- **IP** : identifiant d’une interface réseau (ex. 172.20.0.101 pour frontal-01 dans le projet).
- **Port** : numéro de 1 à 65535 pour une application (ex. 9090 Prometheus, 3000 Grafana).

```bash
ip addr show
ss -tlnp   # Ports en écoute
```

---

## 6.2 ping et curl

```bash
ping -c 3 172.20.0.101
curl -s http://localhost:9090/-/healthy   # Prometheus
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health  # Grafana
```

---

## 6.3 Lien avec le cluster

Dans `configs/slurm/slurm.conf`, les nœuds ont des **NodeAddr** (172.20.0.101, 172.20.0.201 …). La connectivité entre frontal et compute est nécessaire pour que Slurm fonctionne.
