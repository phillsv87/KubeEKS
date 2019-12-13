#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name=$(throw "-name required"),
    [int]$sizeGb=$(throw "-sizeGb required"),
    [string]$zone,
    [string]$type="standard",
    [switch]$noApply
)

$ErrorActionPreference="Stop"

if(!$zone){
    Write-Host "=== Zones ==="
    aws ec2 describe-availability-zones
    throw "-zone required"
}

$r=aws ec2 create-volume --availability-zone=$zone --size=$sizeGb --volume-type=$type
if(!$?){throw "Create EBS failed"}

Write-Host $r

$r=$r | ConvertFrom-Json
if(!$?){throw "Parse result json failed"}

$volumeId=$r.VolumeId
if(!$volumeId){throw "Unable to determine volume ID"}

Write-Host "VolumeId = $volumeId"

$tmplFile=&"$PSScriptRoot/MakeVolume.ps1" `
    -namespace $namespace `
    -name $name `
    -sizeGb $sizeGb `
    -type $type `
    -volumeId $volumeId

if($noApply){
    Write-Host "To complete to creation of the volume run the command below."
    Write-Host "kubectl apply -f $tmplFile"
}else{
    kubectl apply -f $tmplFile
    if(!$?){throw "Apply yaml failed. EBS volume has be created. Inspect $tmplFile"}
}