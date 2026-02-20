# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 2 : Réseaux datacenter, interconnexions et sécurité**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système

---

## Vue d'ensemble du volume

Un cluster HPC n'est pas qu'une simple collection de serveurs : c'est **l'interconnexion** de ces nœuds qui permet le calcul massivement parallèle et l'accès fulgurant aux données. Ce volume couvre le **système nerveux** du supercalculateur : réseaux de management et de stockage (Ethernet, Spine-Leaf, MLAG, Jumbo Frames), interconnexions à faible latence (InfiniBand, RoCE v2), et fondations de la sécurité (IAM, bastion, durcissement). Un [lab pratique](#-lab-2--déploiement-dun-annuaire-central-et-intégration) et un [examen de fin de volume](#-examen-de-fin-de-volume-2) permettent de valider les acquis.

**Prérequis :**
- Modèle OSI, routage IP, VLANs, LACP (Ch. 5)
- Notions de DMA, files d'attente (Ch. 6)
- Linux PAM, SSH, bases de cryptographie (Ch. 7)

---

## Chapitre 5 : Réseaux de management et de stockage (Ethernet)

### Objectifs d'apprentissage

- Concevoir une **topologie réseau datacenter** moderne (Spine-Leaf)
- Comprendre et configurer les **agrégats de liens (MLAG)** et les **trames géantes (Jumbo Frames)**
- Différencier les flux **Nord-Sud** (vers l'extérieur) des flux **Est-Ouest** (inter-nœuds)

---

### 5.1 La fin du modèle 3-Tiers : vive le Spine-Leaf

Historiquement, les réseaux étaient organisés en **Core, Aggregation et Access** (3-Tiers). En HPC, le trafic est **massivement Est-Ouest** (entre nœuds de calcul ou vers le stockage). Le modèle 3-Tiers crée des **goulots d'étranglement** (oversubscription).

La topologie **Spine-Leaf** (ou **architecture de Clos**) garantit que n'importe quel nœud A est à **exactement un saut** (hop) de n'importe quel nœud B, assurant une **latence prédictible**.

**Schéma : Topologie Spine-Leaf**

```
       +-------------+        +-------------+
       |   Spine 1   |        |   Spine 2   |   <-- Couche de routage (L3)
       | (100/400GbE)|        | (100/400GbE)|       (Aucun serveur connecté ici)
       +--+-------+--+        +--+-------+--+
          |       |              |       |
 +--------+       +-------+------+       +--------+
 |                        |                       |
 |  +------------------+  |  +------------------+ |
 +--+      Leaf 1      +--+--+      Leaf 2      +-+ <-- Couche d'accès (L2/L3)
    |    (Top of Rack) |     |    (Top of Rack) |
    +---+---+---+---+--+     +---+---+---+---+--+
        |   |   |   |            |   |   |   |
      +---+---+---+---+        +---+---+---+---+
      |   Nœuds de    |        |  Nœuds de     |
      |   Calcul 1-40 |        |  Stockage     |
      +---------------+        +---------------+
```

---

### 5.2 MLAG et redondance

Pour éviter les boucles, le protocole **Spanning Tree (STP)** bloque des ports et **divise la bande passante**. En production, on utilise le **MLAG** (Multi-Chassis Link Aggregation) ou le **VPC** (Virtual PortChannel) : un serveur est connecté à **deux switches Leaf** distincts via **LACP** (802.3ad), offrant **redondance ET** cumul de bande passante (Active-Active).

---

### 5.3 Jumbo Frames (MTU 9000)

Le **MTU** (Maximum Transmission Unit) standard Ethernet est **1500** octets. Pour le trafic de stockage (NFS, Ceph, [Lustre](Glossaire-et-Acronymes#l) via LNet TCP), un **MTU de 9000** octets réduit la charge CPU (moins d'interruptions, moins d'en-têtes) et augmente le **throughput**.

**Exemple : Configuration persistante du MTU (NetworkManager)**

```bash
# Configuration Jumbo Frame via nmcli
nmcli connection modify "System eth1" ethernet.mtu 9000
nmcli connection up "System eth1"

# Vérification
ip link show eth1 | grep mtu
```

---

### Piège : « Le MTU Mismatch silencieux »

Si un serveur a un **MTU 9000** et le switch reste à **1500**, les petits pings (ICMP de base) passent, mais les **gros transferts** (SSH avec grosses clés, SCP, montages NFS) peuvent **bloquer** (hang) sans message d'erreur clair.

> **Symptôme courant** : la connexion SSH s'établit, puis bloque après l'affichage du mot de passe.

---

### Check-list production (Chapitre 5)

- [ ] Vérifier le **MTU de bout en bout** avec : `ping -M do -s 8972 <IP_CIBLE>`
- [ ] Activer le **LACP "fast rate"** pour une détection de panne en ~1 s au lieu de 30 s

---

## Chapitre 6 : Interconnexions à faible latence (InfiniBand & RoCE v2)

### Objectifs d'apprentissage

- Comprendre le **RDMA** (Remote Direct Memory Access) et l'**OS Bypass**
- Configurer et diagnostiquer un réseau **InfiniBand** (Subnet Manager, routage)
- Appréhender les défis de **RoCE v2** (Lossless Ethernet, PFC, ECN)

---

### 6.1 RDMA et OS Bypass

En réseau **TCP/IP** classique, envoyer un message implique des copies utilisateur → noyau, calcul des checksums, encapsulation : latence typique **~10 à 50 µs**.

Le **RDMA** permet à une carte réseau (**HCA** — Host Channel Adapter) de **lire/écrire directement** dans la RAM d'un autre serveur, en **contournant l'OS** (OS Bypass) et le CPU. **Latence typique : ~1 à 2 µs.**

---

### 6.2 InfiniBand et le Subnet Manager

InfiniBand n'utilise pas d'adresses MAC ni d'ARP. Les cartes ont des **LID** (Local Identifiers) et des **GUID**. Le réseau IB nécessite un « cerveau » : le **Subnet Manager (SM)** (souvent **opensm**). Il découvre la topologie, assigne les LIDs et calcule les **tables de routage** (ex. MinHop, UpDown pour Fat-Tree, Nue pour Dragonfly).

**Commandes de diagnostic (Mellanox/NVIDIA OFED) :**

```bash
# État du lien local (doit être "Active" et "LinkUp")
ibstat

# Découvrir tous les nœuds de la fabric IB
ibnetdiscover

# DANGER EN PROD : Reset du port IB (coupe les jobs MPI en cours !)
ibportstate 1 1 reset

# Test bande passante RDMA point à point
# Serveur :
ib_write_bw
# Client :
ib_write_bw <IP_IB_DU_SERVEUR>
```

---

### 6.3 RoCE v2 (RDMA over Converged Ethernet)

**RoCE v2** encapsule le trafic RDMA dans des trames **UDP/IP**. Avantage : switches Ethernet standards. Inconvénient : Ethernet est **lossy** (paquets perdus en congestion). RoCE v2 exige un réseau Ethernet **Lossless**, avec réglage sur les switches :

| Protocole | Rôle |
|-----------|------|
| **PFC** (Priority Flow Control) | Met le trafic en pause, classe par classe |
| **ECN** (Explicit Congestion Notification) | Marque les paquets pour demander aux expéditeurs de ralentir |

---

### Piège : « Le SM Split-Brain »

Avoir **plusieurs instances OpenSM** avec la **même priorité** sur différents nœuds, sans configuration maître/esclave : elles se battent pour assigner les LIDs, causant des **micro-coupures** dévastatrices pour les jobs MPI.

---

## Chapitre 7 : Fondations de sécurité HPC

### Objectifs d'apprentissage

- Implémenter une **gestion des identités centralisée** (IAM)
- Concevoir un accès sécurisé via **Bastion**
- **Durcir** le système d'exploitation et isoler les environnements (multi-tenancy)

---

### 7.1 IAM et FreeIPA

Dans un cluster, l'**UID/GID** d'un utilisateur doit être **strictement identique** sur le nœud de login, le manager, tous les nœuds de calcul et le stockage. Aujourd'hui : **LDAP** ou **FreeIPA** (LDAP + Kerberos + PKI).

**Exemple : Création d'un utilisateur HPC via FreeIPA**

```bash
# Authentification admin
kinit admin

# Création utilisateur + assignation à un projet Slurm
ipa user-add jdupont --first="Jean" --last="Dupont" --shell=/bin/bash --uid=1050
ipa group-add-member grp_projet_astro --users=jdupont
```

---

### 7.2 Segmentation et Bastion (Jump Host)

- **Bastion (Login Node)** : seul point d'entrée SSH.
- **MFA** : obligatoire sur le Bastion (ex. TOTP via PAM, ou YubiKey).
- **Segmentation** : les nœuds de calcul n'ont souvent **pas d'accès direct à Internet** ; les téléchargements passent par un **proxy HTTP** (ex. Squid).

---

### 7.3 Hardening OS (durcissement)

En HPC, **SELinux** est parfois en *Permissive* (incompatibilités avec certains FS parallèles ou toolchains). D'autres couches compensent :

| Mesure | Rôle |
|--------|------|
| **Root Squash** | Sur NFS/Lustre : root client est mappé à `nobody` pour ne pas lire les fichiers des autres |
| **Cgroups** | Limite RAM/PIDs par utilisateur, protège le démon [Slurm](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md) (slurmd) |

**Snippet : Sécurité SSH sur les nœuds de calcul** (`/etc/ssh/sshd_config`)

```
# Les utilisateurs ne se connectent aux nœuds de calcul
# QUE via Slurm (PAM slurm), pas par SSH direct.
PermitRootLogin no
PasswordAuthentication no
AllowTcpForwarding no
X11Forwarding no
```

---

## 🧪 Lab 2 : Déploiement d'un annuaire central et intégration

### Énoncé

Vous gérez un cluster (1 Master, 2 Computes).

1. Installez **SSSD** (System Security Services Daemon) sur les nœuds de calcul.
2. Configurez-les pour s'authentifier contre un annuaire **LDAP** (ou un serveur **FreeIPA** sur le Master).
3. Configurez **NFSv4** sur le Master pour exporter `/home`.
4. Montez `/home` sur les nœuds de calcul.

### Critères de réussite

- La commande `id jean_hpc` renvoie le **même UID** (ex. 2001) sur Master, Node01 et Node02.
- L'utilisateur `jean_hpc` peut **créer** un fichier dans `/home/jean_hpc` depuis Node01 et le **lire** depuis Node02, avec les permissions correctes.

### Corrigé (grandes lignes avec Ansible)

```yaml
# 1. Installation SSSD sur les clients
- hosts: computes
  tasks:
    - dnf: name=sssd state=present
    - copy:
        src: sssd.conf   # URI ldap://master, search_base
        dest: /etc/sssd/sssd.conf
        mode: '0600'
    - service: name=sssd state=restarted
    # 2. PAM pour SSSD
    - command: authselect select sssd --force

    # 3. Montage NFS
    - mount:
        path: /home
        src: master:/home
        fstype: nfs4
        opts: rw,soft,intr,rsize=8192,wsize=8192
        state: mounted
```

---

## 📝 Examen de fin de volume 2

### QCM (1 point chaque)

**1.** Quelle est l'utilité principale de l'algorithme de routage **Fat-Tree** configuré dans OpenSM ?  
- A) Assigner des adresses IP aux interfaces InfiniBand  
- B) **Calculer des chemins pour éviter l'engorgement et exploiter les liens redondants de la topologie de Clos**  
- C) Traduire les trames Ethernet en paquets RDMA  

**2.** Pourquoi RoCE v2 est-il qualifié de « Lossless Ethernet » ?  
- A) Parce qu'il utilise TCP pour garantir la livraison  
- B) **Parce qu'il nécessite PFC et ECN au niveau des switches pour éviter toute chute de paquet due à la congestion**  
- C) Parce qu'il utilise des câbles optiques qui ne perdent pas de signal  

---

### Question ouverte (Troubleshooting réseau)

Vous constatez qu'un job MPI **all-to-all** prend **10 fois plus de temps** que la normale. Les `ping` montrent une latence de 0,1 ms. `ibstat` indique que tous les liens sont « Active » à 200 Gbps. **Quel outil** utilisez-vous pour diagnostiquer le réseau IB en profondeur et **que cherchez-vous** ?

**Réponse attendue** : Le ping ne teste pas le réseau IB (il teste l'IP, souvent sur le réseau OOB/Admin). Il faut vérifier **congestion**, **compteurs d'erreurs** et **routage**. Outils : **ibdiagnet** pour la santé de la fabric, **ibqueryerrors** pour des « Symbol Errors » ou « LinkDowned » (câble optique défectueux ou sale → retransmissions).

---

### Étude de cas : « Le trou de sécurité du Root Squash »

Un utilisateur malveillant a obtenu les **droits root** sur le nœud de calcul `node045` (vulnérabilité kernel). Le `/home` est monté en **NFSv4**.

1. **Expliquez** comment le paramètre **root_squash** sur le serveur NFS empêche (théoriquement) cet utilisateur de lire les clés SSH des autres dans `/home`.
2. **Démontrez** par quelle méthode simple (sans utiliser le réseau) cet utilisateur root local peut **contourner** root_squash et usurper l'identité d'un autre utilisateur pour lire ses fichiers.

**Réponses attendues :**

1. **root_squash** mappe l'UID 0 (root) du client vers l'UID `nobody` (ex. 65534) sur le serveur. L'accès aux fichiers de `jdupont` (UID 1050) est donc refusé par le serveur NFS.
2. **Contournement** : En étant root localement, il peut exécuter `su - jdupont`. Les requêtes NFS partent alors avec l'UID 1050 et sont acceptées par le serveur. **Mitigation** : chiffrement des données, ou **NFSv4 + Kerberos** (krb5p) où le ticket Kerberos est requis.

---

## Solutions des QCM

- **Q1** : **B** — Fat-Tree permet d'exploiter la redondance de la topologie Clos pour un routage optimal.
- **Q2** : **B** — RoCE v2 repose sur PFC/ECN pour un Ethernet sans perte.

---

## 📋 Relecture qualité du volume 2

- [x] Couverture : Ethernet datacenter (Spine-Leaf, MTU), InfiniBand/RoCE (RDMA, OpenSM), Sécurité (IAM, Bastion, Root Squash)
- [x] Rigueur technique : MTU mismatch, rôle du Subnet Manager, faille d'usurpation locale
- [x] Format : Markdown, schémas Spine-Leaf
- [x] Pédagogie : TP Ansible LDAP/NFS, cas de troubleshooting (ibdiagnet, faille root)

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-HPC-Sommaire-Complet.md)** : plan des 8 volumes, chapitres, labs
- **[Manuel Architecture HPC — Volume 1](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume1.md)** : fondations, provisioning, Ansible
- **[Cours HPC Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Cours-HPC-Complet.md)** : concepts, parallélisme, stockage
- **[Guide SLURM Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md)** : ordonnancement et jobs
- **[Glossaire et Acronymes](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Glossaire-et-Acronymes.md)** : RDMA, RoCE, LACP, MTU, FreeIPA, etc.
- **[Home](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)** : page d'accueil du wiki

---

**Volume 2** — Réseaux datacenter, interconnexions et sécurité  
**Dernière mise à jour** : 2024
