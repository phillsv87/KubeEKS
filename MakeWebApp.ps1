#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$appName=$(throw "-appName required"),
    [string]$imageName=$(throw "-imageName required")
)

& $PSScriptRoot/TextTemplate.ps1 -tmpl web-app `
    -namespace $namespace `
    -appName $appName `
    -imageName $imageName `
    -out "$PSScriptRoot/../app-$namespace-$appName.yml"