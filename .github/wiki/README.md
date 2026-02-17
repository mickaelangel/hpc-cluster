# 📚 Wiki GitHub - Guide d'Utilisation

> **Guide pour utiliser et maintenir le Wiki GitHub**

---

## 🎯 Vue d'Ensemble

Ce répertoire contient tous les fichiers Markdown du Wiki GitHub pour le projet **Cluster HPC Enterprise**.

---

## 📋 Pages Disponibles

### Pages Principales

1. **Home.md** - Page d'accueil du Wiki
2. **Installation-Rapide.md** - Guide d'installation en 5 minutes
3. **Configuration-de-Base.md** - Configuration minimale fonctionnelle
4. **FAQ.md** - Questions fréquentes
5. **Depannage.md** - Guide de résolution de problèmes
6. **Astuces.md** - Astuces et optimisations
7. **Commandes-Utiles.md** - Référence rapide des commandes
8. **Monitoring.md** - Guide complet du monitoring

---

## 🚀 Comment Utiliser

### Option 1 : Via l'Interface GitHub

1. Aller sur https://github.com/mickaelangel/hpc-cluster/wiki
2. Cliquer sur **"New Page"** ou **"Edit"** sur une page existante
3. Copier le contenu du fichier `.md` correspondant
4. Coller dans l'éditeur GitHub
5. Sauvegarder

### Option 2 : Via Git (Recommandé)

Le Wiki GitHub est un repository Git séparé :

```bash
# Cloner le Wiki
git clone https://github.com/mickaelangel/hpc-cluster.wiki.git

# Copier les fichiers
cp .github/wiki/*.md hpc-cluster.wiki/

# Commit et push
cd hpc-cluster.wiki
git add .
git commit -m "Update wiki pages"
git push origin master
```

### Option 3 : Via Script Automatique

```bash
# Script d'upload automatique (à créer)
./scripts/upload-wiki.sh
```

---

## 📝 Structure des Fichiers

```
.github/wiki/
├── README.md                    # Ce fichier
├── Home.md                      # Page d'accueil
├── Installation-Rapide.md       # Installation
├── Configuration-de-Base.md     # Configuration
├── FAQ.md                        # FAQ
├── Depannage.md                  # Dépannage
├── Astuces.md                    # Astuces
├── Commandes-Utiles.md          # Commandes
└── Monitoring.md                 # Monitoring
```

---

## ✏️ Modifier une Page

### Éditer Localement

1. Modifier le fichier `.md` dans `.github/wiki/`
2. Tester le rendu Markdown localement
3. Uploader sur GitHub (voir options ci-dessus)

### Format Markdown

Les fichiers utilisent le format Markdown standard GitHub :
- Titres avec `#`
- Code blocks avec ` ``` `
- Liens avec `[texte](lien)`
- Tableaux avec `|`

---

## 🔗 Liens Inter-Wiki

Les pages utilisent des liens relatifs entre elles :

```markdown
[Installation Rapide](Installation-Rapide)
[FAQ](FAQ)
[Dépannage](Depannage)
```

Ces liens fonctionnent automatiquement dans le Wiki GitHub.

---

## 📚 Contenu des Pages

### Home.md
- Navigation principale
- Vue d'ensemble de l'architecture
- Liens vers toutes les pages
- Quick start

### Installation-Rapide.md
- Prérequis
- Installation en 3 étapes
- Configuration initiale
- Tests de validation

### Configuration-de-Base.md
- Configuration Prometheus
- Configuration Grafana
- Configuration InfluxDB
- Configuration Slurm
- Sécurité de base

### FAQ.md
- Questions sur l'installation
- Questions sur la configuration
- Questions sur le monitoring
- Questions sur la sécurité
- Questions sur le dépannage

### Depannage.md
- Diagnostic système
- Problèmes courants
- Solutions détaillées
- Scripts de diagnostic

### Astuces.md
- Optimisations performance
- Sécurité avancée
- Monitoring avancé
- Automatisation
- Scaling

### Commandes-Utiles.md
- Prometheus
- Grafana
- InfluxDB
- Slurm
- Système
- Docker/Podman

### Monitoring.md
- Architecture
- Configuration
- Métriques clés
- Dashboards
- Alertes

---

## 🎨 Style et Formatage

### Titres
```markdown
# Titre Principal
## Sous-titre
### Section
```

### Code
```markdown
```bash
command
```
```

### Liens
```markdown
[Texte du lien](URL)
```

### Tableaux
```markdown
| Colonne 1 | Colonne 2 |
|-----------|-----------|
| Donnée 1   | Donnée 2  |
```

---

## 🔄 Mise à Jour

### Processus Recommandé

1. **Modifier localement** : Éditer les fichiers `.md`
2. **Tester** : Vérifier le rendu Markdown
3. **Commit** : Commiter les changements
4. **Push** : Pousser vers GitHub
5. **Vérifier** : Vérifier sur le Wiki GitHub

### Fréquence

- **Mise à jour majeure** : Après chaque release
- **Corrections** : Au besoin
- **Nouvelles fonctionnalités** : Immédiatement

---

## 📖 Ressources

- **Documentation GitHub Wiki** : https://docs.github.com/en/communities/documenting-your-project-with-wikis
- **Markdown Guide** : https://www.markdownguide.org/
- **GitHub Flavored Markdown** : https://github.github.com/gfm/

---

## 🤝 Contribution

Pour contribuer au Wiki :

1. Fork le repository
2. Modifier les fichiers dans `.github/wiki/`
3. Créer une Pull Request
4. Une fois mergée, uploader sur le Wiki GitHub

---

**Dernière mise à jour** : 2024  
**Maintenu par** : La communauté HPC
