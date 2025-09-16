﻿# One-step Quartz deploy (Windows) - mirrors Obsidian Public -> content, ensures homepage, pushes main
$ErrorActionPreference = 'Stop'
Set-Location "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

# EDIT if your Public path changes:
$PublicDir = "C:\Users\digit\Current Projects\BURR_Obsidian\BURR_Obsidian\Public"
$ContentDir = "content"

# Replace any leftover symlink with real folder (Windows rarely creates repo symlinks, but be safe)
if (Test-Path $ContentDir) {
  if ((Get-Item $ContentDir).Attributes.ToString().Contains("ReparsePoint")) {
    Remove-Item -Force $ContentDir
    New-Item -ItemType Directory -Path $ContentDir | Out-Null
  }
} else {
  New-Item -ItemType Directory -Path $ContentDir | Out-Null
}

# Mirror Public -> content (delete removed files)
robocopy "$PublicDir" "$ContentDir" /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed" }

# Ensure homepage
if (-not (Test-Path (Join-Path $ContentDir 'index.md'))) {
@'
---
title: Home
---
# Welcome

This is your Quartz site. Put notes in **Public/** to publish them.
'@ | Set-Content -NoNewline -Encoding UTF8 (Join-Path $ContentDir 'index.md')
}

git add -A | Out-Null
git commit -m "Update notes: $(Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss') UTC" 2>$null | Out-Null
git push origin main
Write-Host "Deployed. Check GitHub -> Actions for the Pages run."
