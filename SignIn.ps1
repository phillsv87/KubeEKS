#!/usr/local/bin/pwsh

&"$PSScriptRoot/ClusterSignIn.ps1"

&"$PSScriptRoot/EcrSignIn.ps1"

kubectl get namespaces