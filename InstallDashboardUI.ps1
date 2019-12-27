#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

# Create Dashboard UI resources
kubectl apply -f "$PSScriptRoot/yml/dashboard-ui.yml"
if(!$?){throw "apply dashboard-ui.yml failed"}

# Create admin service account
kubectl apply -f "$PSScriptRoot/yml/admin-user.yml"
if(!$?){throw "apply admin-user.yml failed"}

# Create role
kubectl apply -f "$PSScriptRoot/yml/admin-role-binding.yml"
if(!$?){throw "apply admin-role-binding.yml failed"}

Write-Host "Dashboard UI Install" -ForegroundColor DarkGreen