#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Script complet pour configurer Supabase Storage Upload Photos

.DESCRIPTION
  Ce script automatise:
  1. Création du bucket 'documents'
  2. Configuration des permissions (RLS policies)
  3. Configuration des origines CORS

.PARAMETER SupabaseUrl
  URL Supabase: https://xxxxx.supabase.co

.PARAMETER ServiceRoleKey
  Service Role key depuis Supabase Dashboard

.PARAMETER BucketName
  Nom du bucket (défaut: 'documents')

.EXAMPLE
  .\setup_supabase_storage.ps1 `
    -SupabaseUrl "https://xxxxx.supabase.co" `
    -ServiceRoleKey "eyJhbGc..."

.NOTES
  Trouvez vos clés API sur: https://app.supabase.com/project/[id]/settings/api
#>

param(
  [Parameter(Mandatory=$false)]
  [string]$SupabaseUrl = "https://xxxxxxxxxxx.supabase.co",
  
  [Parameter(Mandatory=$false)]
  [string]$ServiceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  
  [Parameter(Mandatory=$false)]
  [string]$BucketName = "documents"
)

# ============================================================================
# Configuration des origines CORS
# ============================================================================

$CorsOrigins = @(
  "http://localhost:*"
  "http://localhost:3000"
  "http://localhost:8000"
  "https://foncira.app"
  "https://*.lovable.app"
  "https://*.vercel.app"
  "https://*.supabase.co"
)

# ============================================================================
# Logs et couleurs
# ============================================================================

function Write-Header {
  param([string]$Message)
  Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
  Write-Host "║  $($Message.PadRight(54))║" -ForegroundColor Cyan
  Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-Success {
  param([string]$Message)
  Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
  param([string]$Message)
  Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Warning {
  param([string]$Message)
  Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
  param([string]$Message)
  Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Write-Step {
  param([string]$Message)
  Write-Host "📌 $Message" -ForegroundColor Cyan
}

# ============================================================================
# Vérifier la configuration
# ============================================================================

function Test-Configuration {
  Write-Host "`n🔍 Vérification de la configuration...`n"
  
  if ($SupabaseUrl.Contains("xxxxxxxxxxx")) {
    Write-Error "SUPABASE_URL non configurée!"
    Write-Info "Mettez à jour le paramètre -SupabaseUrl"
    return $false
  }
  
  if ($ServiceRoleKey.Contains("eyJ")) {
    Write-Error "SUPABASE_SERVICE_ROLE_KEY non configurée!"
    Write-Info "Mettez à jour le paramètre -ServiceRoleKey"
    return $false
  }
  
  Write-Success "Configuration valide!"
  Write-Info "Supabase URL: $SupabaseUrl"
  Write-Info "Service Role Key: $($ServiceRoleKey.Substring(0, 20))..."
  
  return $true
}

# ============================================================================
# Étape 1: Créer le bucket
# ============================================================================

function New-StorageBucket {
  Write-Header "⚙️  Création du bucket '$BucketName' ⚙️ "
  
  try {
    Write-Step "Création du bucket..."
    
    $headers = @{
      "apikey" = $ServiceRoleKey
      "Authorization" = "Bearer $ServiceRoleKey"
      "Content-Type" = "application/json"
    }
    
    $body = @{
      name = $BucketName
      public = $true
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest `
      -Uri "$SupabaseUrl/storage/v1/bucket" `
      -Method POST `
      -Headers $headers `
      -Body $body `
      -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 200) {
      Write-Success "Bucket '$BucketName' créé avec succès!"
      return $true
    }
  }
  catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
      Write-Warning "Le bucket '$BucketName' existe déjà (c'est normal)"
      return $true
    }
    Write-Error "Erreur: $($_.Exception.Message)"
    return $false
  }
}

# ============================================================================
# Étape 2: Récupérer et afficher les informations du bucket
# ============================================================================

function Get-BucketInfo {
  try {
    Write-Step "Récupération des informations du bucket..."
    
    $headers = @{
      "apikey" = $ServiceRoleKey
      "Authorization" = "Bearer $ServiceRoleKey"
    }
    
    $response = Invoke-WebRequest `
      -Uri "$SupabaseUrl/storage/v1/bucket/$BucketName" `
      -Method GET `
      -Headers $headers `
      -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
      $data = $response.Content | ConvertFrom-Json
      Write-Success "Bucket trouvé!"
      Write-Info "  Nom: $($data.name)"
      Write-Info "  Public: $($data.public)"
      Write-Info "  ID: $($data.id)"
      Write-Info "  Créé: $($data.created_at)"
      return $true
    }
  }
  catch {
    Write-Error "Erreur: $($_.Exception.Message)"
    return $false
  }
}

# ============================================================================
# Étape 3: Afficher les instructions pour les policies
# ============================================================================

function Show-PoliciesInstructions {
  Write-Header "🔐 Policies RLS (À faire manuellement) 🔐"
  
  Write-Host "`n📍 Les policies RLS doivent être configurées via SQL.`n" -ForegroundColor Yellow
  
  Write-Host "1️⃣  Allez à: $SupabaseUrl/project/sql" -ForegroundColor Cyan
  Write-Host "2️⃣  Cliquez sur 'New Query'" -ForegroundColor Cyan
  Write-Host "3️⃣  Collez le contenu de 'setup_storage_policies.sql'" -ForegroundColor Cyan
  Write-Host "4️⃣  Cliquez 'RUN'" -ForegroundColor Cyan
  Write-Host "`n✅ Ou vous pouvez exécuter le fichier SQL directement.`n" -ForegroundColor Green
}

# ============================================================================
# Étape 4: Configurer les origines CORS
# ============================================================================

function Set-CorsOrigins {
  Write-Header "🌐 Configuration des origines CORS 🌐"
  
  Write-Host "`nOrigines à configurer:`n" -ForegroundColor Cyan
  
  $CorsOrigins | ForEach-Object {
    Write-Host "  • $_" -ForegroundColor Yellow
  }
  
  Write-Host "`n📍 Les origines CORS doivent être configurées via le Dashboard.`n" -ForegroundColor Yellow
  
  Write-Host "1️⃣  Allez à: $SupabaseUrl/project/settings/api" -ForegroundColor Cyan
  Write-Host "2️⃣  Allez à 'CORS allow-listed origins'" -ForegroundColor Cyan
  Write-Host "3️⃣  Pour chaque origine ci-dessus:" -ForegroundColor Cyan
  Write-Host "     • Cliquez sur 'Add origin'" -ForegroundColor Cyan
  Write-Host "     • Entrez l'origine" -ForegroundColor Cyan
  Write-Host "4️⃣  Cliquez 'Update'" -ForegroundColor Cyan
  
  Write-Host "`n✅ Ou exécutez: node setup_cors.js`n" -ForegroundColor Green
}

# ============================================================================
# Résumé final
# ============================================================================

function Show-Summary {
  param([bool]$Success)
  
  if ($Success) {
    Write-Header "✅ CONFIGURATION RÉUSSIE! ✅"
  }
  else {
    Write-Header "⚠️  CONFIGURATION INCOMPLÈTE ⚠️"
  }
  
  Write-Host "`n📋 RÉSUMÉ:`n" -ForegroundColor Cyan
  Write-Host "  ✅ Bucket: $BucketName" -ForegroundColor Green
  Write-Host "  📝 Policies: À faire manuellement (voir setup_storage_policies.sql)" -ForegroundColor Yellow
  Write-Host "  🌐 CORS: À faire manuellement (voir Supabase Dashboard)" -ForegroundColor Yellow
  
  Write-Host "`n🚀 PROCHAINES ÉTAPES:`n" -ForegroundColor Cyan
  Write-Host "  1. Exécutez le script SQL des policies" -ForegroundColor White
  Write-Host "  2. Configurez les origines CORS" -ForegroundColor White
  Write-Host "  3. Compilez l'app: flutter run" -ForegroundColor White
  Write-Host "  4. Testez l'upload de photos" -ForegroundColor White
  
  Write-Host "`n📁 Fichiers créés:`n" -ForegroundColor Cyan
  Write-Host "  • setup_supabase_storage.dart" -ForegroundColor White
  Write-Host "  • setup_storage_policies.sql" -ForegroundColor White
  Write-Host "  • setup_cors.js" -ForegroundColor White
  Write-Host "  • setup_supabase_storage.ps1 (ce fichier)" -ForegroundColor White
  
  Write-Host "`n📖 Documentation:`n" -ForegroundColor Cyan
  Write-Host "  • SUPABASE_STORAGE_CONFIG.md" -ForegroundColor White
  
  Write-Host "`n" -ForegroundColor White
}

# ============================================================================
# MAIN - Point d'entrée
# ============================================================================

function Main {
  Write-Header "🚀 Configuration Supabase Storage 🚀"
  
  # Vérifier la configuration
  if (-not (Test-Configuration)) {
    exit 1
  }
  
  # Créer le bucket
  $bucketCreated = New-StorageBucket
  if (-not $bucketCreated) {
    Write-Error "Impossible de créer le bucket"
    exit 1
  }
  
  # Vérifier le bucket
  $bucketVerified = Get-BucketInfo
  if (-not $bucketVerified) {
    Write-Error "Impossible de vérifier le bucket"
    exit 1
  }
  
  # Afficher les instructions pour les policies
  Show-PoliciesInstructions
  
  # Afficher les instructions pour CORS
  Set-CorsOrigins
  
  # Résumé final
  Show-Summary $true
  
  Write-Host "`n💡 Pour automatiser les étapes suivantes:`n" -ForegroundColor Cyan
  Write-Host "  • Exécutez: dart setup_supabase_storage.dart" -ForegroundColor White
  Write-Host "  • Ou: node setup_cors.js" -ForegroundColor White
  Write-Host "  • Ou utilisez le SQL Editor de Supabase" -ForegroundColor White
  Write-Host "`n" -ForegroundColor White
}

# Exécuter main
Main
