# VARIABLES
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$modulesPath = Resolve-Path (Join-Path $scriptDirectory '..\modules')
$htmlFilePath = Join-Path $scriptDirectory 'index.html'

# IMPORTANT
$ModulesList = @()

# FUNCTIONS
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


function Get-ModuleData {
    param (
        [string]$modulePath
    )

    # Procurar pelo arquivo main.bicep dentro do diretório fornecido
    $mainBicepPath = Join-Path -Path $modulePath -ChildPath 'main.bicep'
    if (-not (Test-Path $mainBicepPath -PathType Leaf)) {
        Write-Error "Arquivo main.bicep não encontrado no diretório $modulePath"
        return $null
    }

    # Ler o arquivo main.bicep
    $bicepContent = Get-Content -Path $mainBicepPath -Raw

    # Extrair o nome do módulo usando regex focando em "metadata name"
    if ($bicepContent -match 'metadata\s+name\s*=\s*''(.*?)''') {
        $moduleName = $matches[1]
    } else {
        Write-Error "Nome do módulo não encontrado no arquivo main.bicep de $modulePath"
        return $null
    }

    return $moduleName
}

function Create-HTML {
    param (
        [array]$modulesList
    )

    $options = ''
    $sortedModulesList = $modulesList | Sort-Object Name

    foreach ($module in $sortedModulesList) {
        $moduleName = $module.Name
        $options += "`n<option value='$moduleName'>$moduleName</option>"
    }

    $jsonString = $modulesList | ConvertTo-Json

    $htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CARML Bicep</title>
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
    </style>
</head>
<body>
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
        <div class="box" id="output">
            <h2>Output</h2>
            <textarea readonly></textarea>
        </div>
    </main>
    <script>
        const modulesData = $jsonString;

        document.addEventListener('DOMContentLoaded', function() {
            const moduleSelect = document.getElementById('module');
            const outputTextarea = document.querySelector('#output textarea');
            const requiredFieldsDiv = document.getElementById('required-fields');
            const optionalFieldsDiv = document.getElementById('optional-fields');
            const generateBtn = document.getElementById('generateOutput');

            moduleSelect.addEventListener('change', function() {
                const selectedModule = modulesData.find(module => module.Name === this.value);
                if (selectedModule) {

                    // Interpretar o JSON do módulo
                    let parsedModule = JSON.parse(selectedModule.RawJSON);
                    let parameters = parsedModule.parameters;

                    // Limpar campos de input antigos
                    requiredFieldsDiv.innerHTML = "<h2>Required Fields</h2>";
                    optionalFieldsDiv.innerHTML = "<h2>Optional Fields</h2>";

                    // Criar campos de input/select para cada parâmetro
                    for (let paramName in parameters) {
                        let param = parameters[paramName];

                        // Determinar se é um campo obrigatório ou opcional
                        let isRequired = false;
                        if (param.metadata && param.metadata.description) {
                            const description = param.metadata.description.toLowerCase();
                            isRequired = description.startsWith("required");
                        }

                        let inputElement;
                        if (param.allowedValues) {
                            // Se AllowedValues está definido, criamos um dropdown
                            inputElement = document.createElement("select");
                            param.allowedValues.forEach(value => {
                                let optionElement = document.createElement("option");
                                optionElement.setAttribute("value", value);
                                optionElement.textContent = value;
                                if (param.defaultValue && value === param.defaultValue) {
                                    optionElement.selected = true;
                                }
                                inputElement.appendChild(optionElement);
                            });
                        } else {
                            inputElement = document.createElement("input");
                            inputElement.setAttribute("type", param.type === "bool" ? "checkbox" : "text");
                            if (param.defaultValue) {
                                inputElement.setAttribute("placeholder", JSON.stringify(param.defaultValue));
                            }
                        }

                        inputElement.setAttribute("id", paramName);
                        inputElement.setAttribute("placeholder", paramName);

                        let labelElement = document.createElement("label");
                        labelElement.setAttribute("for", paramName);
                        labelElement.textContent = paramName;

                        let divElement = document.createElement("div");
                        divElement.appendChild(labelElement);
                        divElement.appendChild(inputElement);

                        // Adicionar tooltip (hover) com a descrição
                        if (param.metadata && param.metadata.description) {
                            divElement.setAttribute("title", param.metadata.description);
                        }

                        if (isRequired) {
                            requiredFieldsDiv.appendChild(divElement);
                        } else {
                            optionalFieldsDiv.appendChild(divElement);
                        }
                    }
                }
            });

            generateBtn.addEventListener('click', function() {
                const selectedModule = modulesData.find(module => module.Name === moduleSelect.value);
                let parsedModule = JSON.parse(selectedModule.RawJSON);
                let parameters = parsedModule.parameters;

                // Verificar campos obrigatórios preenchidos
                let allRequiredFilled = true;
                const requiredInputs = requiredFieldsDiv.querySelectorAll('input, select');
                for (let input of requiredInputs) {
                    if (!input.value) {
                        allRequiredFilled = false;
                        break;
                    }
                }

                if (!allRequiredFilled) {
                    alert("Please fill all the required fields before generating the output.");
                    return;
                }

                for (let paramName in parameters) {
                    let paramValue = document.getElementById(paramName).value;
                    if (paramValue) {
                        parameters[paramName].value = paramValue;
                    } else if (parameters[paramName].defaultValue) {
                        parameters[paramName].value = parameters[paramName].defaultValue;
                    }
                }
                outputTextarea.textContent = JSON.stringify(parsedModule, null, 2);
            });
        });
    </script>
</body>
</html>
"@
    return $htmlContent
}

# MAIN
$moduleDirectories = Get-ModuleDirectories -path $modulesPath

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

$htmlContent = Create-HTML -modulesList $ModulesList
$htmlContent | Set-Content -Path $htmlFilePath
