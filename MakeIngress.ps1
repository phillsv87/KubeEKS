#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required")
)

& $PSScriptRoot/TextTemplate.ps1 -tmpl ingress `
    -namespace $namespace `
    -out "$PSScriptRoot/../ingress-$namespace.yml"