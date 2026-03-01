# Chapitre 17 — Lab 4 : Sécurité de base (utilisateurs, SSH)

**Cible** : 10–30 pages (lab guidé, ~3 000–12 000 mots).

---

## Objectifs

- Créer un utilisateur sans privilèges ; vérifier les permissions sur son home.
- Configurer l’authentification SSH par clé (génération, copie, test) ; pas de mot de passe en clair dans la doc.
- Comprendre les options de durcissement SSH (PermitRootLogin, PasswordAuthentication) en lecture ; ne pas appliquer de changement bloquant sans consigne explicite.
- Bonnes pratiques : clés, permissions ~/.ssh.

---

## Prérequis

- Chapitres 1–2, 10 (CLI, permissions, utilisateurs et groupes).
- Accès root ou sudo ; deux machines ou VM (client + serveur SSH).

---

## Plan détaillé

1. **Objectifs du lab** — rappel des compétences visées.
2. **Prérequis et durée** — 45 min – 1 h 30.
3. **Étape 1** — Créer un utilisateur `labuser` avec home ; vérifier UID, GID, répertoire.
4. **Étape 2** — Générer une paire de clés SSH (ssh-keygen) ; documenter sans afficher de clé privée.
5. **Étape 3** — Copier la clé publique vers le serveur (ssh-copy-id ou copie manuelle) ; se connecter sans mot de passe.
6. **Étape 4** — Vérifier les permissions ~/.ssh (700), ~/.ssh/authorized_keys (600).
7. **Validation** — connexion SSH par clé sans mot de passe ; utilisateur labuser existant.
8. **Troubleshooting** — permissions refusées ; connexion refusée ; clé ignorée (vérifier authorized_keys, selinux si applicable).
9. **Références** — man ssh, man ssh-keygen, man sshd_config ; pas de secret dans la doc.

---

## À écrire

- [ ] **TODO** : Rédiger étapes 1–7 — 8–15 pp.
- [ ] **TODO** : Rédiger troubleshooting — 2–4 pp.
- [ ] **TODO** : Mentionner le dépôt uniquement si pertinent (ex. Dockerfiles avec SSH pour démo ; documenter que en prod on durcit selon Checklist PROD) ; pas d’invention.

---

## Exercices (optionnel)

**Facile** : Se connecter en SSH avec clé depuis une seconde machine ; vérifier que la connexion par mot de passe est encore possible (si non désactivée).

**Moyen** : Désactiver l’authentification par mot de passe pour un utilisateur de test (configuration SSH) ; documenter la marche arrière.

**Challenge** : Rédiger une checklist « sécurisation SSH serveur » (5–10 points) sans exposer de paramètres sensibles.

---

## Validation

```bash
id labuser
ls -la /home/labuser/.ssh
ssh -i ~/.ssh/id_ed25519 labuser@<server> "echo OK"
```

---

## Références

- `man ssh`, `man ssh-keygen`, `man sshd_config`
- Documentation distribution (SSH) ; dépôt : uniquement ce qui existe (ex. wiki Checklist PROD, pas d’invention).
