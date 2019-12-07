#!/usr/local/bin/pwsh
param(
    [string]$name=$(throw "-name required")
)
$config=&"$PSScriptRoot/Config.ps1"
&"$PSScriptRoot/EcrSignIn.ps1"
aws ecr create-repository --repository-name $name
if(!$?){throw "Create repo failed"}