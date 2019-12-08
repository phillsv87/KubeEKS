#!/usr/local/bin/pwsh
param(
    [switch]$staging
)

$ErrorActionPreference="Stop"

&"$PSScriptRoot/CreateNamespace.ps1" -namespace letsencrypt

if($staging){
    $server='https://acme-staging-v02.api.letsencrypt.org/directory'
    $type='letsencrypt-staging'
}else{
    $server='https://acme-v02.api.letsencrypt.org/directory'
    $type='letsencrypt-prod'
}

&$PSScriptRoot/TextTemplate.ps1 -kubeApply -tmpl cluster-issuer `
    -server $server `
    -type $type `
    -namespace "letsencrypt"

# Show letsencrypt namespace
kubectl get clusterissuer.cert-manager.io --namespace letsencrypt