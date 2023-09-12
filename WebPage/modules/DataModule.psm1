function Get-ModuleData {
    param (
        [string]$modulePath
    )

    $mainBicepPath = Join-Path -Path $modulePath -ChildPath 'main.bicep'
    if (-not (Test-Path $mainBicepPath -PathType Leaf)) {
        Write-Error "main.bicep not found on $modulePath"
        return $null
    }
    $bicepContent = Get-Content -Path $mainBicepPath -Raw
    if ($bicepContent -match 'metadata\s+name\s*=\s*''(.*?)''') {
        $moduleName = $matches[1]
    } else {
        Write-Error "main.bicep name module not found on $modulePath"
        return $null
    }

    return $moduleName
}

Export-ModuleMember -Function Get-ModuleData
