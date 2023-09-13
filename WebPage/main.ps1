# Import modules
Import-Module .\modules\HTMLModule\HTMLModule.psm1
Import-Module .\modules\DirectoryModule.psm1
Import-Module .\modules\DataModule.psm1

# Load configurations
$config = Get-Content -Path .\settings\config.json | ConvertFrom-Json
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$modulesPath = Resolve-Path (Join-Path $scriptDirectory $config.modulesPath)
$htmlFilePath = Join-Path $scriptDirectory $config.htmlFilePath

# MAIN
$moduleDirectories = Get-ModuleDirectories -path $modulesPath

$ModulesList = @()
foreach ($dir in $moduleDirectories) {
    $moduleName = Get-ModuleData -modulePath $dir

    if ($moduleName) {
        $moduleData = @{
            Name    = $moduleName
            Path    = $dir
            RawJSON = (Get-Content -Path (Join-Path -Path $dir -ChildPath 'main.json') -Raw)
        }

        $ModulesList += $moduleData
    }
}

$htmlContent = Export-HTML -modulesList $ModulesList
$htmlContent | Set-Content -Path $htmlFilePath
