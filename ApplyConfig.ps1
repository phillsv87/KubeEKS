#!/usr/local/bin/pwsh
param(
    [string]$path,
    [string]$secretPath,
    [string]$prefix,
    [string]$insertPath,
    [string]$insertSecretPath,
    [string]$filter='PROD__',
    [string]$indent='        ',
    [string]$secretIndent='  ',
    [string]$secretsName='secrets-default',
    [switch]$noOut
)

$ErrorActionPreference="Stop"

$nl="`n"
$out=$nl
$sOut=$nl

function InsertContent {
    param(
        [string]$value=$(throw "-value required"),
        [string]$path=$(throw "-path required"),
        [string]$tag=$(throw "-tag required")
    )
    [string]$startTag="##[Start$tag]"
    [string]$endTag="##[End$tag]"
    [string]$content=Get-Content -Path $path -Raw
    $start=$content.IndexOf($startTag)
    $end=$content.IndexOf($endTag)
    if($start -eq -1){
        throw "Start tag not found in $path. Start Tag = $startTag"
    }
    if($end -eq -1){
        throw "End tag not found in $path. End Tag = $endTag"
    }
    $content= `
        $content.Substring(0,$start+$startTag.Length) + `
        $value + `
        $content.Substring($end)

    $content.Trim() > $path
}

if($path){
    $env=Get-Content -Path "$path" | ConvertFrom-Json
    $env | Get-Member -MemberType NoteProperty | ForEach-Object {
        [string]$name=$_.Name
        $value=$env."$name"

        if($name -eq 'AUTO_PREFIX'){
            return
        }

        if($name.Contains('__')){
            if($name.StartsWith($filter)){
                $name=$name.Substring($filter.Length)
            }else{
                return
            }
        }
        $name=$prefix+$name.ToUpper()
        $value=$value.Replace("\","\\").Replace("`n","\n").Replace("`t","\t")

        $out+="$indent- name: $name$nl"
        $out+="$indent  value: ""$value""$nl"
    }
}

if($secretPath){

    $env=Get-Content -Path "$secretPath" | ConvertFrom-Json
    $env | Get-Member -MemberType NoteProperty | ForEach-Object {
        [string]$name=$_.Name
        $value=$env."$name"

        if($name -eq 'AUTO_PREFIX'){
            return
        }

        if($name.Contains('__')){
            if($name.StartsWith($filter)){
                $name=$name.Substring($filter.Length)
            }else{
                return
            }
        }
        $varName=$prefix+$name.ToUpper()

        $out+="$indent- name: $varName$nl"
        $out+="$indent  valueFrom:$nl"
        $out+="$indent    secretKeyRef:$nl"
        $out+="$indent      name: $secretsName$nl"
        $out+="$indent      key: $name$nl"


        $b = [System.Text.Encoding]::UTF8.GetBytes($value)
        $value =[Convert]::ToBase64String($b)

        $sOut+="$($secretIndent)$($name): $value$nl"
    }
}

if($insertPath){
    InsertContent -path $insertPath -value $out -tag 'EnvVars'
}elseif(!$noOut){
    "==== $path ===="
    $out
    "==== End ===="
}

if($insertSecretPath){
    InsertContent -path $insertSecretPath -value $sOut -tag 'Secrets'
}elseif(!$noOut){
    "==== $secretPath ===="
    $sOut
    "==== End ===="
}