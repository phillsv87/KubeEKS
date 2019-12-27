#!/usr/local/bin/pwsh
param(
    $value
)
$ErrorActionPreference="Stop"
try{
    Set-Clipboard -Value $value
}catch{
    &"$PSScriptRoot/set-clipboard.sh" "$value"
}