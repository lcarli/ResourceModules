function Get-ModuleDirectories {
    param (
        [Parameter(Mandatory = $true)]
        [string]$path
    )

    $moduleDirs = @()
    $childDirs = Get-ChildItem -Path $path -Directory

    foreach ($dir in $childDirs) {
        # Se o diretório contém um arquivo main.bicep, adicione-o à lista
        if (Test-Path -Path "$dir\main.bicep") {
            $moduleDirs += $dir.FullName
        } else {
            # Se não, navegue mais fundo nos subdiretórios
            $moduleDirs += Get-ModuleDirectories -path $dir.FullName
        }
    }

    return $moduleDirs
}

Export-ModuleMember -Function Get-ModuleDirectories
