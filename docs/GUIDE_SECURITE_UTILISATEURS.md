# Guide Sécurité Utilisateurs - Cluster HPC
## Bonnes Pratiques et Formation Sécurité

**Classification**: Documentation Utilisateur  
**Public**: Tous les Utilisateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Authentification Sécurisée](#authentification-sécurisée)
2. [Protection des Mots de Passe](#protection-des-mots-de-passe)
3. [Sécurité des Jobs](#sécurité-des-jobs)
4. [Protection des Données](#protection-des-données)
5. [Reconnaissance Phishing](#reconnaissance-phishing)
6. [Bonnes Pratiques](#bonnes-pratiques)

---

## 🔐 Authentification Sécurisée

### Mots de Passe Forts

**Règles** :
- Minimum 12 caractères
- Majuscules, minuscules, chiffres, caractères spéciaux
- Ne pas réutiliser de mots de passe
- Changer régulièrement (tous les 90 jours)

### Authentification Multi-Facteur (MFA)

**Si activé** :
- Configurer TOTP (Google Authenticator)
- Utiliser YubiKey si disponible
- Ne jamais partager vos codes MFA

---

## 🛡️ Protection des Mots de Passe

### À Faire ✅
- Utiliser un gestionnaire de mots de passe
- Activer MFA si disponible
- Changer le mot de passe si compromis

### À Éviter ❌
- Écrire le mot de passe sur papier
- Partager le mot de passe
- Utiliser le même mot de passe partout
- Envoyer le mot de passe par email

---

## 🔒 Sécurité des Jobs

### Données Sensibles
- Ne pas stocker de données sensibles dans les jobs
- Utiliser Vault pour les secrets
- Chiffrer les fichiers sensibles (GPG)

### Partage de Ressources
- Respecter les quotas
- Ne pas monopoliser les ressources
- Nettoyer les fichiers temporaires

---

## 📊 Protection des Données

### Chiffrement
- Utiliser GPG pour fichiers sensibles
- Utiliser LUKS pour disques externes
- Ne jamais envoyer données sensibles en clair

### Sauvegarde
- Sauvegarder régulièrement vos données
- Vérifier l'intégrité des sauvegardes
- Ne pas stocker de données sensibles sans chiffrement

---

## 🎣 Reconnaissance Phishing

### Signes d'Alertes
- Email suspect (expéditeur inconnu)
- Liens suspects
- Demandes de mots de passe
- Urgence artificielle

### Que Faire
- Ne pas cliquer sur les liens suspects
- Vérifier l'expéditeur
- Signaler à l'administrateur
- Ne jamais donner votre mot de passe

---

## ✅ Bonnes Pratiques

### Général
- Verrouiller votre session quand vous partez
- Ne pas partager vos identifiants
- Signaler les incidents de sécurité
- Suivre les procédures de sécurité

### Réseau
- Utiliser VPN pour accès distant
- Ne pas utiliser WiFi public non sécurisé
- Vérifier les certificats SSL

---

**Version**: 1.0
