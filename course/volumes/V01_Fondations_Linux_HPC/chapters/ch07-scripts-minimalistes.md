# Chapitre 7 — Édition et scripts minimalistes

**Objectifs** : Éditer un fichier en CLI (nano ou vim basique) ; écrire un script Bash minimal (shebang, variables, exécution).  
**Prérequis** : Chapitres 1–4. **Durée** : ~1 h.

---

## 7.1 Édition

```bash
nano mon_script.sh
# ou vim mon_script.sh
```

Shebang en première ligne : `#!/usr/bin/env bash`

---

## 7.2 Script minimal

```bash
#!/usr/bin/env bash
set -e
echo "Répertoire courant : $(pwd)"
echo "Utilisateur : $USER"
```

Sauvegarder, puis : `chmod +x mon_script.sh` et `./mon_script.sh`.

---

## 7.3 Variables d’environnement

- Ne jamais mettre de **secrets** en clair dans un script. Utiliser des variables d’environnement (ex. `$GF_SECURITY_ADMIN_PASSWORD`) ou un fichier `.env` non versionné (voir projet : `.env.example`, `scripts/check-env-prod.sh`).
