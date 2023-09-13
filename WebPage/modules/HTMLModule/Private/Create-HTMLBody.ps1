<#
.SYNOPSIS
Creates the body section of the HTML content.

.DESCRIPTION
Generates the body content used in our HTML exports.

.EXAMPLE
Create-HTMLBody -Content "Your HTML Content"
#>
function Create-HTMLBody {
    param (
        [Parameter(Mandatory = $true)]
        [string]$options
    )

    return @"
    <header>
        <h1>CARML Bicep UI</h1>
    </header>
    <main>
        <div class="dropdown-container">
            <label for="module">Choose a module:</label>
            <select id="module">
                $options
            </select>
        </div>
        <div class="box" id="required-fields">
            <h2>Required Fields</h2>
        </div>
        <div class="box" id="optional-fields">
            <h2>Optional Fields</h2>
        </div>
        <button id="generateOutput">Generate Output</button>
        <br>
        <div class="box" id="output">
            <div class="button-row">
                <button id="copy-output" title="Copy to Clipboard"><i class="fas fa-copy"></i></button>
                <button id="save-output" title="Save File"><i class="fas fa-download"></i></button>
            </div>
            <h2>Output</h2>
            <textarea readonly></textarea>
        </div>
    </main>
"@
}
