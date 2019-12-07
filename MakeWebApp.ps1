#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$appName=$(throw "-appName required")
)

& $PSScriptRoot/TextTemplate.ps1 -tmpl web-app `
    -namespace $namespace `
    -appName $appName `
    -out "$PSScriptRoot/../app-$namespace-$appName.yml"