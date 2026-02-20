# 🔒 Sécurité — Sécurité avancée

> **Sécurisation complète et monitoring du Cluster HPC Enterprise**

---

## 🎯 Vue d'ensemble

Ce guide couvre la **sécurité avancée** du cluster : firewall, gestion des secrets, certificats SSL/TLS, sécurité des conteneurs, scan de vulnérabilités, conformité et Zero Trust.

---

## Thèmes principaux

| Thème | Description |
|--------|--------------|
| **Firewall** | nftables, firewalld, iptables — règles strictes, rate limiting SSH |
| **Secrets** | Vault — gestion centralisée des secrets |
| **Certificats** | Certbot — SSL/TLS automatiques |
| **Conteneurs** | Falco (runtime), Trivy (scan images Docker) |
| **Vulnérabilités** | Scans et remédiation |
| **Compliance** | DISA STIG, CIS Level 2, ANSSI BP-028 |
| **MFA** | Authentification multi-facteur (TOTP, YubiKey) |
| **RBAC** | Permissions granulaires |
| **Zero Trust** | Micro-segmentation, chiffrement (ex. InfiniBand) |

---

## Firewall (exemple)

```bash
# Installation / configuration
./scripts/security/configure-firewall.sh

# Vérification
nft list ruleset
firewall-cmd --list-all
iptables -L -n -v
```

---

## 📚 Documentation complète

- **Guide sécurité avancée** : [docs/GUIDE_SECURITE_AVANCEE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_SECURITE_AVANCEE.md)
- **Guide sécurité** : [docs/GUIDE_SECURITE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_SECURITE.md)
- **Sécurité niveau maximum** : [docs/SECURITE_NIVEAU_MAXIMUM.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/SECURITE_NIVEAU_MAXIMUM.md)
- **Automatisation sécurité** : [docs/GUIDE_AUTOMATISATION_SECURITE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_AUTOMATISATION_SECURITE.md)

---

## Voir aussi

- **[Guide Administrateur](Guide-Administrateur)** — Administration complète
- **[Maintenance](Maintenance)** — Opérations et procédures
- **[Monitoring](Monitoring)** — Observabilité et dashboards sécurité
- **[Home](Home)** — Accueil du wiki

---

[← Accueil](Home)
