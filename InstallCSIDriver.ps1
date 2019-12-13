#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

$config=&"$PSScriptRoot/Config.ps1"

$policyName="kubeeks-csi-permissions"
$roleName=$config.IamDefaultRoleName

if(!$roleName){
    throw "config.IamDefaultRoleName not set"
}

Push-Location $PSScriptRoot
try{

    $list=aws iam list-policies --scope Local
    if(!$?){throw "List policies failed"}
    $list=$list | ConvertFrom-Json
    if(!$?){throw "Parse json policy list failed"}
    $policy=$list.Policies | Where-Object {$_.PolicyName -eq $policyName}

    if(!$policy){
        $policy=aws iam create-policy --policy-name $policyName --policy-document "file://aws/csi-iam-policy.json"
        $status=$?
        Write-Host $policy
        if(!$status){throw "aws iam create-policy failed"}
        $policy=$policy | ConvertFrom-Json
        if(!$?){throw "Parse policy JSON failed"}
    }else{
        Write-Host ($policy | ConvertTo-Json)
        Write-Host "Policy already exists with name $policyName"
    }

    
    $list=aws iam list-attached-role-policies --role-name $roleName | ConvertFrom-Json
    if(!$?){throw "Get role policies failed"}
    $attachment=$list.AttachedPolicies | Where-Object {$_.PolicyName -eq $policyName}

    if($attachment){
        Write-Host ($attachment | ConvertTo-Json)
        Write-Host "policy already attached to role"
    }else{
        $r=aws iam attach-role-policy --role-name $roleName --policy-arn $policy.Arn
        $status=$?
        Write-Host $r
        if(!$status){throw "aws aim attach-role-policy failed"}
        Write-Host "CSI policy attached" -ForegroundColor DarkGreen
    }


    kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
    if(!$?){throw "apply aws-ebs-csi-driver failed"}

    kubectl get pods -n kube-system

}finally{
    Pop-Location
}