#!/usr/local/bin/pwsh
$config=&"$PSScriptRoot/Config.ps1"

if(!$config.SecretsDir){
    throw "config.SecretsDir not set"
}

return Join-Path -Path $config.__DIR -ChildPath $config.SecretsDir