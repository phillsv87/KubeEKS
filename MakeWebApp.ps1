#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name=$(throw "-name required"),
    [string]$imageName=$(throw "-imageName required")
)

& $PSScriptRoot/TextTemplate.ps1 -tmpl web-app `
    -namespace $namespace `
    -name $name `
    -imageName $imageName `
    -out "$PSScriptRoot/../app-$namespace-$name.yml"