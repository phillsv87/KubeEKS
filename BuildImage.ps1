#!/usr/local/bin/pwsh
param(
    [string]$version=$(throw "-version required"),
    [string]$dockerFile=$(throw "-dockerFile required"),
    [string]$name=$(throw "-name required"),
    [switch]$noBuild,
    [switch]$noPush,
    [switch]$noSignIn
)

$config=&"$PSScriptRoot/Config.ps1"

if(!$noSignIn){
    &"$PSScriptRoot/EcrSignIn.ps1"
}

$dir=Split-Path -Path $dockerFile -Parent
$filename=Split-Path -Path $dockerFile -Leaf
if(!(Test-Path $dir)){
    throw "Directory of docker file does not exist"
}
if(!(Test-Path $dockerFile)){
    throw "Docker file does not exist"
}
Push-Location $dir
$tag="$($config.ContainerRegistry)/$($name):$version"

try{

    if(!$noBuild){
        Write-Host "Building $tag"
        docker build -t $tag -f $filename .
        if(!$?){throw "build failed"}
        Write-Host "Build $tag success" -Foreground DarkGreen
    }

    if(!$noPush){
        Write-Host "Pushing $tag"
        docker push $tag
        if(!$?){throw "push failed"}
        Write-Host "Push $tag success" -Foreground DarkGreen
    }

}finally{
    Pop-Location
}