# Guide d'Utilisation du Cluster SANS MATLAB
## Le Cluster Fonctionne Parfaitement Sans MATLAB

**Classification**: Documentation Utilisateur  
**Public**: Tous les Utilisateurs  
**Version**: 1.0  
**Date**: 2024

---

## ✅ Le Cluster Fonctionne SANS MATLAB

**Vous n'avez PAS besoin de MATLAB pour utiliser le cluster !**

Tous les composants du cluster fonctionnent indépendamment de MATLAB :
- ✅ Slurm (scheduler)
- ✅ GPFS (stockage)
- ✅ LDAP/Kerberos/FreeIPA (authentification)
- ✅ Prometheus/Grafana (monitoring)
- ✅ TrinityX/Warewulf (provisioning)
- ✅ Tous les autres composants

---

## 🚀 Alternatives Gratuites

### 1. Python (Recommandé)

**Installation** :
```bash
# Python est déjà installé
python3 --version

# Installer des packages
pip3 install numpy scipy matplotlib pandas
```

**Exemple de job** :
```bash
#!/bin/bash
#SBATCH --job-name=python_calc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=02:00:00

python3 my_script.py
```

**Voir** : `examples/jobs/exemple-python.sh`

---

### 2. R (Statistiques)

**Installation** :
```bash
# R est déjà installé
R --version
```

**Exemple de job** :
```bash
#!/bin/bash
#SBATCH --job-name=r_analysis
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=02:00:00

Rscript my_analysis.R
```

---

### 3. Octave (Alternative MATLAB)

**Installation** :
```bash
# Installer Octave
zypper install octave
# ou
spack install octave
```

**Exemple de job** :
```bash
#!/bin/bash
#SBATCH --job-name=octave_calc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=02:00:00

octave --no-gui my_script.m
```

**Avantage** : Syntaxe compatible MATLAB !

---

### 4. OpenM++ (Simulation)

**Installation** :
```bash
# OpenM++ est déjà installé
module load openm/1.15.2
```

**Exemple de job** :
```bash
#!/bin/bash
#SBATCH --job-name=openm_sim
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --time=04:00:00

module load openm/1.15.2
omc run my_model.xml
```

---

## 📝 Scripts à Ignorer (Optionnels)

Ces scripts sont **optionnels** si vous n'utilisez pas MATLAB :

- ❌ `scripts/flexlm/install-flexlm.sh` - License server MATLAB
- ❌ Sections MATLAB dans la documentation
- ❌ `examples/jobs/exemple-matlab.sh` - Exemple MATLAB

**Vous pouvez utiliser le cluster sans installer ces composants !**

---

## 🎯 Installation du Cluster

### Installation Standard (SANS MATLAB)

```bash
# 1. Authentification
cd cluster\ hpc/scripts
sudo ./install-ldap-kerberos.sh  # ou install-freeipa.sh

# 2. Sécurité
cd security
sudo ./hardening.sh

# 3. Monitoring (déjà dans docker-compose)
# Prometheus, Grafana, InfluxDB, Telegraf

# 4. Autres composants
# ... (tous les autres scripts fonctionnent sans MATLAB)
```

**Aucun script MATLAB n'est nécessaire !**

---

## 📊 Comparaison

| Fonctionnalité | MATLAB | Python | Octave | R |
|----------------|--------|--------|--------|---|
| **Gratuit** | ❌ | ✅ | ✅ | ✅ |
| **Calcul scientifique** | ✅ | ✅ | ✅ | ✅ |
| **Parallélisation** | ✅ | ✅ | ⚠️ | ✅ |
| **Visualisation** | ✅ | ✅ | ✅ | ✅ |
| **Statistiques** | ✅ | ✅ | ⚠️ | ✅✅ |

---

## ✅ Conclusion

**Le cluster fonctionne parfaitement SANS MATLAB !**

Utilisez :
- ✅ **Python** pour calcul scientifique
- ✅ **R** pour statistiques
- ✅ **Octave** pour migration MATLAB
- ✅ **OpenM++** pour simulation
- ✅ **C/C++/Fortran** pour performance

**Tous ces outils sont gratuits et open-source !** 🚀

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
