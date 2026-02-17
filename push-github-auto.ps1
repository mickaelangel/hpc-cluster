# ============================================================================
# Script automatique pour pousser le projet Cluster HPC sur GitHub
# Utilise l'API GitHub pour créer le dépôt et pousser le code
# ============================================================================

$GitHubUsername = "mickaelangelcv"
$GitHubEmail = "mickaelangelcv@gmail.com"
$GitHubPassword = "@Ght7vtt9ovtt12"
$RepoName = "hpc-cluster"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "PUBLICATION AUTOMATIQUE SUR GITHUB" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Note: GitHub ne permet plus l'authentification par mot de passe depuis 2021
# Il faut utiliser un Personal Access Token (PAT)
Write-Host "⚠️  IMPORTANT: GitHub nécessite un Personal Access Token (PAT)" -ForegroundColor Yellow
Write-Host "   Le mot de passe ne fonctionnera pas pour l'API GitHub." -ForegroundColor Yellow
Write-Host ""
Write-Host "Création d'un token:" -ForegroundColor Cyan
Write-Host "1. Aller sur: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "2. Cliquer sur 'Generate new token (classic)'" -ForegroundColor White
Write-Host "3. Nom: HPC Cluster Push" -ForegroundColor White
Write-Host "4. Permissions: repo (toutes les permissions repo)" -ForegroundColor White
Write-Host "5. Copier le token" -ForegroundColor White
Write-Host ""

$GitHubToken = Read-Host "Collez votre Personal Access Token ici" -AsSecureString
$GitHubToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($GitHubToken)
)

if ([string]::IsNullOrEmpty($GitHubToken)) {
    Write-Host "❌ Token requis. Annulation." -ForegroundColor Red
    exit 1
}

# Créer le dépôt via l'API GitHub
Write-Host ""
Write-Host "Création du dépôt sur GitHub..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "token $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    name = $RepoName
    description = "Cluster HPC complet - 2 frontaux + 6 nœuds + monitoring complet (100% Open-Source)"
    private = $false
    auto_init = $false
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "✅ Dépôt créé: $($response.html_url)" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "⚠️  Le dépôt existe peut-être déjà. Continuons..." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Erreur lors de la création du dépôt: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Détails: $($_.Exception.Response)" -ForegroundColor Red
        exit 1
    }
}

# Configurer le remote Git
Write-Host ""
Write-Host "Configuration du remote Git..." -ForegroundColor Yellow

$remoteUrl = "https://$GitHubToken@github.com/$GitHubUsername/$RepoName.git"

# Supprimer le remote existant s'il existe
git remote remove origin 2>$null

# Ajouter le nouveau remote
git remote add origin $remoteUrl

# Renommer la branche en main
Write-Host "Renommage de la branche en main..." -ForegroundColor Yellow
git branch -M main 2>$null

# Pousser le projet
Write-Host ""
Write-Host "Poussée du projet sur GitHub (cela peut prendre plusieurs minutes)..." -ForegroundColor Yellow
Write-Host ""

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "✅ PROJET PUBLIÉ SUR GITHUB !" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL du dépôt: https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 Félicitations ! Votre cluster HPC est maintenant sur GitHub." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors du push." -ForegroundColor Red
    Write-Host "   Vérifiez que le token est valide et a les bonnes permissions." -ForegroundColor Yellow
}
