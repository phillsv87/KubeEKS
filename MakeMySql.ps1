#!/usr/local/bin/pwsh
param(
    [string]$namespace=$(throw "-namespace required"),
    [string]$name=$(throw "-name required"),
    [string]$dataVolume=$(throw "-dataVolume required"),
    [string]$secret="secrets-default",
    [string]$rootSecretKey="mysqlRootPassword",
    [string]$defaultUser="sqluser",
    [string]$defaultUserSecretKey="mysqlUserPassword",
    [string]$defaultDatabase=$(throw "-defaultDatabase required")
)

& $PSScriptRoot/TextTemplate.ps1 mysql `
    -namespace $namespace `
    -name $name `
    -dataVolume $dataVolume `
    -secret $secret `
    -rootSecretKey $rootSecretKey `
    -defaultUser $defaultUser `
    -defaultUserSecretKey $defaultUserSecretKey `
    -defaultDatabase $defaultDatabase `
    -out "$PSScriptRoot/../mysql-$namespace-$name.yml"