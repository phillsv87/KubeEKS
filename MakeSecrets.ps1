#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name="default"
)

$dir=&"$PSScriptRoot/GetSecretsDirectory.ps1"
$path="$dir/secrets-$namespace-$name.yml"

if(Test-Path $path){
    Write-Host "Secret file already exists"
    return $path
}

& $PSScriptRoot/TextTemplate.ps1 -tmpl secrets `
    -namespace $namespace `
    -name $name `
    -out $path