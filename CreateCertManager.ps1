#!/usr/local/bin/pwsh

$ErrorActionPreference="Stop"

# see for more info - https://cert-manager.io/docs/installation/kubernetes/

# Create the namespace for cert-manager if does not exist
&"$PSScriptRoot/CreateNamespace.ps1" -namespace cert-manager

# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f "$PSScriptRoot/yml/cert-manager.yaml"
if(!$?){throw "cert-manager.yaml apply failed"}
Write-Host "cert-manager created" -Foreground DarkGreen

# Show cert-manager pods
kubectl get pods --namespace cert-manager