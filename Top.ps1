#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

Write-Host '==== Nodes ====' -ForegroundColor DarkCyan
kubectl top nodes
if(!$?){throw "kubectl top nodes"}

Write-Host '==== Pods ====' -ForegroundColor DarkCyan
kubectl top pods --all-namespaces
if(!$?){throw "kubectl pods nodes"}