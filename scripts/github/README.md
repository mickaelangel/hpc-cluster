# Scripts de Protection GitHub

## 📋 Scripts Disponibles

### `protect-repository.sh`

Script pour protéger automatiquement la branche `main` du dépôt GitHub.

**Usage** :
```bash
bash scripts/github/protect-repository.sh
```

**Prérequis** :
- GitHub CLI (`gh`) installé
- Authentification GitHub (`gh auth login`)

**Ce que fait le script** :
- ✅ Active la protection de branche `main`
- ✅ Requiert des pull requests avant merge
- ✅ Requiert 1 approbation
- ✅ Active CODEOWNERS
- ✅ Désactive force pushes
- ✅ Désactive suppression de branche
- ✅ Restreint les pushes à vous seul
- ✅ **IMPORTANT** : `enforce_admins=false` (vous pouvez toujours push directement)

## 🔧 Configuration Manuelle

Voir [docs/GUIDE_PROTECTION_GITHUB.md](../../docs/GUIDE_PROTECTION_GITHUB.md) pour la configuration manuelle via l'interface web GitHub.

## 📝 Fichier CODEOWNERS

Le fichier `.github/CODEOWNERS` définit que tous les fichiers nécessitent votre approbation.

**Contenu** :
```
* @mickaelangel
```

## ✅ Vérification

```bash
# Vérifier la protection
gh api repos/mickaelangel/hpc-cluster/branches/main/protection
```
