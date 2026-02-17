# Identifiants Grafana - Cluster HPC

**Date de mise à jour** : 2025-02-15

---

## 🔐 Identifiants de Connexion

- **URL** : http://localhost:3000
- **Login** : `admin`
- **Mot de passe** : `$Password!2026`

---

## 📝 Notes

- Le mot de passe a été configuré dans `docker/docker-compose-opensource.yml`
- Pour appliquer le changement, redémarrer le conteneur Grafana :
  ```powershell
  docker restart hpc-grafana
  ```

---

## 🔒 Sécurité

⚠️ **Important** : Changez ce mot de passe en production !

Pour changer le mot de passe via l'interface Grafana :
1. Connectez-vous avec les identifiants ci-dessus
2. Allez dans Configuration → Users → Admin
3. Changez le mot de passe

---

**Version** : 1.0
