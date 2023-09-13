<#
.SYNOPSIS
Generates a complete HTML content.

.DESCRIPTION
Combines head, body, and JS to create a complete HTML export.

.EXAMPLE
Export-HTML -modulesList "Your HTML Content"
#>
function Export-HTML {
    param (
        [Parameter(Mandatory = $true)]
        [array]$modulesList
    )

    $options = ''
    $sortedModulesList = $modulesList | Sort-Object Name

    foreach ($module in $sortedModulesList) {
        $moduleName = $module.Name
        $options += "`n<option value='$moduleName'>$moduleName</option>"
    }

    $jsonString = $modulesList | ConvertTo-Json

    $head = Create-HTMLHead
    $css = Create-HTMLCSS
    $main = Create-HTMLBody -options $options
    $js = Create-HTMLJS -jsonString $jsonString

    return @"
<!DOCTYPE html>
<html>
<head>
$head
$css
</head>
<body>
$main
$js
</body>
</html>
"@
}
