#!/usr/local/bin/pwsh
param(
    [switch]$returnToken
)
$ErrorActionPreference="Stop"

$s=kubectl -n kubernetes-dashboard get secret
if(!$?){throw "get admin-user secret failed"}
$s=$s | grep admin-user | awk '{print $1}'

$s=kubectl -n kubernetes-dashboard describe secret $s
if(!$?){throw "describe admin-user secret failed"}
$s=$s | grep token: | awk '{print $2}'

if($returnToken){
    return $s
}else{
    &"$PSScriptRoot/SetClipboard.ps1" -value $s
    Write-Host "Dashboard login token copied to clipboard." -ForegroundColor DarkCyan
}