#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

$policyName="kubeeks-csi-permissions"

&"$PSScriptRoot/AddPolicyToProfile.ps1" `
    -policyName "$policyName" `
    -policyFile "$PSScriptRoot/aws/keel-iam-policy.json"

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
if(!$?){throw "apply aws-ebs-csi-driver failed"}

kubectl get pods -n kube-system