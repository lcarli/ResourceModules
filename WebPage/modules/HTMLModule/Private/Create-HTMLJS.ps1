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
                outputTextarea.textContent = '';
                const selectedModule = modulesData.find(module => module.Name === this.value);
                if (selectedModule) {

                    let parsedModule = JSON.parse(selectedModule.RawJSON);
                    let parameters = parsedModule.parameters;

                    requiredFieldsDiv.innerHTML = "<h2>Required Fields</h2>";
                    optionalFieldsDiv.innerHTML = "<h2>Optional Fields</h2>";

                    for (let paramName in parameters) {
                        let param = parameters[paramName];

                        let isRequired = false;
                        if (param.metadata && param.metadata.description) {
                            const description = param.metadata.description.toLowerCase();
                            isRequired = description.startsWith("required");
                        }

                        let inputElement;
                        if (param.allowedValues) {
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
                outputTextarea.textContent = '';
                const selectedModule = modulesData.find(module => module.Name === moduleSelect.value);

                let outputJSON = {
                    "`$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
                    "contentVersion": "1.0.0.0",
                    "parameters": {}
                };

                let allRequiredFilled = true;
                const requiredInputs = requiredFieldsDiv.querySelectorAll('input, select');
                for (let input of requiredInputs) {
                    if (!input.value) {
                        allRequiredFilled = false;
                        break;
                    }
                    outputJSON.parameters[input.id] = { "value": input.value };
                }

                if (!allRequiredFilled) {
                    alert("Please fill all the required fields before generating the output.");
                    return;
                }

                const optionalInputs = optionalFieldsDiv.querySelectorAll('input, select');
                for (let input of optionalInputs) {
                    let parsedModule = JSON.parse(selectedModule.RawJSON);
                    let parameters = parsedModule.parameters;
                    if (selectedModule && parameters && parameters[input.id]) {
                        let paramDetails = parameters[input.id];
                        let defaultValue = paramDetails.defaultValue;
                        let actualValue;
                        if (input.type === "checkbox") {
                            actualValue = input.checked;
                        } else if (input.tagName.toLowerCase() === "select") {  // Para campos select
                            actualValue = input.options[input.selectedIndex].value;
                        } else {
                            actualValue = input.value;
                        }
                        if (actualValue && actualValue !== defaultValue) {
                            outputJSON.parameters[input.id] = { "value": actualValue };
                        }
                    }
                }

                outputTextarea.textContent = JSON.stringify(outputJSON, null, 2);
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
