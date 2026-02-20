# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 8 : Le fil rouge « De zéro à la prod » et tendances de l'Exascale**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, architectes

---

## Vue d'ensemble du volume

Ce volume est l'**aboutissement** du manuel : synthèse des connaissances en un **projet de déploiement complet** (le « Fil Rouge ») et exploration des **frontières** du calcul intensif — Exascale, convergence IA-HPC, hybridation Cloud. On y traite les **phases chronologiques** du déploiement (design, bare-metal, stockage, ordonnancement, sécurisation, observabilité, tests de charge), les **critères de Go-Live**, puis les **défis Exascale** (énergie, DLC), la **convergence IA/HPC** et le **Cloud Bursting**. Le [Lab 11](#-lab-11--étude-de-cas-architecture--design) et l'[examen de fin de volume](#-examen-de-fin-de-volume-8-et-de-louvrage) clôturent l'ouvrage.

**Prérequis :** Maîtrise des [Volumes 1 à 7](Manuel-Architecture-HPC-Volume1.md).

---

## Chapitre 25 : Projet guidé complet « De la page blanche à la production »

### Objectifs d'apprentissage

- Ordonnancer **chronologiquement** les étapes de déploiement d'un supercalculateur
- Éviter les régressions par une **méthodologie d'intégration continue**
- Valider les **critères de passage en production** (Go-Live)

---

### 25.1 Phase 1 : Design et dimensionnement (Jours 1 à 15)

Tout commence par le **Co-Design** avec les chercheurs.

| Thème | Questions clés |
|-------|----------------|
| **Analyse du workload** | Deep Learning (GPU H100, NVLink) ou dynamique moléculaire (CPU denses, InfiniBand) ? |
| **Dimensionnement stockage** | Ratio capacité / bande passante. Ex. : 5 To/jour → durée de rétention sur `/scratch` Lustre ? Politique de purge. |
| **Topologie réseau** | Non-blocking (1:1) ou oversubscription (ex. 2:1) si budget limité et communications MPI peu denses. |

---

### 25.2 Phase 2 : Fondations bare-metal et réseau (Jours 16 à 30)

| Étape | Contenu |
|-------|---------|
| **Rack & Stack** | Câblage physique. **Cable Plan** strict (éviter le croisement des câbles InfiniBand). |
| **Réseau OOB** | VLAN isolé pour IPMI/Redfish (management). |
| **Provisioning** | Nœud Master, [Warewulf](Manuel-Architecture-HPC-Volume1.md) v4, image OS (ex. Rocky Linux 9) en RAM (tmpfs). |
| **Fabric IB** | Lancement d'**opensm**, vérification des liens (ibnetdiscover, pas de liens dégradés). |

---

### 25.3 Phase 3 : Déploiement du stockage parallèle (Jours 31 à 40)

| Étape | Contenu |
|-------|---------|
| **SAN/Block** | LUNs matériels (RAID 6 ou Declustered Parity). |
| **Lustre** | Formatage MGS, MDT (NVMe), OSTs (HDD capacitifs). |
| **LNet** | Interfaces Lustre sur InfiniBand (o2ib). |
| **Tests** | Premier **IOR** (I/O aléatoire et séquentiel) pour valider la bande passante avant prod. |

---

### 25.4 Phase 4 : Ordonnancement et environnements (Jours 41 à 50)

| Étape | Contenu |
|-------|---------|
| **Identity** | FreeIPA/LDAP, synchronisation via SSSD sur les nœuds. |
| **Slurm** | slurmctld, slurmdbd (MariaDB), slurmd ; **cgroups** (cgroup.conf) pour isolation CPU/RAM. |
| **Toolchains** | [Spack](Manuel-Architecture-HPC-Volume5.md) : GCC, Intel, OpenMPI, MVAPICH2 ; arbre **Lmod**. |

---

### 25.5 Phase 5 : Sécurisation, observabilité et tests de charge (Jours 51 à 60)

| Étape | Contenu |
|-------|---------|
| **Monitoring** | [Prometheus](Manuel-Architecture-HPC-Volume7.md), Grafana, node_exporter, slurm_exporter, Alertmanager. |
| **HPL & HPCG** | HPL sur **100 %** des nœuds pendant **24 h** (burn-in thermique). |
| **Chaos Engineering** | Débrancher une fibre pendant un job MPI ; redémarrer le nœud slurmctld primaire pour valider le **basculement HA**. |

---

### Check-list Go-Live

- [ ] Benchmarks d'acceptation (HPL/IOR) **≥ 85 %** de la promesse constructeur
- [ ] **Runbook** des 10 pannes les plus courantes rédigé et testé
- [ ] Script de purge du `/scratch` activé en **dry-run**
- [ ] Portail de support utilisateur (Jira/GLPI) opérationnel

---

## Chapitre 26 : Hybridation Cloud et avenir du HPC

### Objectifs d'apprentissage

- Comprendre les **défis physiques** de l'ère Exascale (énergie, refroidissement)
- Différencier HPC traditionnel, **Cloud Bursting** et **convergence IA**

---

### 26.1 Le mur de l'énergie et l'Exascale

L'**Exascale** = **10¹⁸ FLOPS** (un milliard de milliards d'opérations/s). Le défi n'est plus seulement le silicium, mais l'**alimentation** et le **refroidissement**.

**Efficacité énergétique :**

```
E_sys = R_max / P_totale
```

*(R_max = performance mesurée, P_totale = consommation électrique totale de la salle ; en GFLOPS/Watt.)*

Pour rester sous **20–30 MW** (puissance d'une petite ville), les systèmes abandonnent le refroidissement **par air** au profit du **DLC** (Direct Liquid Cooling) : eau tiède (jusqu'à 45 °C) sur les dissipateurs CPU/GPU pour capter ~90 % de la chaleur.

---

### 26.2 La convergence IA et HPC

| Domaine | Précision typique | Usage |
|---------|-------------------|--------|
| **HPC classique** | FP64 (double) | Stabilité numérique, physique |
| **IA / Deep Learning** | FP32, FP16, FP8, INT4 | Entraînement, inférence |

L'IA **remplace ou accélère** les solveurs traditionnels (ex. **PINNs** — Physics-Informed Neural Networks — pour des EDP 1000× plus rapides). → Architecture **hybride** : CPU + **Tensor Cores** massivement parallèles.

---

### 26.3 Le Cloud Bursting (HPC élastique)

Quand la file [Slurm](Guide-SLURM-Complet.md) locale **déborde**, le Cloud Bursting alloue des **nœuds virtuels** sur un cloud public (AWS, GCP, Azure).

**Fonctionnement Slurm :**
- Nœuds Cloud avec état **CLOUD** dans slurm.conf
- **ResumeProgram** : appel API pour démarrer les VMs
- **SuspendProgram** : destruction des VMs quand inactives → arrêt de la facturation

---

### Piège : « La gravité de la donnée » (Data Gravity)

Déporter le **calcul** dans le Cloud en laissant les **données** (ex. 100 To) sur le Lustre **on-premise** → les nœuds Cloud passent **90 %** du temps (facturé) à attendre les données via le lien VPN. Si des données sont **générées dans le cloud** et rapatriées, les **coûts d'egress** explosent.

> **Règle** : Le calcul doit aller **vers la donnée**. En bursting, les données doivent être **synchronisées** dans le cloud (S3, FSx for Lustre, etc.) au préalable.

---

## 🧪 Lab 11 : Étude de cas « Architecture & Design » (exercice sur table)

### Énoncé

Vous êtes l'**architecte HPC** d'un institut de recherche en **climatologie**.

- **Budget** : 4 M€  
- **Contrainte électrique** : 200 kW max pour la salle  
- **Code** : Modèle **WRF** (fortement MPI, bande passante mémoire ; **pas de GPU**)  
- **Données** : 50 To/semaine  

Proposez une **architecture macroscopique** (type processeur, ratio compute/login, interconnexion, système de fichiers, dimensionnement). **Expliquez** pourquoi vous excluez les GPU.

### Critères de réussite (corrigé conceptuel)

| Composant | Choix | Justification |
|-----------|--------|----------------|
| **Compute** | **CPU-only**. Processeurs à fort ratio bande passante mémoire / cœur (ex. AMD EPYC Genoa-X, Intel Xeon Max avec HBM). | WRF n'exploite pas les GPU → GPU = budget et quota électrique gaspillés. |
| **Réseau** | InfiniBand NDR ou RoCE v2 **non-blocking** (Fat-Tree 1:1). | Communications de halos WRF permanentes, sensibles à la latence. |
| **Stockage** | Lustre ou BeeGFS ~**1 Po** utilisable. **Tiering** vers bandes ou S3 pour archivage. | 50 To/semaine → purge agressive ou archivage pour pérennité. |
| **Énergie** | 200 kW restrictif → processeurs TDP modéré et/ou **Direct Liquid Cooling** pour réduire climatisation et ventilateurs. | |

---

## 📝 Examen de fin de volume 8 (et de l'ouvrage)

### QCM (1 point chaque)

**1.** Quelle est la **limite physique** majeure poussant vers le **Direct Liquid Cooling (DLC)** pour l'Exascale ?  
- A) L'eau conduit mieux les signaux électriques que le cuivre  
- B) **L'air n'a plus la capacité d'absorption thermique suffisante pour des racks à 50–100 kW de dissipation (CPU/GPU ultra-denses)**  
- C) Les pompes à eau prennent moins de place que les SSD  

**2.** Qu'est-ce que la **« Data Gravity »** en contexte Cloud Bursting HPC ?  
- A) **La difficulté à déplacer de très grands volumes de données, qui « attirent » naturellement le calcul vers elles**  
- B) L'usure plus rapide des disques sur site que dans le cloud  
- C) La compression algorithmique des données scientifiques  

---

### Question ouverte (Exploitation et gouvernance)

**Expliquez** pourquoi le **Chaos Engineering** (simulation intentionnelle de pannes : débrancher le nœud primaire slurmctld ou un routeur LNet en production simulée) est une **étape cruciale** du jalon **Go-Live** (Phase 5).

**Réponse attendue** : Un plan de **HA non testé** est une théorie dangereuse. Le Chaos Engineering **valide** que le failover fonctionne en conditions de stress, que les **alertes** (Prometheus) remontent aux bonnes personnes et que le **MTTR** des équipes sur les Runbooks est acceptable **avant** que de vrais utilisateurs soient impactés.

---

### Étude de cas : « La facture salée du Bursting »

Un centre a configuré des nœuds **CLOUD** dans slurm.conf (ResumeProgram AWS). Objectif : gérer les pics. Au bout d'un mois : **150 000 €** de facture AWS au lieu de **10 000 €** prévus.

Les logs Slurm montrent que des **milliers de petits jobs** (durée **30 s**) ont été envoyés sur les nœuds CLOUD. Les instances Cloud mettent **2–3 min** à démarrer.

1. **Expliquez** l'inefficacité technique et financière.  
2. **Quel paramètre** (QOS ou limites de partition) aurait dû restreindre le Cloud Bursting à certains types de calculs ?

**Réponses attendues :**

1. Facturation à la **minute** (ou minimum forfaitaire). Allumer une VM (3 min), exécuter 30 s, éteindre → **hérésie économique** : overhead d'initialisation énorme, coût par job prohibitif.  
2. **MinTime** sur la partition Cloud (ex. `MinTime=02:00:00`) pour éviter les micro-jobs ; ou réserver la partition à des **QOS** spécifiques (projets avec budget Cloud alloué).

---

## Solutions des QCM

- **Q1** : **B** — DLC pour dissiper 50–100 kW par rack.  
- **Q2** : **A** — Data Gravity = la donnée « attire » le calcul.

---

## 📚 Références (Volume 8)

- Dongarra, J., et al. (2022). *The Exascale computing project.*  
- Reed, D. A., et al. (2015). Exascale computing and big data. *Communications of the ACM.*  
- Google SRE (2016). *Site Reliability Engineering: How Google Runs Production Systems.* O'Reilly Media.

---

## 📋 Relecture qualité du volume 8 (finale)

- [x] Couverture : Fil rouge (5 phases), Exascale, DLC, Data Gravity, IA vs HPC, Cloud Bursting  
- [x] Rigueur technique : TDP, efficacité énergétique (GFLOPS/Watt), ResumeProgram/SuspendProgram Slurm  
- [x] Format : Markdown, formules (E_sys), questions adaptées Master/PhD  
- [x] Pédagogie : Lab architecture systémique (design sous contraintes budget/énergie)

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](Manuel-HPC-Sommaire-Complet.md)** : plan des 8 volumes  
- **[Manuel Architecture HPC — Vol. 1 à 7](Manuel-Architecture-HPC-Volume1.md)** : fondations à observabilité  
- **[Guide SLURM Complet](Guide-SLURM-Complet.md)** : partitions, CLOUD, QOS  
- **[Glossaire et Acronymes](Glossaire-et-Acronymes.md)** : DLC, Exascale, SRE, etc.  
- **[Home](Home.md)** : page d'accueil du wiki  

---

**Volume 8** — Le fil rouge « De zéro à la prod » et tendances de l'Exascale  
**Dernière mise à jour** : 2024  

*Le corps du Manuel (8 volumes) est achevé : cycle complet de l'ingénierie HPC, de la gestion mémoire NUMA jusqu'à la stratégie Cloud et Exascale.*
