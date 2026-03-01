# Collection des 40 volumes — Cours HPC

Cette arborescence contient les **40 volumes** de la collection (Licence → Master → Doctorat) sur l’administration HPC, l’observabilité, la sécurité et l’exploitation de clusters.

**Plan** : [CROSS_REFERENCE_MAP.md](../editorial/CROSS_REFERENCE_MAP.md). **Convention 400–800 pp** : [CIBLE_400_800_PAGES.md](../editorial/CIBLE_400_800_PAGES.md).

---

## Statut des volumes (V01 + V02→V40 squelettes)

| Vol | Dossier | Titre | Niveau | Statut |
|-----|---------|--------|--------|--------|
| V01 | [V01_Fondations_Linux_HPC](V01_Fondations_Linux_HPC/) | Fondations Linux pour HPC | Licence | ✅ Rédigé (ch. 1–9 + squelettes ch. 10–20) |
| V02 | [V02_Linux_Avance_Admins](V02_Linux_Avance_Admins/) | Linux avancé pour admins | Licence | Structure + squelettes |
| V03 | [V03_Reseaux_Linux_HPC](V03_Reseaux_Linux_HPC/) | Réseaux Linux pour HPC | Licence | Structure + squelettes |
| V04 | [V04_Stockage_Linux_FHS](V04_Stockage_Linux_FHS/) | Stockage Linux & FHS | Licence | Structure + squelettes |
| V05 | [V05_Bash_Automation_Pro](V05_Bash_Automation_Pro/) | Bash & automation pro | Licence | Structure + squelettes |
| V06 | [V06_Packaging_Build_Toolchain](V06_Packaging_Build_Toolchain/) | Gestion logiciels & build toolchain | Licence | Structure + squelettes |
| V07 | [V07_Securite_Linux_Base](V07_Securite_Linux_Base/) | Sécurité Linux de base | Licence | Structure + squelettes |
| V08 | [V08_Architecture_HPC_Cluster](V08_Architecture_HPC_Cluster/) | Architecture HPC & principes cluster | Licence | Structure + squelettes |
| V09 | [V09_Slurm_Fondamentaux](V09_Slurm_Fondamentaux/) | Slurm fondamentaux | Licence | Structure + squelettes |
| V10 | [V10_Modules_Environnements](V10_Modules_Environnements/) | Environnements & modules | Licence | Structure + squelettes |
| V11 | [V11_Conteneurs_Admins](V11_Conteneurs_Admins/) | Conteneurs pour admins | Licence | Structure + squelettes |
| V12 | [V12_Observabilite_Logs_Metriques](V12_Observabilite_Logs_Metriques/) | Observabilité 1 : logs & métriques | Licence | Structure + squelettes |
| V13 | [V13_Debug_Diagnostic_Linux](V13_Debug_Diagnostic_Linux/) | Debug & diagnostic Linux | Licence | Structure + squelettes |
| V14 | [V14_Projet_Licence_Cluster_LAB](V14_Projet_Licence_Cluster_LAB/) | Projet Licence : cluster LAB complet | Licence | Structure + squelettes |
| V15 | [V15_Slurm_Avance_Config_Ops](V15_Slurm_Avance_Config_Ops/) | Slurm avancé : config & ops | Master | Structure + squelettes |
| V16 | [V16_Scheduling_QoS_Fairshare](V16_Scheduling_QoS_Fairshare/) | Scheduling, QoS & fair-share | Master | Structure + squelettes |
| V17 | [V17_MPI_Pour_Admins](V17_MPI_Pour_Admins/) | MPI pour admins & support | Master | Structure + squelettes |
| V18 | [V18_GPU_HPC_Exploitation](V18_GPU_HPC_Exploitation/) | GPU en HPC : exploitation | Master | Structure + squelettes |
| V19 | [V19_Stockage_Distribue_Concepts](V19_Stockage_Distribue_Concepts/) | Stockage distribué : concepts & mise en œuvre | Master | Structure + squelettes |
| V20 | [V20_Performance_Linux_CPU_NUMA_IO](V20_Performance_Linux_CPU_NUMA_IO/) | Performance Linux : CPU/NUMA/I/O | Master | Structure + squelettes |
| V21 | [V21_Prometheus_Grafana](V21_Prometheus_Grafana/) | Observabilité 2 : Prometheus & Grafana | Master | Structure + squelettes |
| V22 | [V22_Loki_Promtail_Logs](V22_Loki_Promtail_Logs/) | Logs modernes : Loki/Promtail | Master | Structure + squelettes |
| V23 | [V23_InfluxDB_Telegraf](V23_InfluxDB_Telegraf/) | Time-series : InfluxDB/Telegraf | Master | Structure + squelettes |
| V24 | [V24_Ansible_Cluster](V24_Ansible_Cluster/) | IaC 1 : Ansible pour cluster | Master | Structure + squelettes |
| V25 | [V25_Terraform_Provisioning](V25_Terraform_Provisioning/) | IaC 2 : Terraform & provisioning | Master | Structure + squelettes |
| V26 | [V26_CICD_Release_Engineering](V26_CICD_Release_Engineering/) | CI/CD & release engineering | Master | Structure + squelettes |
| V27 | [V27_Securite_Avancee_PKI_TLS_Secrets](V27_Securite_Avancee_PKI_TLS_Secrets/) | Sécurité avancée : PKI/TLS/secrets | Master | Structure + squelettes |
| V28 | [V28_IAM_LDAP_FreeIPA_Kerberos](V28_IAM_LDAP_FreeIPA_Kerberos/) | IAM : LDAP/FreeIPA/Kerberos | Master | Structure + squelettes |
| V29 | [V29_Backup_DR_Capacity](V29_Backup_DR_Capacity/) | Sauvegarde, DR & capacity planning | Master | Structure + squelettes |
| V30 | [V30_SRE_HPC_SLO_Incidents](V30_SRE_HPC_SLO_Incidents/) | SRE HPC : SLO, incidents, runbooks | Master | Structure + squelettes |
| V31 | [V31_Theorie_Scheduling_Fairness](V31_Theorie_Scheduling_Fairness/) | Théorie du scheduling & fairness | Doctorat | Structure + squelettes |
| V32 | [V32_Green_HPC_Energy_Aware](V32_Green_HPC_Energy_Aware/) | Energy-aware scheduling & Green HPC | Doctorat | Structure + squelettes |
| V33 | [V33_Data_Management_Scale](V33_Data_Management_Scale/) | Data management at scale | Doctorat | Structure + squelettes |
| V34 | [V34_Chaos_Engineering_HPC](V34_Chaos_Engineering_HPC/) | Fiabilité : chaos engineering HPC | Doctorat | Structure + squelettes |
| V35 | [V35_Benchmarking_Reproductibilite](V35_Benchmarking_Reproductibilite/) | Benchmarking & reproductibilité | Doctorat | Structure + squelettes |
| V36 | [V36_Zero_Trust_HPC](V36_Zero_Trust_HPC/) | Zero Trust appliqué au HPC | Doctorat | Structure + squelettes |
| V37 | [V37_AIOps_Anomalies](V37_AIOps_Anomalies/) | AIOps : détection d'anomalies | Doctorat | Structure + squelettes |
| V38 | [V38_Gouvernance_MultiTenant](V38_Gouvernance_MultiTenant/) | Gouvernance multi-tenant & conformité | Doctorat | Structure + squelettes |
| V39 | [V39_Exascale_Interconnexions](V39_Exascale_Interconnexions/) | Tendances exascale & interconnexions | Doctorat | Structure + squelettes |
| V40 | [V40_Projet_Doctoral_Etude](V40_Projet_Doctoral_Etude/) | Projet doctoral : étude complète publiable | Doctorat | Structure + squelettes |

---

## Objectif 400–800 pages par volume

Chaque volume vise **400–800 pages**. Convention : [CIBLE_400_800_PAGES.md](../editorial/CIBLE_400_800_PAGES.md). **État actuel** : structure + squelettes (TODOs) ; rédaction **chapitre par chapitre**.

## Méthode

- **V01** : contenu partiel + squelettes ch. 10–20.
- **V02–V40** : book.md + chapters/ (14 chapitres type) + figures/ + assets/ ; squelettes à rédiger selon [TEMPLATE_CHAPTER](../editorial/TEMPLATE_CHAPTER.md) / [TEMPLATE_LAB](../editorial/TEMPLATE_LAB.md).
- Prochaine étape : rédiger chapitre par chapitre (voir [ROADMAP](../editorial/ROADMAP.md)).

## Références

- [SOURCE_INDEX](../editorial/SOURCE_INDEX.md) | [STYLE_GUIDE](../editorial/STYLE_GUIDE.md) | [ROADMAP](../editorial/ROADMAP.md)
