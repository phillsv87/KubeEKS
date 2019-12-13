#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name=$(throw "-name required"),
    [string]$type="gp2"
)

& $PSScriptRoot/TextTemplate.ps1 -tmpl storage-class `
    -namespace $namespace `
    -name $name `
    -type $type `
    -out "$PSScriptRoot/../storage-class-$namespace-$name.yml"