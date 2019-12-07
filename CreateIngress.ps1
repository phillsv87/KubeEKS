#!/usr/local/bin/pwsh
kubectl apply -f "$PSScriptRoot/yml/ingress-mandatory.yaml"
if(!$?){throw "apply ingress-mandatory.yaml failed"}

kubectl apply -f "$PSScriptRoot/yml/ingress-nlb-service.yaml"
if(!$?){throw "apply ingress-nlb-service.yaml failed"}