#!/usr/local/bin/pwsh
&"$PSScriptRoot/Config.ps1" -noReturn

$cmd=aws ecr get-login --no-include-email
if(!$?){
    throw "aws ecr get-login failed"
}

Invoke-Expression $cmd
if(!$?){
    throw "ecr login expression failed"
}
Write-Host "Signed into ECR" -Foreground DarkGreen