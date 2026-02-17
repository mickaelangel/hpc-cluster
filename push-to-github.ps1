# ============================================================================
# Script pour pousser le projet Cluster HPC sur GitHub
# ============================================================================

param(
    [string]$RepoName = "hpc-cluster",
    [string]$GitHubUsername = "",
    [string]$GitHubToken = ""
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "PUBLICATION SUR GITHUB" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si le dépôt Git est initialisé
if (-not (Test-Path ".git")) {
    Write-Host "❌ Dépôt Git non initialisé. Exécutez d'abord: git init" -ForegroundColor Red
    exit 1
}

# Vérifier si un remote existe déjà
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Remote existant trouvé: $existingRemote" -ForegroundColor Yellow
    $continue = Read-Host "Voulez-vous le remplacer? (o/N)"
    if ($continue -ne "o" -and $continue -ne "O") {
        Write-Host "Annulé." -ForegroundColor Yellow
        exit 0
    }
    git remote remove origin
}

# Demander les informations si non fournies
if ([string]::IsNullOrEmpty($GitHubUsername)) {
    $GitHubUsername = Read-Host "Votre nom d'utilisateur GitHub"
}

if ([string]::IsNullOrEmpty($GitHubToken)) {
    Write-Host ""
    Write-Host "GitHub nécessite un Personal Access Token (PAT) pour l'authentification." -ForegroundColor Yellow
    Write-Host "Créez-en un ici: https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host "Permissions nécessaires: repo (toutes les permissions repo)" -ForegroundColor Yellow
    Write-Host ""
    $GitHubToken = Read-Host "Votre Personal Access Token" -AsSecureString
    $GitHubToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($GitHubToken)
    )
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
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "✅ Dépôt créé: $($response.html_url)" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "⚠️  Le dépôt existe peut-être déjà. Continuons..." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Erreur lors de la création du dépôt: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Création manuelle du dépôt:" -ForegroundColor Yellow
        Write-Host "1. Aller sur https://github.com/new" -ForegroundColor White
        Write-Host "2. Nom: $RepoName" -ForegroundColor White
        Write-Host "3. Ne PAS initialiser avec README/.gitignore/licence" -ForegroundColor White
        Write-Host "4. Cliquer sur 'Create repository'" -ForegroundColor White
        Write-Host ""
        $continue = Read-Host "Appuyez sur Entrée après avoir créé le dépôt..."
    }
}

# Ajouter le remote
Write-Host ""
Write-Host "Configuration du remote..." -ForegroundColor Yellow
$remoteUrl = "https://$GitHubUsername`:$GitHubToken@github.com/$GitHubUsername/$RepoName.git"
git remote add origin $remoteUrl 2>$null
if ($LASTEXITCODE -ne 0) {
    git remote set-url origin $remoteUrl
}

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
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors du push. Vérifiez:" -ForegroundColor Red
    Write-Host "   - Le token GitHub est valide" -ForegroundColor Yellow
    Write-Host "   - Le dépôt existe sur GitHub" -ForegroundColor Yellow
    Write-Host "   - Vous avez les permissions nécessaires" -ForegroundColor Yellow
    Write-Host ""
}
