#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

&"$PSScriptRoot/AddPolicyToProfile.ps1" `
    -policyName 'keel-iam' `
    -policyFile "$PSScriptRoot/aws/keel-iam-policy.json"