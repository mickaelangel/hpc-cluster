# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 7 : Observabilité, MCO et incidentologie**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs SRE

---

## Vue d'ensemble du volume

Un supercalculateur n'a de valeur que s'il est **disponible, surveillé et prédictible**. Ce volume couvre le **Site Reliability Engineering (SRE)** appliqué au HPC : **stack d'observabilité** (métriques, logs, Pull vs Push, exporters Slurm/Lustre/GPU), **capacity planning** et **SLA** (allocation vs utilisation, showback/chargeback, SLOs), puis **runbooks**, **on-call** et **post-mortems** (RCA blameless, MTTR). Le [Lab 10](#-lab-10--déploiement-de-lobservabilité-prometheus--slurm) et l'[examen de fin de volume](#-examen-de-fin-de-volume-7) permettent de valider les acquis.

**Prérequis :**
- Notions de bases de données, JSON/YAML, TCP/UDP (Ch. 22)
- Statistiques descriptives de base (Ch. 23)
- Expérience d'environnements de production (Ch. 24)

---

## Chapitre 22 : Stack d'observabilité HPC (métriques et logs)

### Objectifs d'apprentissage

- Déployer une architecture de surveillance basée sur des **séries temporelles** (TSDB)
- Collecter les **métriques spécifiques** de [Slurm](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md) et de Lustre
- **Centraliser** et parser les logs distribués

---

### 22.1 Le paradigme Pull vs Push

Sur des **milliers de nœuds**, deux modèles s'opposent :

| Modèle | Exemple | Comportement | Risque |
|--------|---------|--------------|--------|
| **Push** | InfluxDB / Telegraf | Chaque nœud **envoie** ses métriques au serveur central | Tempête de métriques (DDoS interne) si le serveur ralentit |
| **Pull** | **Prometheus** | Le serveur central **scrappe** (aspire) les métriques exposées par chaque nœud (HTTP, souvent port 9100) | Le serveur **contrôle la cadence** → standard moderne |

---

### 22.2 Les exporters vitaux en HPC

Un **exporter** expose les données (OS ou application) au format **Prometheus**.

| Exporter | Rôle | Où tourne |
|----------|------|-----------|
| **node_exporter** | CPU, RAM, I/O disque local, réseau | Tous les nœuds |
| **slurm_exporter** | Jobs Pending/Running, état des nœuds (Drain, Down) ; interroge slurmctld | Management / frontal |
| **lustre_exporter** | IOPS, métadonnées, remplissage des OSTs ; lit `/proc/fs/lustre` (MGS/MDS/OSS) | Nœuds stockage |
| **dcgm_exporter** | (NVIDIA) Température, Watts, utilisation cœurs Tensor ; indispensable pour l'IA | Nœuds GPU |

**Schéma : Flux de l'observabilité**

```
+-------------------+      +-------------------+
| Compute Nodes     |      | Management Node   |
| - node_exporter   |<--+  |                   |       +---------------+
| - dcgm_exporter   |   |  | +---------------+ |       | Utilisateur / |
+-------------------+   |  | | Prometheus    | |       | Administrateur|
                        +--+-| (Scraper)     | |<----->| (Grafana)     |
+-------------------+   |  | +---------------+ |       +---------------+
| Storage Nodes     |   |  |         |         |
| - lustre_exporter |<--+  |         v         |
+-------------------+      | +---------------+ |
                           | | Alertmanager  | |------> (Email, Slack,
                           | +---------------+ |         PagerDuty)
                           +-------------------+
```

---

### 22.3 Centralisation des logs

Un job MPI plante sur **compute-084** : on ne se connecte pas en SSH pour lire `/var/log/messages`. Les logs doivent être **expédiés** (rsyslog, **Promtail**, **Filebeat**) vers un point central (**Elasticsearch** ou **Loki**).

---

### Piège : « L'effet d'observateur »

Configurer Prometheus avec **scrape_interval: 1s** sur un cluster de **2000 nœuds** → le réseau d'admin et les CPU des nœuds sont **saturés** par la surveillance. **Règle** : **15 à 30 s** suffisent pour l'infrastructure.

---

### Check-list production (Chapitre 22)

- [ ] Configurer **Alertmanager** pour **regrouper** (group) les alertes : 500 nœuds down → **1** alerte « Switch Spine Down », pas 500 emails
- [ ] **Sécuriser** les endpoints Prometheus (reverse-proxy ou règles pare-feu)

---

## Chapitre 23 : Capacity planning et SLA

### Objectifs d'apprentissage

- Modéliser la **croissance** du cluster et anticiper la **saturation**
- Distinguer **allocation** et **utilisation réelle**
- Définir et mesurer des **SLOs** (Service Level Objectives) pertinents en HPC

---

### 23.1 Allocation vs utilisation (l'illusion du GPU)

Slurm indique qu'un GPU est **« Alloué »** (100 % réservé). **dcgm_exporter** indique si le GPU **calcule vraiment** (utilisation 80 %) ou est **en veille** (5 %) en attendant le CPU.

> Le **capacity planning** ne se base **jamais** sur l'allocation seule : sinon on achète du matériel inutile. Il faut **optimiser les codes** avant d'ajouter des ressources.

---

### 23.2 Showback et Chargeback

| Concept | Rôle |
|--------|------|
| **Showback** | Tableau de bord informatif : « Ce mois-ci, vous avez consommé l'équivalent de 50 000 € de temps de calcul ». Responsabilisation, pas de facturation. |
| **Chargeback** | **Facturation réelle** à partir de l'accounting Slurm (`sacct`). Exige une **précision absolue**. |

---

### 23.3 SLOs (Service Level Objectives) en HPC

Les métriques SRE en HPC diffèrent du web (99,99 % uptime). Exemples :

| SLO | Cible typique |
|-----|----------------|
| **Queue Wait Time** | 95 % des jobs demandant &lt; 10 nœuds démarrent en **&lt; 4 h** |
| **I/O Latency** | Création d'un fichier (métadonnée Lustre) **&lt; 5 ms** au **p99** |
| **Job Success Rate** | **&lt; 1 %** des jobs échouent à cause d'une **défaillance infrastructure** (hors bug utilisateur) |

---

## Chapitre 24 : Runbooks, on-call et post-mortems (RCA)

### Objectifs d'apprentissage

- Rédiger des **SOP** (Standard Operating Procedures) **actionnables**
- Gérer une **crise** en production
- Rédiger un **Root Cause Analysis (RCA) blameless** (sans blâme)

---

### 24.1 Le Runbook (SOP)

À 3 h du matin, face à l'alarme **« Lustre OST Full »**, l'ingénieur d'astreinte **exécute**, ne réfléchit pas. Le Runbook est un document concis :

| Section | Contenu |
|---------|---------|
| **Symptôme** | Ex. : alerte LustreOSTCapacityWarning sur PagerDuty |
| **Vérification** | `lfs df -h` pour confirmer |
| **Action immédiate** | Identifier les gros consommateurs (`lfs quota -h /scratch`), avertir ou purger (`find /scratch -atime +30 -delete`) |
| **Escalade** | Si OST &gt; 95 %, bloquer les nouvelles écritures et appeler l'expert niveau 3 |

---

### 24.2 Le Post-Mortem (RCA blameless)

Chaque **incident majeur** génère un rapport. **Règle d'or** (Google SRE) : **Blameless RCA** — on suppose que l'opérateur a pris la meilleure décision avec les infos disponibles. On cherche **pourquoi le système a permis l'erreur**, pas qui a fauté.

**Métrique de fiabilité :**

```
MTTR = (Σ Temps de réparation de tous les incidents) / (Nombre total d'incidents)
```

*(Mean Time To Recovery. En HPC, le MTTR compte souvent plus que le MTBF : un cluster plantera ; la question est à quelle vitesse on le relance.)*

---

### DANGER en prod : « Le fix à la main non documenté »

Modifier un fichier de configuration **directement sur le nœud** sans reporter la modification dans **Ansible/GitOps** → à la prochaine exécution d'Ansible, l'incident **se reproduit**.

---

## 🧪 Lab 10 : Déploiement de l'observabilité (Prometheus + Slurm)

### Énoncé

Sur votre nœud **Master** :

1. Téléchargez et lancez **Prometheus** (binaire pré-compilé).
2. Installez **slurm_exporter** (GitHub).
3. Configurez **prometheus.yml** pour scrapper `localhost:9100` (node_exporter) et `localhost:8080` (slurm_exporter).
4. Lancez quelques jobs via **sbatch** et interrogez Prometheus (`http://master:9090`) pour afficher la métrique **slurm_jobs_running**.

### Critères de réussite

- La page **/targets** de Prometheus affiche l'exporter Slurm avec le statut **UP**.
- La requête PromQL **sum(slurm_jobs_running)** affiche une valeur **&gt; 0** lorsque des jobs s'exécutent.

### Corrigé (snippets)

**prometheus.yml :**

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "slurm"
    static_configs:
      - targets: ["localhost:8080"]
  - job_name: "nodes"
    static_configs:
      - targets: ["localhost:9100", "node01:9100", "node02:9100"]
```

**Lancement :**

```bash
./prometheus --config.file=prometheus.yml &
./slurm_exporter &
```

---

## 📝 Examen de fin de volume 7

### QCM (1 point chaque)

**1.** Quelle est la différence majeure entre le modèle **Push** (Telegraf) et le modèle **Pull** (Prometheus) ?  
- A) Le modèle Pull est moins sécurisé  
- B) Le modèle Push force le serveur central à aspirer les données, ce qui surcharge son CPU  
- C) **Dans le modèle Pull, c'est le serveur central qui décide de la fréquence de collecte, évitant d'être submergé**  

**2.** Un job alloue **4 GPU A100** mais **dcgm_exporter** indique **2 %** d'utilisation et une **VRAM vide**. Quel est le problème probable ?  
- A) Les GPU sont en surchauffe (thermal throttling)  
- B) **Le code n'utilise pas les GPU (ou CUDA/PyTorch mal chargé) ; le job gaspille des ressources**  
- C) Le réseau InfiniBand est en panne  

---

### Question ouverte (Analyse de SLA)

Le directeur se plaint que le **Wait Time** (temps d'attente en file) a **explosé** depuis 3 mois. Sur Grafana, l'**utilisation globale CPU** du cluster est pourtant à **60 %** (40 % de nœuds inactifs).

**Expliquez** pourquoi un cluster peut avoir des **jobs en file d'attente** alors qu'il est **presque à moitié vide**. (Indice : au-delà des CPU, que demande un job ?)

**Réponse attendue** : **Fragmentation des ressources** ou **goulot annexe**. Les jobs en attente demandent peut-être des **GPU** (saturés à 100 %), des **licences** épuisées, ou une **grosse quantité de RAM** (les nœuds libres n'ont plus de mémoire malgré des cœurs libres). Il est aussi possible que le **Backfill** ne puisse pas placer les jobs si les utilisateurs ne fournissent pas de **walltime** précis.

---

### Étude de cas : « Post-Mortem du vendredi noir »

Vendredi 17 h. Un admin met à jour **slurm.conf** via Ansible et lance **scontrol reconfigure**. **Tous les nœuds** passent en **DOWN**, **5000 jobs** sont tués.

1. **Quelle erreur** classique dans slurm.conf peut provoquer un **rejet massif** des nœuds par le contrôleur ? (penser : caractéristiques nœuds, mémoire, auth.)  
2. **Quelle étape** manquait dans la pipeline (CI/CD ou SOP) **avant** la commande en production ?  
3. **Rédigez** l'**action corrective** pour éviter la récidive.

**Réponses attendues :**

1. Modification d'une **caractéristique critique** (ex. **RealMemory**, nombre de cœurs) sans vérifier. Si slurmctld attend 256 Go de RAM et que slurmd annonce 255 Go, le contrôleur considère le nœud **incohérent** et le marque **DOWN**.

2. **Validation** : exécuter **slurmd -C** sur un nœud pour vérifier la config matérielle vue par Slurm, ou **tester** le nouveau slurm.conf sur un **staging**. Pas de **slurmctld -t** (test config) avant redémarrage.

3. **Action Item** : Intégrer un **linter** ou un **script de pré-flight** dans le pipeline Ansible qui lance **slurmctld -t** avant tout redémarrage des services en production.

---

## Solutions des QCM

- **Q1** : **C** — Pull : le serveur contrôle la cadence.  
- **Q2** : **B** — Allocation ≠ utilisation ; le code ne tire pas parti des GPU.

---

## 📋 Relecture qualité du volume 7

- [x] Couverture : Exporters, Pull vs Push, capacity planning, SLO/SLA (wait time, IOPS), post-mortems blameless
- [x] Rigueur technique : Showback/Chargeback, Allocation/Utilisation (dcgm_exporter), formule MTTR
- [x] Format : Titres clairs, schéma ASCII monitoring
- [x] Pédagogie : Cas d'étude incident Slurm (SOP, CI/CD)

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-HPC-Sommaire-Complet.md)** : plan des 8 volumes, chapitres, labs
- **[Manuel Architecture HPC — Vol. 1 à 6](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume1.md)** : fondations à performances
- **[Monitoring](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Monitoring.md)** : Prometheus, Grafana, dashboards
- **[Guide SLURM Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md)** : slurmctld, accounting, sinfo
- **[Glossaire et Acronymes](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Glossaire-et-Acronymes.md)** : SLO, MTTR, TSDB, etc.
- **[Home](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)** : page d'accueil du wiki

---

**Volume 7** — Observabilité, MCO et incidentologie  
**Dernière mise à jour** : 2024
