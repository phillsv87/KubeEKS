#!/usr/local/bin/pwsh
param(
    [switch]$staging,
    [string]$domain=$(throw "-domain required"),
    [string]$namespace=$(throw "-namespace required")
)


if($staging){
    $type='letsencrypt-staging'
}else{
    $type='letsencrypt-prod'
}

$name=$domain.Replace(".","-")
$path="$PSScriptRoot/../cert-$namespace-$name.yml"

& $PSScriptRoot/TextTemplate.ps1 -tmpl cert -out $path `
    -name "cert-$name" `
    -namespace $namespace `
    -issuerNamespace letsencrypt `
    -domain $domain `
    -type $type