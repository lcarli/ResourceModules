<#
.SYNOPSIS
Creates the CSS stylesheet section of the HTML content.

.DESCRIPTION
Generates the CSS Style tag <style> used in our HTML exports.

.EXAMPLE
Create-CSS
#>

function Create-HTMLCSS {
    $cssContent = @'
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f4f4f4;
    }
    header {
        background-color: #4CAF50;
        color: white;
        text-align: center;
        padding: 1em 0;
    }
    main {
        padding: 2em;
        background-color: white;
        border-radius: 5px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        margin: 2em auto;
        max-width: 800px;
    }
    .dropdown-container {
        margin-bottom: 2em;
    }
    .box {
        border: 1px solid #ccc;
        padding: 1em;
        margin-bottom: 2em;
        border-radius: 5px;
    }
    .box h2 {
        border-bottom: 1px solid #ccc;
        padding-bottom: 0.5em;
        margin-bottom: 1em;
    }
    textarea {
        width: 100%;
        height: 5em;
        padding: 0.5em;
        border-radius: 5px;
        border: 1px solid #ccc;
        resize: vertical;
        font-family: Arial, sans-serif;
        font-size: 0.9em;
    }
    label {
        display: block;
        margin-bottom: 0.3em;
        font-weight: bold;
    }
    input {
        width: 100%;
        padding: 0.5em;
        border-radius: 5px;
        border: 1px solid #ccc;
        font-family: Arial, sans-serif;
        font-size: 0.9em;
    }
    div > div {
        margin-bottom: 1.5em;
    }
    select {
        padding: 0.5em;
        border-radius: 5px;
        border: 1px solid #ccc;
        font-family: Arial, sans-serif;
        font-size: 0.9em;
    }
    #generateOutput {
        display: inline-block;
        padding: 10px 20px;
        margin-bottom: 10px;
        border: none;
        background-color: #0078d4;
        color: white;
        cursor: pointer;
        font-size: 1em;
        transition: background-color 0.2s;
    }

    #generateOutput:hover {
        background-color: #005a9e;
    }

    #output {
        position: relative;
    }

    .button-row {
        display: flex;
        justify-content: flex-end; /* aligns the buttons to the right */
        gap: 10px; /* adds a space between the buttons */
    }

    .button-row button:not(:last-child) {
        margin-right: 10px; /* adds a margin to the right of all buttons, except the last one */
    }

    textarea[readonly] {
        min-height: 300px;
    }

</style>
'@

    return $cssContent
}

Export-ModuleMember -Function Create-HTMLCSS
