# Chapitre 5 — Services et systemd (notions)

**Objectifs** : Comprendre les **unités** systemd ; utiliser `systemctl` pour démarrer, arrêter, activer des services ; consulter les logs avec **journalctl**.  
**Prérequis** : Chapitres 1–4. **Durée** : ~1 h.

---

## 5.1 systemctl

```bash
systemctl status nom_service
systemctl start nom_service
systemctl stop nom_service
systemctl enable nom_service   # Démarrage au boot
systemctl disable nom_service
systemctl restart nom_service
```

---

## 5.2 journalctl

```bash
journalctl -u nom_service -n 50 --no-pager
journalctl -u prometheus -f   # Suivi en temps réel
```

---

## 5.3 Contexte Docker vs systemd

Dans le **déploiement Docker** du projet hpc-cluster, Prometheus, Grafana, InfluxDB tournent dans des **conteneurs** ; on utilise `docker ps`, `docker logs` plutôt que `systemctl` sur l’hôte. Sur les **conteneurs** eux-mêmes (frontal, compute), systemd peut être utilisé pour les services internes (slurmd, node_exporter, etc.). Voir [Quickstart DEMO](.github/wiki/Quickstart-DEMO.md) et [Troubleshooting](.github/wiki/Troubleshooting.md).
