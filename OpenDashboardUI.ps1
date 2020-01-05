#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

Write-Host 'Getting login token'
&"$PSScriptRoot/GetDashboardLoginToken.ps1"

Start-Job -ScriptBlock {
    Start-Sleep -Seconds 2
    open 'http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'
} | Out-Null

Write-Host 'Starting proxy'
kubectl proxy