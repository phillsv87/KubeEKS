#!/usr/local/bin/pwsh
$ErrorActionPreference="Stop"

$tmpDir="$PSScriptRoot/tmp"
if(!(Test-Path $tmpDir)){
    New-Item -ItemType 'Directory' -Path $tmpDir | Out-Null
}

return $tmpDir