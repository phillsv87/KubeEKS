#!/usr/local/bin/pwsh
param(
    [string]$version='1.8+'
)
$ErrorActionPreference="Stop"

$tmpDir=&"$PSScriptRoot/GetTmpDir.ps1"

Push-Location $tmpDir
try{

    if(Test-Path './metrics-server'){
        Remove-Item -Recurse -Force -Path './metrics-server'
    }

    Write-Host 'Cloning https://github.com/kubernetes-sigs/metrics-server.git'
    git clone https://github.com/kubernetes-sigs/metrics-server.git
    if(!$?){throw "clone https://github.com/kubernetes-sigs/metrics-server.git failed"}

    Push-Location './metrics-server'
    try{

        Write-Host "Depolying $tmpDir/metrics-server/deploy/$version/"
        kubectl create -f "./deploy/$version/"
        if(!$?){throw "Depoly failed failed"}

        Write-Host "MetricServer v$version install" -ForegroundColor DarkGreen

    }finally{
        Pop-Location
        Remove-Item -Recurse -Force -Path './metrics-server'
    }

}finally{
    Pop-Location
}