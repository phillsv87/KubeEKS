#!/usr/local/bin/pwsh
$config=&"$PSScriptRoot/Config.ps1"

#signin to cluster
aws eks --region $config.ClusterRegion update-kubeconfig --name $config.ClusterName
if(!$?){
    throw "Cluster Signin Failed failed"
}
Write-Host "Signed into cluster $($config.ClusterName) in region $($config.ClusterRegion)" -Foreground DarkGreen