#!/usr/local/bin/pwsh
param(
    [switch]$reset,
    [switch]$noReturn
)

if($reset){
    $Env:KubeEksInit="0"
}

$configPath=$null
$configDir=$null

if(Test-Path "$PSScriptRoot/../KubeEKS.json"){
    $configPath="$PSScriptRoot/../KubeEKS.json"
    $configDir="$PSScriptRoot/../"
}elseif(Test-Path "$PSScriptRoot/KubeEKS.json"){
    $configPath="$PSScriptRoot/KubeEKS.json";
    $configDir="$PSScriptRoot/"
}else{
    throw "No KubeEKS config file found. Looked for $PSScriptRoot/KubeEKS.json and $PSScriptRoot/../KubeEKS.json"
}

$config=Get-Content $configPath | ConvertFrom-json

if("$Env:KubeEksInit" -ne "1"){
    $Env:KubeEksInit="1"
    $Env:AWS_PROFILE=$config.AwsProfile
}

$config | Add-Member -name "__PATH" -value $configPath -MemberType NoteProperty
$config | Add-Member -name "__DIR" -value $configDir -MemberType NoteProperty

if(!$noReturn){
    return $config
}