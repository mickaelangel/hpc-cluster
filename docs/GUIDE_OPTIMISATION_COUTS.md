# Guide Optimisation Coûts - Cluster HPC
## Réduction des Coûts Opérationnels

**Classification**: Documentation Coûts  
**Public**: Administrateurs / Finance  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Analyse Coûts](#analyse-coûts)
2. [Optimisation Ressources](#optimisation-ressources)
3. [Réduction Consommation](#réduction-consommation)

---

## 💰 Analyse Coûts

### Coûts par Utilisateur

```bash
# Calculer coûts CPU-heures
sacct --format=User,CPU,Elapsed --starttime=$(date -d "30 days ago" +%Y-%m-%d)
```

---

## ⚡ Optimisation Ressources

### Réduction Consommation Énergétique

```bash
# Activer CPU governor powersave
cpupower frequency-set -g powersave
```

---

**Version**: 1.0
