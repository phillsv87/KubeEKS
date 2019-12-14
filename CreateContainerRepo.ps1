#!/usr/local/bin/pwsh
param(
    [string]$name=$(throw "-name required")
)
&"$PSScriptRoot/EcrSignIn.ps1"
aws ecr create-repository --repository-name $name
if(!$?){throw "Create repo failed"}