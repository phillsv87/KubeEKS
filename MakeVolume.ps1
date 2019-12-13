#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name=$(throw "-name required"),
    [int]$sizeGb=$(throw "-sizeGb required"),
    [string]$storageClass=$(throw "-storageClass required")
)

& $PSScriptRoot/TextTemplate.ps1 -tmpl volume `
    -namespace $namespace `
    -name $name `
    -storageClass $storageClass `
    -sizeGb $sizeGb `
    -out "$PSScriptRoot/../volume-$namespace-$name.yml"