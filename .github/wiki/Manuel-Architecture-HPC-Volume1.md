# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 1 : Fondations, architecture de base et provisioning DevOps**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système

---

## Vue d'ensemble du volume

Ce manuel couvre les **fondations** d'un cluster HPC en production : co-design, architectures types, gestion hors-bande (OOB), provisioning bare-metal (PXE, Warewulf) et configuration management (Ansible). Un [lab pratique](#-lab-1--provisioning-dun-mini-cluster-from-scratch) et un [examen de fin de volume](#-examen-de-fin-de-volume-1) permettent de valider les acquis.

**Prérequis généraux :**
- Notions d'architecture des ordinateurs (CPU, RAM, I/O)
- Bases du calcul parallèle
- Connaissances réseaux (IP, MAC, VLAN) pour les chapitres 2 et 3

---

## Chapitre 1 : Introduction au HPC moderne et co-design

### Objectifs d'apprentissage

- Comprendre la philosophie du **co-design** (matériel / logiciel)
- Identifier les **3 grandes architectures types** de clusters HPC
- Cartographier les **composants logiques** d'un supercalculateur

---

### 1.1 Le paradigme du co-design

En HPC, le matériel et le logiciel ne sont **pas choisis de manière isolée**. Le **co-design** est l'art d'architecturer un système en fonction des caractéristiques exactes de la **charge de travail** (workload).

> On ne construit pas un cluster pour « faire du calcul » ; on le construit pour **« résoudre des équations de Navier–Stokes massivement parallèles »** ou **« entraîner des LLM de 70B paramètres »**.

Chaque famille de workload impose des choix d’architecture (CPU vs GPU, latence vs débit réseau, stockage parallèle vs local).

---

### 1.2 Les trois architectures types

| Architecture | Cible typique | Design principal |
|--------------|----------------|-------------------|
| **CPU-only** (capacité & scalabilité) | CFD, chimie quantique, Monte-Carlo | Nœuds denses en cœurs (AMD EPYC, Intel Xeon). Bande passante mémoire (DDR5, HBM) et **réseau à très faible latence** (InfiniBand NDR). Fort usage [MPI](Glossaire-et-Acronymes#m). |
| **GPU / Accelerated** (IA & calcul vectoriel) | Deep Learning (training), dynamique moléculaire (GROMACS, NAMD) | Nœuds « fat » (ex. 8× NVIDIA H100 ou AMD MI300X). **Interconnexion interne (NVLink)** cruciale. Réseau externe à débit massif (RoCE v2 ou InfiniBand) avec **GPUDirect RDMA** pour bypasser le CPU. |
| **Data-Intensive** (I/O heavy) | Génomique, bio-informatique, physique des particules | Nœuds avec **beaucoup de RAM locale**. Réseau dimensionné pour le **throughput** vers le stockage. **Stockage parallèle** ([Lustre](Glossaire-et-Acronymes#l), GPFS) optimisé pour millions de petits fichiers (IOPS) ou flux séquentiels massifs. |

---

### 1.3 Architecture macroscopique d’un cluster

Les composants logiques s’articulent ainsi en production :

```
+-------------------+       +-------------------+       +-------------------+
|  Utilisateurs     |       |   Réseau d'Admin  |       | Réseau Haute Perf |
|  (SSH / Portail)  |       |   (1GbE / 10GbE)  |       | (InfiniBand/RoCE) |
+--------+----------+       +---------+---------+       +---------+---------+
         |                            |                           |
         v                            |                           |
+-------------------+                 |                           |
|   Login Nodes     +-----------------+                           |
| (Bastion/Compil)  |                 |                           |
+-------------------+                 |                           |
                                      |                           |
+-------------------+                 |                           |
| Management Nodes  +-----------------+                           |
| (Slurmctld, DNS,  |                 |                           |
|  LDAP, Observab.) |                 |                           |
+-------------------+                 |                           |
                                      |                           |
+-------------------+                 |                           |
| Compute Nodes     |                 |                           |
| (CPU/GPU/Fat RAM) +-----------------+---------------------------+
+-------------------+                 |                           |
                                      |                           |
+-------------------+                 |                           |
| Storage Nodes     |                 |                           |
| (Lustre MGS/OSS)  +-----------------+---------------------------+
+-------------------+
```

---

### Pièges et anti-patterns

| Piège | Description |
|-------|-------------|
| **Login node fourre-tout** | Laisser les utilisateurs lancer de gros calculs ou compilations lourdes sur le nœud de connexion. **Symptôme** : le cluster semble planté car le point d’entrée est saturé. |
| **Négliger le réseau d’administration (OOB)** | Penser que le réseau 1GbE / IPMI n’a pas besoin d’être redondant. En cas de freeze du cluster, c’est souvent la **seule porte de secours**. |

---

### Check-list production (Chapitre 1)

- [ ] Séparation physique ou **VLAN strict** entre : réseau d’admin, réseau IPMI, réseau haute performance (Data/MPI)
- [ ] **Quotas stricts** sur les nœuds de login (ex. `/home` limité)
- [ ] Politique claire : pas de calcul lourd sur les login nodes (utilisation de [Slurm](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md) pour toute exécution)

---

## Chapitre 2 : Bases matérielles et gestion Out-of-Band (OOB)

### Objectifs d'apprentissage

- Maîtriser l’**administration bare-metal** sans dépendre de l’OS
- Utiliser **IPMI** et l’**API Redfish** pour la gestion de flotte

---

### 2.1 Le BMC (Baseboard Management Controller)

Le **BMC** est un **micro-ordinateur indépendant** (souvent basé sur un SoC ARM) soudé à la carte mère du serveur. Il dispose de :

- Sa propre **RAM** et son propre **OS** (souvent [OpenBMC](https://github.com/openbmc/openbmc))
- Sa propre **interface réseau** (port dédié ou partagé)
- Il reste **allumé** même si le serveur est électriquement éteint (mais branché)

Il permet : console série/KVM à distance, power on/off/reset, lecture capteurs (température, tension), logs matériels (SEL), mise à jour firmware.

---

### 2.2 IPMI vs Redfish

| Critère | IPMI | Redfish |
|--------|------|---------|
| **Standard** | Historique (port UDP 623) | Moderne DMTF |
| **Interface** | Binaire, protocole propriétaire | **API REST** (HTTPS), réponses **JSON** |
| **Sécurité** | Failles connues si exposé sur le réseau | HTTPS, authentification, mieux adapté à l’automatisation |
| **Usage** | Outils type `ipmitool` | `curl`, scripts, orchestration (Ansible, Terraform) |

**En pratique** : Redfish est l’**avenir** du provisionnement et de la supervision matérielle automatisée.

---

### Exemple : Redémarrage forcé d’un nœud bloqué (IPMI)

```bash
# DANGER : Coupe brutalement l’alimentation (équivalent bouton power maintenu)
ipmitool -I lanplus -H 10.0.1.50 -U admin -P secret_pass power reset
```

---

### Exemple : Température CPU via Redfish (REST/JSON)

```bash
curl -u admin:secret_pass -k https://10.0.1.50/redfish/v1/Chassis/1/Thermal | \
  jq '.Temperatures[] | select(.Name=="CPU1 Temp") | .ReadingCelsius'
```

---

### ⚠️ Sécurité OOB en production

> **DANGER** : L’exposition du réseau BMC/IPMI sur Internet ou sur le réseau de recherche est une **faille critique** (CVSS 10.0). Ces interfaces doivent être **strictement isolées** sur un VLAN d’administration, idéalement **non routé** vers Internet.

- Réseau **Out-of-Band** dédié
- Accès restreint (VPN, bastion)
- Changer les mots de passe par défaut et les stocker dans un coffre (vault)

---

## Chapitre 3 : Provisioning bare-metal et gestion du cycle de vie

### Objectifs d'apprentissage

- Comprendre la **chaîne de boot PXE**
- Déployer et configurer **Warewulf v4** pour provisionner des nœuds **stateless**

**Prérequis** : DHCP, TFTP, notions de conteneurs OCI.

---

### 3.1 La chaîne PXE (Preboot eXecution Environment)

Dans beaucoup de clusters HPC, les nœuds de calcul **n’ont pas de disque OS local** (ou seulement cache/scratch). Ils démarrent **par le réseau** (stateless).

| Étape | Rôle |
|-------|------|
| 1 | Le nœud s’allume ; la carte réseau envoie un **DHCP Discover** |
| 2 | Le serveur Management (DHCP) répond avec une **IP** et l’**adresse du serveur TFTP** |
| 3 | Le nœud télécharge **iPXE** (ou PXELinux) via **TFTP** |
| 4 | iPXE télécharge le **noyau Linux** (`vmlinuz`) et l’**initramfs** (souvent en HTTP, plus rapide que TFTP) |
| 5 | Le nœud charge l’**OS en RAM** (tmpfs) ; au redémarrage, tout est re-téléchargé |

---

### 3.2 Provisioning avec Warewulf v4

Warewulf v4 utilise des **conteneurs OCI** (compatibles Docker / Apptainer) comme **images système** pour les nœuds, au lieu d’images chroot traditionnelles.

**Workflow typique (sur le nœud Management) :**

```bash
# 1. Importer une image de base depuis un registre
wwctl container import docker://rockylinux:9 rockylinux-9-hpc

# 2. Entrer dans le conteneur pour installer des paquets (client Slurm, Mellanox OFED, etc.)
wwctl container exec rockylinux-9-hpc /bin/bash
# > dnf install epel-release -y
# > dnf install slurm-slurmd munge -y
# > exit

# 3. Enregistrer un nœud (node01) avec MAC et IP
wwctl node add node01 --macaddr=00:11:22:33:44:55 --ipaddr=10.10.0.1 --container=rockylinux-9-hpc

# 4. Configurer le réseau PXE et redémarrer les services
wwctl configure --all
```

---

### À retenir (stateless)

> Dans une architecture **stateless**, toute modification faite **directement sur un nœud** (via SSH) sera **perdue au prochain redémarrage**. Les changements doivent être faits :
> 1. Dans l’**image conteneur Warewulf** (`wwctl container exec`), ou  
> 2. Via **Ansible** (ou autre Configuration Management) appliqué après chaque boot.

---

## Chapitre 4 : Configuration Management & GitOps en HPC

### Objectifs d'apprentissage

- Automatiser la **configuration post-déploiement** avec **Ansible**
- Éviter l’effet **« Snowflake »** (nœuds ayant dérivé de la configuration initiale)

**Prérequis** : Bases YAML, SSH.

---

### 4.1 Ansible à l’échelle HPC

Ansible utilise un modèle **push** via SSH. Sur 10 nœuds, c’est rapide ; sur **2000 nœuds**, la configuration par défaut peut être trop lente.

**Tuning recommandé** dans `ansible.cfg` :

```ini
[defaults]
forks = 100          # Paralléliser sur 100 nœuds simultanément
pipelining = True    # Réduit le nombre de connexions SSH
strategy = free      # Les nœuds n’attendent pas les autres pour la tâche suivante
```

---

### 4.2 Exemple : durcissement et tuning OS pour HPC

Extrait de playbook typique : désactiver services inutiles (réduction du **OS Jitter**, important pour la latence MPI), désactiver le swap, fixer le governor CPU en **performance**.

```yaml
---
- name: HPC Compute Node Hardening & Tuning
  hosts: compute_nodes
  tasks:
    - name: Désactiver firewalld (géré au niveau réseau en HPC)
      ansible.builtin.systemd:
        name: firewalld
        state: stopped
        enabled: no

    - name: Désactiver le swap (les jobs HPC ne doivent pas swapper ; OOM si manque de RAM)
      ansible.posix.mount:
        name: swap
        fstype: swap
        state: absent

    - name: Governor CPU en performance
      ansible.builtin.command: cpupower frequency-set -g performance
      changed_when: false
```

---

## 🧪 Lab 1 : Provisioning d’un mini-cluster « from scratch »

### Énoncé

Vous disposez d’un hyperviseur **KVM**. Vous devez :

1. Déployer une **VM Master** (Rocky Linux 9) avec deux interfaces : WAN et LAN `10.0.0.1/24`
2. Installer **Warewulf v4** sur le Master
3. Importer une image Rocky 9, y installer **htop** et **munge**
4. Créer **2 VMs** (node01, node02) démarrant en **PXE** sur le réseau LAN
5. Les faire **booter** avec succès sur votre image

### Critères de réussite

- `ping node01` et `ping node02` répondent depuis le Master
- **SSH** (sans mot de passe, clés gérées par Warewulf) fonctionne vers les nœuds
- La commande **htop** est disponible sur les nœuds

### Corrigé (grandes lignes)

- Sur le Master : `dnf install epel-release` ; installer Warewulf selon la doc officielle
- Éditer `/etc/warewulf/warewulf.conf` : interface LAN (ex. `eth1`), plage DHCP (ex. `10.0.0.50`–`10.0.0.100`)
- Lancer `wwctl configure --all` (configure DHCP, TFTP, NFS si utilisé)
- `wwctl container import docker://rockylinux:9 base_image`
- `wwctl container exec base_image dnf install htop munge -y`
- Ajouter les nœuds : `wwctl node add node01 --netdev eth0 --hwaddr <MAC_VM1>` (idem pour node02)
- Démarrer les VMs clientes en **boot réseau (PXE)** et vérifier le chargement de l’image

---

## 📝 Examen de fin de volume 1

### QCM (1 point chaque)

**1.** Quelle architecture est la plus pertinente pour de la **dynamique des fluides (CFD)** fortement couplée via MPI ?  
- A) Data-Intensive (grosse RAM)  
- B) **CPU-only avec réseau InfiniBand**  
- C) GPU-heavy avec Ethernet 1 Gbps  

**2.** Pourquoi préfère-t-on **Redfish** à IPMI aujourd’hui ?  
- A) Redfish est plus rapide pour booter l’OS  
- B) **Redfish utilise des standards web modernes (REST/JSON), plus sûrs et automatisables**  
- C) IPMI ne supporte pas les CPU AMD  

---

### Question ouverte (scénario d’exploitation)

Vous êtes d’astreinte. Le cluster de 500 nœuds est **injoignable par SSH** (timeout). L’alimentation de la salle est normale. Quelle est votre **première action technique** pour diagnostiquer sans vous déplacer physiquement ?

**Réponse attendue** : Se connecter via le **réseau OOB/Management** (IPMI ou Redfish) pour ouvrir une **console KVM distante** (Virtual Console) ou consulter les **logs matériels (SEL – System Event Log)** et vérifier l’état des nœuds (power, panne, etc.).

---

### Étude de cas : « Le nœud amnésique »

Un administrateur junior modifie **directement** le fichier `/etc/security/limits.conf` sur le nœud `compute-045` via SSH pour régler un problème de limites de fichiers ouverts. Il redémarre le nœud pour appliquer la modification. **Au redémarrage, la modification a disparu.**

- **Expliquez** techniquement pourquoi.  
- **Détaillez** la procédure correcte pour rendre cette modification **persistante** dans une architecture HPC moderne (stateless).

**Réponse attendue :**

- **Pourquoi** : Le cluster utilise un provisioning **stateless** (ex. Warewulf) ; l’OS tourne en RAM (tmpfs). Au reboot, l’image est **re-téléchargée** depuis le Master : toute modification locale est perdue.
- **Procédure correcte** :  
  1) Faire la modification dans le **conteneur source** via `wwctl container exec <image>`, puis reconstruire/déployer l’image ; **ou**  
  2) Ajouter un **playbook Ansible** qui déploie ce fichier (ou ce paramètre), et l’appliquer après chaque déploiement/redémarrage.

---

## Solutions des QCM

- **Q1** : **B** — En CFD fortement couplée, le ratio communication/calcul est élevé ; le réseau à **faible latence** (InfiniBand) est déterminant.
- **Q2** : **B** — Redfish est une API REST/JSON, adaptée à l’automatisation et à une meilleure sécurité (HTTPS).

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-HPC-Sommaire-Complet.md)** : plan des 8 volumes, chapitres, labs, annexes
- **[Cours HPC Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Cours-HPC-Complet.md)** : concepts généraux, parallélisme, stockage, GPU
- **[Guide SLURM Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md)** : ordonnancement et soumission de jobs
- **[Glossaire et Acronymes](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Glossaire-et-Acronymes.md)** : définitions (BMC, PXE, Redfish, Lustre, etc.)
- **[Home](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)** : page d’accueil du wiki

---

**Volume 1** — Fondations, architecture de base et provisioning DevOps  
**Dernière mise à jour** : 2024
