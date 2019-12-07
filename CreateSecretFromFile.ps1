#!/usr/local/bin/pwsh
param(
    $namespace=$(throw "-namespace required"),
    $name=$(throw "-name required"),
    $path=$(throw "-path required")
)
kubectl create secret generic $name --from-file=$path --namespace $namespace