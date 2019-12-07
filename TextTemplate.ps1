#!/usr/local/bin/pwsh
param(
    [string]$tmpl=(throw "-tmpl required "),
    [switch]$tmp,
    [switch]$kubeApply,
    [switch]$kubeDelete,
    [switch]$outParent,
    [string]$out
)

$ErrorActionPreference="Stop"

$config=&"$PSScriptRoot/Config.ps1"

$templatePath=$tmpl

if(!(Test-Path $templatePath)){
    $templatePath="$PSScriptRoot/templates/$($tmpl).yml"
}

if(!(Test-Path $templatePath)){
    throw "No template found at $tmpl or $templatePath"
}

$vars=@{}
$args | ForEach-Object {
    if($_ -match '^-') {
        #New parameter
        $lastvar = $_ -replace '^-'
        $vars[$lastvar] = $null
    } else {
        #Value
        $vars[$lastvar] = $_
    }
}

if($kubeApply -or $kubeDelete -or $outParent -or $out){
    $tmp=$true
}

$templateContent=Get-Content $templatePath -Raw
if($tmp){
    $filePath=$null
    if($out){
        $tmpDir=$null
        $filePath=$out
    }elseif($outParent){
        $tmpDir="$PSScriptRoot/.."
    }else{
        $tmpDir="$PSScriptRoot/tmp"
    }
    if($tmpDir -and !(Test-Path $tmpDir)){
        mkdir $tmpDir | Out-Null
    }
    if(!$filePath){
        $filePath="$tmpDir/$($tmpl).yml"
    }
    $ExecutionContext.InvokeCommand.ExpandString($templateContent) | Out-File -FilePath $filePath

    if($kubeApply){
        kubectl apply -f $filePath
        if(!$?){
            "kubectl apply -f $filePath FAILED"
        }
    }elseif($kubeDelete){
        kubectl delete -f $filePath
        if(!$?){
            "kubectl delete -f $filePath FAILED"
        }
    }else{
        return $filePath
    }
}else{
    $ExecutionContext.InvokeCommand.ExpandString($templateContent)
}