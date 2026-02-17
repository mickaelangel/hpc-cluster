# Guide d'Installation Complet - TrinityX + Warewulf
## Cluster HPC SUSE 15 SP7 avec GPFS, MATLAB, OpenM++

**Classification**: Documentation Technique - Niveau Sénior  
**Version**: 1.0  
**Date**: 2024  
**Environnement**: SUSE Linux Enterprise Server 15 SP7 / openSUSE Leap 15.4

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Architecture](#architecture)
4. [Installation TrinityX + Warewulf](#installation-trinityx--warewulf)
5. [Configuration GPFS](#configuration-gpfs)
6. [Intégration MATLAB et OpenM++](#intégration-matlab-et-openm)
7. [Configuration Monitoring](#configuration-monitoring)
8. [Déploiement des Nœuds](#déploiement-des-nœuds)
9. [Vérification et Tests](#vérification-et-tests)
10. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

**TrinityX** est une solution de gestion de cluster HPC basée sur **Warewulf** (provisioning) avec une interface web de management. TrinityX utilise Warewulf comme backend pour le provisioning des nœuds, mais ajoute une couche d'orchestration et de gestion.

### Compatibilité TrinityX ↔ Warewulf

✅ **OUI, 100% compatible** : TrinityX est une couche de management au-dessus de Warewulf. Toutes les commandes Warewulf (`wwctl`) fonctionnent directement, et TrinityX ajoute :
- Interface web de gestion
- Orchestration automatisée
- Gestion des images et overlays
- Monitoring intégré

### Stack Complet

- **OS**: SUSE 15 SP4 / openSUSE Leap 15.4
- **Provisioning**: Warewulf 4.x (via TrinityX)
- **Stockage**: BeeGFS 7.3 / Lustre 2.15 (open-source, remplace GPFS)
- **Scheduler**: Slurm 23.11
- **Monitoring**: Prometheus + Grafana + InfluxDB + Telegraf + Loki
- **Software**: GROMACS, OpenFOAM, Quantum ESPRESSO, ParaView, Spack, Nexus
- **Remote Graphics**: X2Go, NoMachine (open-source, remplace Exceed TurboX)
- **Sécurité**: Kerberos, LDAP (389 Directory Server) / FreeIPA

---

## 📦 Prérequis

### Matériel

**Nœud Contrôleur (TrinityX/Warewulf)**:
- CPU: 4+ cœurs
- RAM: 16GB minimum (32GB recommandé)
- Disque: 500GB+ (pour images et cache)
- Réseau: 2 interfaces (1 management, 1 PXE/DHCP)

**Nœuds Frontaux GPFS** (2x):
- CPU: 24+ cœurs
- RAM: 128GB+
- Disque: 4+ disques pour NSD (SAS/NVMe)
- Réseau: InfiniBand (100 Gb/s) + Ethernet

**Nœuds de Calcul** (6x):
- CPU: 32+ cœurs
- RAM: 256GB+
- Disque: 100GB+ (OS local)
- Réseau: InfiniBand (100 Gb/s) + Ethernet

### Logiciel

**Sur le Nœud Contrôleur**:
- SUSE 15 SP7 ou openSUSE Leap 15.4
- Docker 20.10+ (pour TrinityX)
- Accès Internet (pour téléchargements initiaux)
- Packages: `git`, `make`, `gcc`, `python3`, `go` (1.19+)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    NŒUD CONTRÔLEUR                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  TrinityX    │  │  Warewulf     │  │  DHCP/TFTP    │    │
│  │  (Web UI)     │  │  (Provision)  │  │  (PXE Boot)   │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Prometheus  │  │  Grafana      │  │  InfluxDB    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│  Frontal-01  │  │  Frontal-02  │  │  Node-01-06  │
│  (GPFS NSD)  │  │  (GPFS NSD)  │  │  (Compute)   │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🚀 Installation TrinityX + Warewulf

### Étape 1: Installation des Dépendances

```bash
# Sur le nœud contrôleur (SUSE 15 SP7)
sudo zypper refresh

# Activation des modules nécessaires
sudo SUSEConnect -p PackageHub/15.7/x86_64
sudo SUSEConnect -p sle-module-containers/15.7/x86_64
sudo SUSEConnect -p sle-module-hpc/15.7/x86_64

# Installation des dépendances de base
sudo zypper install -y \
    git make gcc gcc-c++ \
    python3 python3-pip python3-devel \
    golang go \
    docker docker-compose \
    tftp-server dhcp-server \
    nfs-kernel-server \
    openssh openssh-server \
    vim htop wget curl jq

# Démarrage Docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Se déconnecter/reconnecter pour activer le groupe
```

### Étape 2: Installation de Warewulf

```bash
# Création du répertoire de travail
sudo mkdir -p /opt/warewulf
cd /opt/warewulf

# Clonage de Warewulf (version 4.x)
git clone https://github.com/hpcng/warewulf.git
cd warewulf

# Compilation et installation
make
sudo make install

# Configuration initiale
sudo wwctl configure --all

# Vérification
sudo wwctl version
```

### Étape 3: Installation de TrinityX

```bash
# Option 1: Installation via Docker (Recommandé)
cd /opt
git clone https://github.com/TrinityX/trinityx.git
cd trinityx

# Configuration Docker Compose
cp docker-compose.yml.example docker-compose.yml
# Éditer docker-compose.yml avec vos paramètres

# Démarrage TrinityX
docker-compose up -d

# Vérification
docker-compose ps
curl http://localhost:8080/health

# Option 2: Installation depuis sources (Alternative)
cd /opt
git clone https://github.com/TrinityX/trinityx-web.git
cd trinityx-web
pip3 install -r requirements.txt
python3 app.py
```

### Étape 4: Configuration Warewulf de Base

```bash
# Configuration du réseau PXE
sudo vim /etc/warewulf/warewulf.conf

# Exemple de configuration:
# {
#   "ipaddr": "192.168.1.1",
#   "netmask": "255.255.255.0",
#   "network": "192.168.1.0",
#   "tftp": {
#     "enabled": true,
#     "path": "/var/lib/tftpboot"
#   },
#   "dhcp": {
#     "enabled": true,
#     "range start": "192.168.1.100",
#     "range end": "192.168.1.200"
#   }
# }

# Redémarrage des services
sudo systemctl enable --now warewulfd
sudo systemctl enable --now tftp
sudo systemctl enable --now dhcpd
```

---

## 💾 Configuration GPFS

### Étape 1: Préparation des Images

```bash
# Création de l'image frontale GPFS
sudo wwctl image create --name sles15-sp7-frontal \
    --chroot /var/lib/warewulf/chroots/sles15-sp7-frontal

# Installation des packages de base dans le chroot
sudo wwctl image exec sles15-sp7-frontal -- \
    zypper --non-interactive install \
    aaa_base systemd kernel-default kernel-devel \
    gcc make ksh libaio1 libnsl2 \
    rdma-core infiniband-diags \
    openssh openssh-server \
    vim htop

# Installation GPFS (copier les RPMs dans le chroot)
sudo cp /path/to/gpfs/*.rpm /var/lib/warewulf/chroots/sles15-sp7-frontal/tmp/
sudo wwctl image exec sles15-sp7-frontal -- \
    rpm -ivh /tmp/gpfs.base-*.rpm \
    /tmp/gpfs.gpl-*.rpm \
    /tmp/gpfs.gskit-*.rpm \
    /tmp/gpfs.msg.*.rpm \
    /tmp/gpfs.compression-*.rpm \
    /tmp/gpfs.nfs-ganesha-*.rpm

# Compilation du module kernel GPFS
sudo wwctl image exec sles15-sp7-frontal -- \
    /usr/lpp/mmfs/bin/mmbuildgpl

# Création utilisateur gpfs (UID/GID fixes)
sudo wwctl image exec sles15-sp7-frontal -- \
    groupadd -g 3000 gpfs
sudo wwctl image exec sles15-sp7-frontal -- \
    useradd -u 3000 -g gpfs -d /home/gpfs -s /bin/bash gpfs

# Build de l'image
sudo wwctl image build sles15-sp7-frontal
```

### Étape 2: Création de l'Image Client

```bash
# Image pour nœuds de calcul
sudo wwctl image create --name sles15-sp7-compute \
    --chroot /var/lib/warewulf/chroots/sles15-sp7-compute

# Installation packages
sudo wwctl image exec sles15-sp7-compute -- \
    zypper --non-interactive install \
    aaa_base systemd kernel-default kernel-devel \
    gcc make ksh libaio1 libnsl2 \
    rdma-core infiniband-diags \
    slurm-slurmd munge \
    openmpi4 mpich \
    numactl hwloc

# Installation GPFS client (packages minimaux)
sudo cp /path/to/gpfs-client/*.rpm /var/lib/warewulf/chroots/sles15-sp7-compute/tmp/
sudo wwctl image exec sles15-sp7-compute -- \
    rpm -ivh /tmp/gpfs.base-*.rpm \
    /tmp/gpfs.gpl-*.rpm \
    /tmp/gpfs.gskit-*.rpm \
    /tmp/gpfs.msg.*.rpm

# Compilation module
sudo wwctl image exec sles15-sp7-compute -- \
    /usr/lpp/mmfs/bin/mmbuildgpl

# Build
sudo wwctl image build sles15-sp7-compute
```

### Étape 3: Configuration du Cluster GPFS

```bash
# Sur frontal-01 (premier nœud démarré)
# Création du cluster
mmcrcluster -N \
    frontal-01:quorum-manager:frontal-01,frontal-02:admin:frontal-01,frontal-02,\
    frontal-02:quorum-manager:frontal-01,frontal-02:admin:frontal-01,frontal-02,\
    node-01:quorum:frontal-01,frontal-02,\
    node-02::frontal-01,frontal-02,\
    node-03::frontal-01,frontal-02,\
    node-04::frontal-01,frontal-02,\
    node-05::frontal-01,frontal-02,\
    node-06::frontal-01,frontal-02 \
    -C hpc-cluster -A

# Démarrage GPFS sur tous les nœuds
mmstartup -a

# Création des NSD (exemple avec /dev/sdb, /dev/sdc, etc.)
cat > /tmp/nsd.def <<EOF
nsd1:frontal-01,frontal-02:/dev/sdb:::dataOnly:system::
nsd2:frontal-01,frontal-02:/dev/sdc:::dataOnly:system::
nsd3:frontal-01,frontal-02:/dev/sdd:::dataOnly:system::
nsd4:frontal-01,frontal-02:/dev/sde:::dataOnly:system::
EOF

mmcrnsd -F /tmp/nsd.def

# Création du filesystem
mmcrfs gpfsfs1 -F /tmp/nsd.def \
    -A yes \
    -m 2 \
    -r 2 \
    -M 2 \
    -R 2 \
    -Q yes \
    --version=latest

# Montage
mmmount gpfsfs1 -a

# Vérification
mmlscluster
mmlsfs gpfsfs1
df -h /gpfs/gpfsfs1
```

---

## 🔬 Intégration MATLAB et OpenM++

### Étape 1: Installation MATLAB dans l'Image

```bash
# Montage de l'image pour installation MATLAB
sudo wwctl image exec sles15-sp7-compute -- bash

# Dans le chroot, installer MATLAB
# (Copier l'installateur MATLAB depuis votre média)
cd /tmp
./install -inputFile /path/to/installer_input.txt \
    -mode silent \
    -agreeToLicense yes \
    -fileInstallationKey YOUR_KEY \
    -destinationFolder /opt/matlab

# Configuration MATLAB Distributed Computing Server (MDCS)
cd /opt/matlab/toolbox/distcomp/bin
./mdce install
./mdce start

# Configuration du cluster profile
# (Créer un fichier de configuration)
cat > /opt/matlab/cluster_profile_hpc.m <<'EOF'
function profile = cluster_profile_hpc()
    profile = parallel.cluster.Generic;
    profile.JobStorageLocation = '/gpfs/gpfsfs1/matlab/jobs';
    profile.HasSharedFilesystem = true;
    profile.NumWorkers = 256;
    profile.ClusterMatlabRoot = '/opt/matlab';
end
EOF

# Sortie du chroot
exit

# Rebuild de l'image
sudo wwctl image build sles15-sp7-compute
```

### Étape 2: Installation OpenM++

```bash
# Dans l'image compute
sudo wwctl image exec sles15-sp7-compute -- bash

# Installation des dépendances
zypper install -y \
    sqlite3 sqlite3-devel \
    r-base r-base-devel \
    python3 python3-devel python3-pip \
    gcc gcc-c++ make cmake

# Compilation OpenM++
cd /tmp
git clone https://github.com/openmpp/openmpp.git
cd openmpp
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/openm
make -j$(nproc)
make install

# Configuration Environment Modules (Lmod)
mkdir -p /opt/modules/openm/1.15.2
cat > /opt/modules/openm/1.15.2/modulefile <<'EOF'
#%Module1.0
proc ModulesHelp { } {
    puts stderr "OpenM++ 1.15.2 - Microsimulation Framework"
}
module-whatis "OpenM++ v1.15.2"
prepend-path PATH /opt/openm/bin
prepend-path LD_LIBRARY_PATH /opt/openm/lib
setenv OPENM_HOME /opt/openm
EOF

exit
sudo wwctl image build sles15-sp7-compute
```

### Étape 3: Configuration Spack (Optionnel)

```bash
# Installation Spack dans l'image
sudo wwctl image exec sles15-sp7-compute -- bash

cd /opt
git clone https://github.com/spack/spack.git
cd spack
. share/spack/setup-env.sh

# Configuration pour SUSE 15 SP7
spack compiler find
spack install gcc@13.2.0
spack install openmpi@4.1.5

exit
sudo wwctl image build sles15-sp7-compute
```

---

## 📊 Configuration Monitoring

### Étape 1: Installation Telegraf dans les Images

```bash
# Téléchargement Telegraf
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.29.0-1.x86_64.rpm

# Installation dans l'image frontale
sudo cp telegraf-1.29.0-1.x86_64.rpm \
    /var/lib/warewulf/chroots/sles15-sp7-frontal/tmp/
sudo wwctl image exec sles15-sp7-frontal -- \
    rpm -ivh /tmp/telegraf-1.29.0-1.x86_64.rpm

# Configuration Telegraf
sudo wwctl image exec sles15-sp7-frontal -- \
    cat > /etc/telegraf/telegraf.conf <<'EOF'
[global_tags]
  cluster = "hpc-cluster"
  node = "$HOSTNAME"

[agent]
  interval = "10s"
  round_interval = true

[[outputs.influxdb_v2]]
  urls = ["http://192.168.1.1:8086"]
  token = "YOUR_TOKEN"
  organization = "hpc-cluster"
  bucket = "hpc-metrics"

[[inputs.cpu]]
[[inputs.mem]]
[[inputs.disk]]
[[inputs.diskio]]
[[inputs.net]]
[[inputs.processes]]
[[inputs.system]]

# GPFS Metrics (frontal seulement)
[[inputs.exec]]
  commands = ["/usr/lpp/mmfs/bin/mmlsfs all -Y"]
  interval = "30s"
  data_format = "influx"
EOF

# Même procédure pour l'image compute
sudo cp telegraf-1.29.0-1.x86_64.rpm \
    /var/lib/warewulf/chroots/sles15-sp7-compute/tmp/
sudo wwctl image exec sles15-sp7-compute -- \
    rpm -ivh /tmp/telegraf-1.29.0-1.x86_64.rpm

# Rebuild
sudo wwctl image build sles15-sp7-frontal
sudo wwctl image build sles15-sp7-compute
```

---

## 🖥️ Déploiement des Nœuds

### Étape 1: Configuration des Nœuds dans Warewulf

```bash
# Définition des nœuds frontaux
sudo wwctl node set frontal-01 \
    --image sles15-sp7-frontal \
    --kernel $(uname -r) \
    --netname eth0 --ipaddr 192.168.1.10 --netmask 255.255.255.0 \
    --netname ib0 --ipaddr 10.10.10.11 --netmask 255.255.255.0 \
    --profile default

sudo wwctl node set frontal-02 \
    --image sles15-sp7-frontal \
    --kernel $(uname -r) \
    --netname eth0 --ipaddr 192.168.1.11 --netmask 255.255.255.0 \
    --netname ib0 --ipaddr 10.10.10.12 --netmask 255.255.255.0 \
    --profile default

# Définition des nœuds de calcul
for i in {01..06}; do
    id=${i#0}  # Enlève le zéro (01 -> 1)
    sudo wwctl node set node-$i \
        --image sles15-sp7-compute \
        --kernel $(uname -r) \
        --netname eth0 --ipaddr 192.168.1.$((20+id)) --netmask 255.255.255.0 \
        --netname ib0 --ipaddr 10.10.10.$((100+id)) --netmask 255.255.255.0 \
        --profile default
done

# Vérification
sudo wwctl node list
```

### Étape 2: Création des Overlays

```bash
# Overlay pour configuration GPFS
sudo wwctl overlay create gpfs-config
sudo mkdir -p /var/lib/warewulf/overlays/gpfs-config/rootfs/etc/mmfs

# Fichier de configuration GPFS
sudo cat > /var/lib/warewulf/overlays/gpfs-config/rootfs/etc/mmfs/mmfsf.env <<'EOF'
MMFS_NODE_TYPE=client
MMFS_ADMIN_NODE=frontal-01,frontal-02
MMFS_QUORUM_NODE=frontal-01,frontal-02,node-01
MMFS_NETWORK_IB=ib0
MMFS_NETWORK_ETH=eth0
MMFS_PAGEPOOL=8G
EOF

# Overlay pour configuration Slurm
sudo wwctl overlay create slurm-config
sudo mkdir -p /var/lib/warewulf/overlays/slurm-config/rootfs/etc/slurm

# Configuration Slurm (à adapter)
sudo cp /path/to/slurm.conf \
    /var/lib/warewulf/overlays/slurm-config/rootfs/etc/slurm/

# Application des overlays au profile
sudo wwctl profile set --overlay-add gpfs-config --overlay-add slurm-config default

# Build des overlays
sudo wwctl overlay build
```

### Étape 3: Boot des Nœuds

```bash
# Activation PXE pour tous les nœuds
sudo wwctl node ready frontal-01 frontal-02 \
    node-01 node-02 node-03 node-04 node-05 node-06

# Vérification du statut
sudo wwctl node status

# Boot des machines (via IPMI ou manuellement)
# Les nœuds booteront via PXE et chargeront l'image Warewulf
```

---

## ✅ Vérification et Tests

### Tests de Base

```bash
# Vérification Warewulf
sudo wwctl version
sudo wwctl node list
sudo wwctl image list

# Vérification GPFS (sur un nœud frontal)
ssh frontal-01
mmlscluster
mmlsfs gpfsfs1
df -h /gpfs/gpfsfs1

# Vérification Slurm
sinfo
squeue
scontrol show nodes

# Vérification MATLAB
module load matlab/R2023b
matlab -nodisplay -r "parpool('local', 4); exit"

# Vérification OpenM++
module load openm/1.15.2
omc --version

# Vérification Monitoring
curl http://192.168.1.1:9090/api/v1/targets  # Prometheus
curl http://192.168.1.1:3000  # Grafana
```

---

## 🔧 Dépannage

### Problèmes de Boot PXE

```bash
# Vérifier les services
sudo systemctl status warewulfd
sudo systemctl status tftp
sudo systemctl status dhcpd

# Vérifier les logs
sudo journalctl -u warewulfd -f
sudo tail -f /var/log/messages

# Vérifier la configuration réseau
sudo wwctl configure --show
```

### Problèmes GPFS

```bash
# Vérifier l'état du cluster
mmgetstate -a
mmhealth node show
mmhealth cluster show

# Vérifier les logs
tail -f /var/mmfs/log/mmfs.log

# Redémarrer GPFS
mmstartup -a
```

### Problèmes TrinityX

```bash
# Vérifier les conteneurs Docker
docker-compose ps
docker-compose logs

# Redémarrer
docker-compose restart
```

---

## 📝 Notes Importantes

1. **UID/GID fixes** : L'utilisateur `gpfs` doit avoir le même UID/GID (3000) sur tous les nœuds
2. **Kernel modules** : Les modules GPFS doivent être compilés pour chaque version de kernel
3. **Réseau** : InfiniBand doit être configuré avec IPoIB avant le démarrage GPFS
4. **Licences MATLAB** : Configurer le serveur de licences avant le déploiement
5. **Sécurité** : Changer tous les mots de passe par défaut en production

---

## 📚 Ressources

- **Warewulf**: https://warewulf.org/
- **TrinityX**: https://github.com/TrinityX/trinityx
- **GPFS**: Documentation IBM Spectrum Scale
- **Slurm**: https://slurm.schedmd.com/
- **MATLAB DCS**: https://www.mathworks.com/products/distriben.html

---

**Version**: 1.0  
**Dernière mise à jour**: 2024  
**Maintenu par**: HPC Team
