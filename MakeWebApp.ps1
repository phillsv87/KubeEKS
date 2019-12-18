#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name=$(throw "-name required"),
    [string]$imageName=$(throw "-imageName required"),
    [switch]$keel
)

$tmpl='web-app'
$role='no-role'

if($keel){
    $tmpl='web-app-keel'
    $role=&"$PSScriptRoot/GetRoleArn.ps1"
}

& $PSScriptRoot/TextTemplate.ps1 -tmpl $tmpl `
    -namespace $namespace `
    -name $name `
    -imageName $imageName `
    -role $role `
    -out "$PSScriptRoot/../app-$namespace-$name.yml"