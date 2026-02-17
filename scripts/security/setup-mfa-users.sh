#!/bin/bash
# ============================================================================
# Configuration MFA pour Utilisateurs - Cluster HPC
# Guide d'utilisation pour les utilisateurs
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION MFA UTILISATEURS${NC}"
echo -e "${BLUE}========================================${NC}"

# Créer guide utilisateur
cat > /usr/local/share/mfa-guide.txt <<'EOF'
========================================
GUIDE MFA - AUTHENTIFICATION MULTI-FACTEUR
========================================

1. INSTALLATION APPLICATION AUTHENTICATOR
   - Google Authenticator (Android/iOS)
   - Authy (Android/iOS/Desktop)
   - Microsoft Authenticator (Android/iOS)

2. CONFIGURATION TOTP
   - Se connecter au cluster
   - Exécuter: google-authenticator
   - Scanner le QR code avec votre application
   - Sauvegarder les codes de récupération

3. UTILISATION
   - Se connecter avec SSH
   - Entrer votre mot de passe
   - Entrer le code TOTP (6 chiffres)
   - Connexion réussie !

4. CODES DE RÉCUPÉRATION
   - Conserver les codes de récupération en sécurité
   - Utiliser en cas de perte de l'appareil

5. SUPPORT
   - Contact: admin@cluster.local
   - Documentation: docs/GUIDE_SECURITE_UTILISATEURS.md
EOF

echo -e "${GREEN}✅ Guide MFA créé: /usr/local/share/mfa-guide.txt${NC}"
echo -e "${YELLOW}Les utilisateurs peuvent maintenant configurer leur MFA${NC}"
