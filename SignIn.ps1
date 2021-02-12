#!/usr/local/bin/pwsh

&"$PSScriptRoot/ClusterSignIn.ps1"

# Skip Ecr sign-in - I don't directly use ECR anymore
#&"$PSScriptRoot/EcrSignIn.ps1"

kubectl get namespaces