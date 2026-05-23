# Fill eCommerce/ from rasdr/eCommerce (only missing files; keeps committed Azure overrides).
# Run from prosjektoppgave/:  .\scripts\setup-ecommerce.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$ecom = Join-Path $root "eCommerce"
$repo = "https://github.com/rasdr/eCommerce.git"

if (-not (Test-Path $ecom)) {
    Write-Error "Missing $ecom"
}

if (Test-Path (Join-Path $ecom "manage.py")) {
    Write-Host "eCommerce already complete (manage.py found)."
    exit 0
}

$temp = Join-Path ([System.IO.Path]::GetTempPath()) "rasdr-eCommerce-$(Get-Random)"
Write-Host "Cloning $repo -> $temp"
git clone --depth 1 $repo $temp

try {
    Write-Host "Copying upstream files into $ecom (existing files kept)"
    Get-ChildItem -Path $temp -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($temp.Length + 1)
        $dest = Join-Path $ecom $rel
        if (-not (Test-Path $dest)) {
            $dir = Split-Path $dest -Parent
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            Copy-Item $_.FullName $dest
        }
    }
}
finally {
    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
}

if (-not (Test-Path (Join-Path $ecom "manage.py"))) {
    Write-Error "setup failed: manage.py still missing in $ecom"
}

Write-Host "Ready: $ecom (run .\scripts\build-acr.ps1 after terraform apply)"
