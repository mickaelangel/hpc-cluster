# 🔧 Infrastructure as Code — Terraform, Ansible

> **Provisionnement et configuration du cluster en code (Terraform, Ansible)**

---

## 🎯 Vue d'ensemble

**Infrastructure as Code (IaC)** : décrire et gérer l'infrastructure (réseau, VMs, stockage, config) dans des fichiers versionnés, pour reproductibilité et collaboration.

| Outil | Rôle |
|--------|--------|
| **Terraform** | Provisionnement déclaratif (cloud, VMs, réseaux) |
| **Ansible** | Configuration des nœuds (packages, services, fichiers) |

---

## Terraform

### Bénéfices

- ✅ **Reproductibilité** : même infra partout
- ✅ **Versioning** : historique Git
- ✅ **Idempotence** : `terraform apply` multiple sans effet de bord

### Structure type

```
terraform/
├── main.tf          # Configuration principale
├── variables.tf     # Variables
├── outputs.tf       # Sorties
├── terraform.tfstate # État (généré, à sécuriser)
└── modules/         # Modules réutilisables
```

### Commandes de base

```bash
terraform init      # Initialiser (backend, providers)
terraform plan      # Prévoir les changements
terraform apply     # Appliquer
terraform destroy   # Détruire les ressources
```

### Installation (cluster)

```bash
./scripts/iac/install-terraform.sh
terraform version
```

---

## Ansible

- **Inventaire** : liste des nœuds (frontaux, compute)
- **Playbooks** : tâches (installer paquets, déployer config, redémarrer services)
- **Rôles** : réutilisation (slurm, monitoring, auth)

Exemple d’usage : déploiement Slurm, configuration FreeIPA, déploiement des exporters Prometheus.

---

## 📚 Documentation complète

- **Guide Terraform / IaC** : [docs/GUIDE_TERRAFORM_IAC.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_TERRAFORM_IAC.md)
- **Guide infrastructure professionnelle** : [docs/GUIDE_INFRASTRUCTURE_PROFESSIONNELLE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_INFRASTRUCTURE_PROFESSIONNELLE.md)

---

## Voir aussi

- **[CI/CD](CI-CD)** — Pipelines et automatisation
- **[Monitoring](Monitoring)** — Observabilité
- **[Guide Administrateur](Guide-Administrateur)** — Administration du cluster
- **[Home](Home)** — Accueil du wiki

---

[← Accueil](Home)
