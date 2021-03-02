#!/usr/local/bin/pwsh
$config=&"$PSScriptRoot/Config.ps1"

aws ecr get-login-password `
    --region $config.ClusterRegion `
| docker login `
    --username AWS `
    --password-stdin $config.ContainerRegistry

if(!$?){
    throw "aws ecr get-login failed"
}


Write-Host "Signed into ECR" -Foreground DarkGreen