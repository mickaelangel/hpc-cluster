#!/usr/bin/env python3
"""
Génère les squelettes des volumes V03-V40 (nouveaux noms).
Usage: depuis course/ : python scripts/gen_volumes_skeletons.py
"""
import os

VOLUMES = [
    ("V03", "Reseaux_Linux_HPC", "Réseaux Linux pour HPC", "Licence", "V01", "TCP/IP, DNS, routage, firewall, diag, perf réseau."),
    ("V04", "Stockage_Linux_FHS", "Stockage Linux & FHS", "Licence", "V01", "Partitions, LVM, FS (ext4/xfs), permissions, quotas, FHS."),
    ("V05", "Bash_Automation_Pro", "Bash & automation pro", "Licence", "V01", "Bash avancé, bonnes pratiques, robustesse, CLI UX."),
    ("V06", "Packaging_Build_Toolchain", "Gestion logiciels & build toolchain", "Licence", "V01", "Paquets, dépôts, compilation, libs, ABI, env."),
    ("V07", "Securite_Linux_Base", "Sécurité Linux de base", "Licence", "V01", "SSH, sudo, PAM, audit, principes de durcissement."),
    ("V08", "Architecture_HPC_Cluster", "Architecture HPC & principes cluster", "Licence", "V01", "Nœuds, réseaux, stockage, services, notions."),
    ("V09", "Slurm_Fondamentaux", "Slurm fondamentaux", "Licence", "V01, V08", "srun/sbatch/squeue, états, partitions, premières politiques."),
    ("V10", "Modules_Environnements", "Environnements & modules", "Licence", "V01, V09", "Modules (Lmod), env, conda, reproductibilité."),
    ("V11", "Conteneurs_Admins", "Conteneurs pour admins", "Licence", "V01", "Docker/Podman : images, compose, réseaux/volumes, sécurité."),
    ("V12", "Observabilite_Logs_Metriques", "Observabilité 1 : logs & métriques", "Licence", "V01, V11", "Logging, métriques, alerting basique."),
    ("V13", "Debug_Diagnostic_Linux", "Debug & diagnostic Linux", "Licence", "V01", "strace/lsof, perf de base, sysctl, analyse incidents."),
    ("V14", "Projet_Licence_Cluster_LAB", "Projet Licence : cluster LAB complet", "Licence", "V01-V13", "Mise en place + validation + doc/runbook."),
    ("V15", "Slurm_Avance_Config_Ops", "Slurm avancé : config & ops", "Master", "V09", "slurm.conf, nœuds, HA notions, munge, tuning."),
    ("V16", "Scheduling_QoS_Fairshare", "Scheduling, QoS & fair-share", "Master", "V15", "Priorités, limites, accounting, politiques."),
    ("V17", "MPI_Pour_Admins", "MPI pour admins & support", "Master", "V09", "Bases, runtimes, debug, erreurs typiques."),
    ("V18", "GPU_HPC_Exploitation", "GPU en HPC : exploitation", "Master", "V15", "Drivers, visibilité, scheduling GPU, diag."),
    ("V19", "Stockage_Distribue_Concepts", "Stockage distribué : concepts & mise en œuvre", "Master", "V04, V10", "Ceph/Gluster/GPFS (concepts, choix, ops)."),
    ("V20", "Performance_Linux_CPU_NUMA_IO", "Performance Linux : CPU/NUMA/I/O", "Master", "V01", "Topo, irq, NUMA, I/O path, tuning."),
    ("V21", "Prometheus_Grafana", "Observabilité 2 : Prometheus & Grafana", "Master", "V12, V15", "Scraping, labels, dashboards, alerting."),
    ("V22", "Loki_Promtail_Logs", "Logs modernes : Loki/Promtail", "Master", "V12, V21", "Pipelines, parsers, corrélations."),
    ("V23", "InfluxDB_Telegraf", "Time-series : InfluxDB/Telegraf", "Master", "V21", "Modèles, retention, perf, intégrations."),
    ("V24", "Ansible_Cluster", "IaC 1 : Ansible pour cluster", "Master", "V01, V15", "Rôles, inventaires, idempotence, patterns."),
    ("V25", "Terraform_Provisioning", "IaC 2 : Terraform & provisioning", "Master", "V24", "State, modules, cloud-init, gitops."),
    ("V26", "CICD_Release_Engineering", "CI/CD & release engineering", "Master", "V24", "Tests, lint, pipelines, versioning."),
    ("V27", "Securite_Avancee_PKI_TLS_Secrets", "Sécurité avancée : PKI/TLS/secrets", "Master", "V07", "Certificats, rotation, vault patterns."),
    ("V28", "IAM_LDAP_FreeIPA_Kerberos", "IAM : LDAP/FreeIPA/Kerberos", "Master", "V07, V15", "Authn/authz, SSO, intégration Linux."),
    ("V29", "Backup_DR_Capacity", "Sauvegarde, DR & capacity planning", "Master", "V19, V24", "RPO/RTO, stratégie, tests de restore."),
    ("V30", "SRE_HPC_SLO_Incidents", "SRE HPC : SLO, incidents, runbooks", "Master", "V21, V26", "SLO, alert fatigue, postmortems."),
    ("V31", "Theorie_Scheduling_Fairness", "Théorie du scheduling & fairness", "Doctorat", "V16", "Modèles, métriques, compromis."),
    ("V32", "Green_HPC_Energy_Aware", "Energy-aware scheduling & Green HPC", "Doctorat", "V16, V31", "Énergie, DVFS, contraintes CO₂, politiques."),
    ("V33", "Data_Management_Scale", "Data management at scale", "Doctorat", "V19", "Objets, hiérarchies, data lifecycle."),
    ("V34", "Chaos_Engineering_HPC", "Fiabilité : chaos engineering HPC", "Doctorat", "V29, V30", "Injections de pannes, méthodo, garde-fous."),
    ("V35", "Benchmarking_Reproductibilite", "Benchmarking & reproductibilité", "Doctorat", "V20, V33", "Protocoles, stats, biais, reporting."),
    ("V36", "Zero_Trust_HPC", "Zero Trust appliqué au HPC", "Doctorat", "V28", "Segmentation, identité, posture device."),
    ("V37", "AIOps_Anomalies", "AIOps : détection d'anomalies", "Doctorat", "V21, V30", "Signaux, features, seuils vs ML, évaluation."),
    ("V38", "Gouvernance_MultiTenant", "Gouvernance multi-tenant & conformité", "Doctorat", "V28, V30", "Politiques, traçabilité, contrôle."),
    ("V39", "Exascale_Interconnexions", "Tendances exascale & interconnexions", "Doctorat", "V08, V17", "Topo réseau, RDMA concepts, limites."),
    ("V40", "Projet_Doctoral_Etude", "Projet doctoral : étude complète publiable", "Doctorat", "V31-V39", "Protocole + résultats + artefacts."),
]

CHAPTERS = [
    ("ch01-introduction.md", "Introduction", False),
    ("ch02-concepts.md", "Concepts de base", False),
    ("ch03-theme-a.md", "Thème principal 1", False),
    ("ch04-theme-b.md", "Thème principal 2", False),
    ("ch05-theme-c.md", "Thème principal 3", False),
    ("ch06-pratique.md", "Pratique et exemples", False),
    ("ch07-erreurs-troubleshooting.md", "Erreurs et troubleshooting", False),
    ("ch08-lab1.md", "Lab 1", True),
    ("ch09-lab2.md", "Lab 2", True),
    ("ch10-bonnes-pratiques.md", "Bonnes pratiques", False),
    ("ch11-reference.md", "Référence", False),
    ("ch12-synthese.md", "Synthèse", False),
    ("ch13-annexes.md", "Annexes", False),
    ("ch14-evaluation.md", "Évaluation", False),
]

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOLUMES_DIR = os.path.join(BASE, "volumes")

def book_md(vol_id, slug_name, title, niveau, prereq, obj):
    return f"""# Volume {vol_id[-2:]} — {title}

**Niveau** : {niveau}
**Prérequis** : {prereq}
**Objectif** : {obj}

---

> **Cible 400–800 pages**
> [CIBLE_400_800_PAGES.md](../../editorial/CIBLE_400_800_PAGES.md). **État actuel** : structure + squelettes à rédiger.

---

## Table des matières (squelettes à rédiger)

""" + "\n".join(
    f"{i+1}. [Chapitre {i+1} — {ch_title}](chapters/{ch_file}) — cible 20–35 pp" + (" (lab 10–30 pp)" if is_lab else "")
    for i, (ch_file, ch_title, is_lab) in enumerate(CHAPTERS)
) + """

---

## Index rapide

- [CIBLE_400_800_PAGES](../../editorial/CIBLE_400_800_PAGES.md) | [GLOSSARY](../../editorial/GLOSSARY.md) | [BIBLIOGRAPHY](../../editorial/BIBLIOGRAPHY.md) | [SOURCE_INDEX](../../editorial/SOURCE_INDEX.md)
"""

def chapter_md(filename, title, is_lab):
    cible = "10–30 pp (lab)" if is_lab else "20–35 pp"
    return f"""# Chapitre — {title}

**Cible** : {cible}. [CIBLE_400_800_PAGES](../../../editorial/CIBLE_400_800_PAGES.md).

---

## Objectifs
- (3–6 puces à compléter.)

## Prérequis
- Chapitres précédents ; voir book.md.

## Plan détaillé
1. Section 1. 2. Section 2. 3. Exemples. 4. Erreurs fréquentes. 5. Validation. 6. Exercices. 7. À retenir. 8. Références.

## À écrire
- [ ] **TODO** : Rédiger à pleine longueur. Pas d'invention dépôt ; pas de secret.

## Exercices
**Facile** : À rédiger. **Moyen** : À rédiger. **Challenge** : À rédiger.

## Validation
```bash
# Commandes à adapter
```

## Références
- man ; docs officielles. [SOURCE_INDEX](../../../editorial/SOURCE_INDEX.md) si dépôt.
"""

def main():
    for vol_id, slug_name, title, niveau, prereq, obj in VOLUMES:
        vol_dir = os.path.join(VOLUMES_DIR, f"{vol_id}_{slug_name}")
        os.makedirs(vol_dir, exist_ok=True)
        os.makedirs(os.path.join(vol_dir, "chapters"), exist_ok=True)
        os.makedirs(os.path.join(vol_dir, "figures"), exist_ok=True)
        os.makedirs(os.path.join(vol_dir, "assets"), exist_ok=True)

        with open(os.path.join(vol_dir, "book.md"), "w", encoding="utf-8") as f:
            f.write(book_md(vol_id, slug_name, title, niveau, prereq, obj))

        for ch_file, ch_title, is_lab in CHAPTERS:
            with open(os.path.join(vol_dir, "chapters", ch_file), "w", encoding="utf-8") as f:
                f.write(chapter_md(ch_file, ch_title, is_lab))

        for d in ["figures", "assets"]:
            gitkeep = os.path.join(vol_dir, d, ".gitkeep")
            if not os.path.exists(gitkeep):
                with open(gitkeep, "w") as f:
                    pass

    print("Done. Volumes V03-V40 created.")

if __name__ == "__main__":
    main()
