<#
.SYNOPSIS
Creates the head section of the HTML content.

.DESCRIPTION
Generates the standard head used in our HTML exports, including embedded styles for components.

.EXAMPLE
Create-HTMLHead
#>
function Create-HTMLHead {
    return @'
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CARML Bicep</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2@4.0.13/dist/css/select2.min.css"/>
'@
}
