#!/usr/local/bin/pwsh
param(
    $namespace="",
    $name="",
    $path=$(throw "-path required"),
    [switch]$dryRun
)
$ErrorActionPreference="Stop"

if(!(Test-Path $path)){
    throw "Secrets file not found at -path"
}

$lines=Get-Content -Path $path -Delimiter "`n"

$dir=[System.IO.Path]::GetDirectoryName($path)

Push-Location $dir

try{

    $from=""

    foreach($line in $lines){

        $line=$line.Trim()
        if($line.StartsWith("#") -or [string]::IsNullOrWhiteSpace($line)){
            continue
        }

        
        $parts=$line.Split(":",2)
        if($parts.Length -eq 1){
            [string]$prop=$parts[0].Trim()
            [string]$file=$prop
        }else{
            [string]$prop=$parts[0].Trim()
            [string]$file=$parts[1].Trim()
        }

        if($prop.StartsWith("@/")){

            switch($prop){

                "@/namespace"{
                    if($parts.Length -ne 2){
                        throw "namespace property requires a value"
                    }
                    if($namespace -ne "" -and $namespace -ne $file){
                        throw "Conflicting namespaces defined by secrets file and command. namespace in file = "+$file
                    }
                    $namespace=$file
                }

                "@/name"{
                    if($parts.Length -ne 2){
                        throw "namespace property requires a value"
                    }
                    if($name -ne "" -and $name -ne $file){
                        throw "Conflicting names defined by secrets file and command. name in file = "+$file
                    }
                    $name=$file
                }

            }
        }else{

            if(!(Test-Path $file)){
                throw "$file not found"
            }

            $prop=[System.IO.Path]::GetFileName($prop)
            $from+="--from-file=$prop=`"$file`" "
        }
    }

    if([string]::IsNullOrWhiteSpace($namespace)){
        throw "-namespace not defined by command or secrets file"
    }

    if([string]::IsNullOrWhiteSpace($name)){
        throw "-name not defined by command or secrets file"
    }

    $cmd="kubectl create secret generic $name --namespace $namespace $from --dry-run -o yaml | kubectl apply -f -"

    Write-Host "$cmd"
    if(!$dryRun){
        Invoke-Expression $cmd | Out-Null
        if(!$?){throw "Apply secrets file failed. cmd = $cmd"}

        kubectl describe secret/$name --namespace $namespace
    }

}finally{
    Pop-Location
}
