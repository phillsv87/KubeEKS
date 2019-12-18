#!/usr/local/bin/pwsh
param(
    [string]$policyName=$(throw "-policyName required"),
    [string]$policyFile=$(throw "-policyFile required"),
    [string]$roleName
)

$ErrorActionPreference="Stop"

$config=&"$PSScriptRoot/Config.ps1"

if(!$roleName){
    $roleName=$config.IamDefaultRoleName
    if(!$roleName){
        throw "config.IamDefaultRoleName"
    }
}

Push-Location $PSScriptRoot
try{

    $list=aws iam list-policies --scope Local
    if(!$?){throw "List policies failed"}
    $list=$list | ConvertFrom-Json
    if(!$?){throw "Parse json policy list failed"}
    $policy=$list.Policies | Where-Object {$_.PolicyName -eq $policyName}

    if(!$policy){
        Write-Host "Creating Policy - policyName:$policyName, policyFile:file://$policyFile"
        $policy=aws iam create-policy --policy-name $policyName --policy-document "file://$policyFile"
        $status=$?
        Write-Host $policy
        if(!$status){throw "aws iam create-policy failed"}
        $policy=$policy | ConvertFrom-Json
        if(!$?){throw "Parse policy JSON failed"}
        Write-Host "Policy Created" -ForegroundColor DarkGreen
    }else{
        Write-Host ($policy | ConvertTo-Json)
        Write-Host "Policy already exists with name $policyName"
    }

    Write-Host "Policy - policyName:$policyName, policyArn:$($policy.Arn)"

    
    $list=aws iam list-attached-role-policies --role-name $roleName | ConvertFrom-Json
    if(!$?){throw "Get role policies failed"}
    $attachment=$list.AttachedPolicies | Where-Object {$_.PolicyName -eq $policyName}

    if($attachment){
        Write-Host ($attachment | ConvertTo-Json)
        Write-Host "policy already attached to role"
    }else{
        Write-Host "Attaching policy to role - roleName:$roleName, policyName:$policyName, policyArn:$($policy.Arn)"
        $r=aws iam attach-role-policy --role-name $roleName --policy-arn $policy.Arn
        $status=$?
        Write-Host $r
        if(!$status){throw "aws aim attach-role-policy failed"}
        Write-Host "Policy attached" -ForegroundColor DarkGreen
    }

    Write-Host "Policy Attachment - roleName:$roleName, policyName:$policyName, policyArn:$($policy.Arn)"

    return $policy

}finally{
    Pop-Location
}