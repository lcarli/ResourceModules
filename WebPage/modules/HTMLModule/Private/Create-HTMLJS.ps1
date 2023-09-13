<#
.SYNOPSIS
Creates the JavaScript section of the HTML content.

.DESCRIPTION
Generates the JavaScript used in our HTML exports.

.EXAMPLE
Create-HTMLJS
#>
function Create-HTMLJS {
    param (
        [string]$jsonString
    )

    return @"
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.0.13/dist/js/select2.min.js"></script>
    <script>
        `$(document).ready(function() {
            `$('#module').select2({
                placeholder: "Selecione um módulo...",
                allowClear: true
            });
        });
    </script>
    <script>
        const modulesData = $jsonString;

        document.addEventListener('DOMContentLoaded', function() {
            const moduleSelect = document.getElementById('module');
            const outputTextarea = document.querySelector('#output textarea');
            const requiredFieldsDiv = document.getElementById('required-fields');
            const optionalFieldsDiv = document.getElementById('optional-fields');
            const generateBtn = document.getElementById('generateOutput');

            `$('#module').on('select2:select', function (e) {
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

            const copyBtn = document.getElementById('copy-output');
            const saveBtn = document.getElementById('save-output');

            copyBtn.addEventListener('click', function() {
                outputTextarea.select();
                document.execCommand('copy');
                alert('Content copied to clipboard!');
            });

            saveBtn.addEventListener('click', function() {
                const blob = new Blob([outputTextarea.value], { type: 'text/plain' });
                const a = document.createElement('a');
                a.href = URL.createObjectURL(blob);
                a.download = 'parameters.json';
                a.click();
            });
        });
    </script>
"@
}
