# Chapitre 16 — Lab 3 : Configuration réseau avancée

**Cible** : 10–30 pages (lab guidé, ~3 000–12 000 mots).

---

## Objectifs

- Configurer une interface réseau (adresse IP, masque) avec ip ou nmcli (générique Linux).
- Vérifier la connectivité (ping, curl) et les ports en écoute (ss, netstat).
- Appliquer des règles firewall de base (firewalld ou iptables — selon distribution).
- Préparer l’usage de SSH (clés) pour la suite ; pas de secret en clair.

---

## Prérequis

- Chapitres 1–2, 6 (CLI, fichiers, réseau de base).
- Accès root ou sudo ; machine ou VM de test.

---

## Plan détaillé

1. **Objectifs du lab** — rappel des compétences visées.
2. **Prérequis et durée** — environnement, 45 min – 1 h 30.
3. **Étape 1** — Vérifier la configuration réseau actuelle (ip addr, ip route).
4. **Étape 2** — Modifier une adresse IP (ex. interface secondaire ou temporaire) ; vérifier avec ping.
5. **Étape 3** — Lister les ports en écoute (ss -tlnp) ; tester un service (curl).
6. **Étape 4** — Firewall : ouvrir/fermer un port (ex. firewalld --add-port) ; documenter la commande générique.
7. **Validation** — checklist : IP visible, ping OK, port atteignable.
8. **Troubleshooting** — 3–5 pannes courantes (interface down, firewall bloque, mauvais masque) + cause + correctif.
9. **Références** — man ip, man ss, doc firewalld/iptables (distribution).

---

## À écrire

- [ ] **TODO** : Rédiger étapes 1–7 avec commandes complètes et sorties types — 8–15 pp.
- [ ] **TODO** : Rédiger section 8 (troubleshooting) — 2–4 pp.
- [ ] **TODO** : Ne pas inventer de topologie spécifique au dépôt ; si référence au cluster (frontal-01, compute-01), s’appuyer uniquement sur configs existantes (IP dans slurm.conf, docker-compose).

---

## Exercices (optionnel en fin de lab)

**Facile** : Refaire les étapes sur une seconde machine ou VM ; documenter les commandes.

**Moyen** : Configurer deux VM pour qu’elles se pingent ; vérifier qu’un port (ex. 22) est accessible.

**Challenge** : Rédiger un mini-runbook « vérification réseau d’un nœud » (5–10 commandes) sans données sensibles.

---

## Validation

```bash
ip addr show
ip route show
ping -c 2 <gateway_or_peer>
ss -tlnp
# Selon distribution :
# firewall-cmd --list-all
```

---

## Références

- `man ip`, `man ss`, `man firewall-cmd` (si firewalld)
- Documentation distribution (réseau, firewall) — pas d’invention sur le dépôt.
