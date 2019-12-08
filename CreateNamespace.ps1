#!/usr/local/bin/pwsh
param(
  $namespace=$(throw "-namespace required")
)

$ErrorActionPreference="Stop"

$all=kubectl get -o name namespaces
if(!$?){throw "Unable to get current namespaces"}

if(!($all -Match "namespace/$namespace")){
  kubectl create namespace "$namespace"
  if(!$?){throw "create namespace failed - $namespace"}
}else{
  Write-Host "namespace already exists - $namespace"
}