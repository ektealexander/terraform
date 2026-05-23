# Build and push rasdr/eCommerce images to the Terraform-created ACR (cloud build).
# Prerequisites: terraform apply, .\scripts\setup-ecommerce.ps1

param(
    [string]$Acr = $(terraform -chdir="$((Split-Path $PSScriptRoot -Parent))" output -raw acr_login_server 2>$null)
)

$root = Split-Path $PSScriptRoot -Parent
$ecom = Join-Path $root "eCommerce"

if (-not $Acr) {
    Write-Error "Set -Acr or run terraform apply first (need acr_login_server output)."
}
if (-not (Test-Path (Join-Path $ecom "manage.py"))) {
    Write-Error "Run .\scripts\setup-ecommerce.ps1 first."
}

$registry = ($Acr -replace '\.azurecr\.io$', '')

Push-Location $ecom
try {
    az acr build --registry $registry --image ecommerce-mysql:latest --file db/mysql/Dockerfile .
    az acr build --registry $registry --image ecommerce:latest --file Dockerfile .
    Write-Host "Pushed ${Acr}/ecommerce-mysql:latest and ${Acr}/ecommerce:latest"
}
finally {
    Pop-Location
}
