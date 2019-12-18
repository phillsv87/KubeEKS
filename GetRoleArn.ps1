#!/usr/local/bin/pwsh

$ErrorActionPreference="Stop"

$config=&"$PSScriptRoot/Config.ps1"

$roleName=$config.IamDefaultRoleName

$list=aws iam list-roles
if(!$?){throw "List roles failed"}
$list=$list | ConvertFrom-Json
if(!$?){throw "Parse json role list failed"}
$role=$list.Roles | Where-Object {$_.RoleName -eq $roleName}

return $role.Arn