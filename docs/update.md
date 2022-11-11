# Guardrails - Update

Updating the components of a previously-deploy Guardrails Solution Accelerator instance is accomplished using the GuardrailsSolutionAcceleratorSetup PowerShell module. It is possible to update individual components of a deployment but recommended to update all components to ensure versions remain synchronized. 

The components which can be updated are:

| Name | Description | Update Source |
|---|---|---|
| GuardrailPowerShellModules | The PowerShell modules that define each guardrail and the required controls. | GitHub Azure/GuardrailsSolutionAccelerator 'main' branch |
| AutomationAccountRunbooks | The Azure Automation Account runbook definitions which execute the guardrail PowerShell modules | Local clone of the GitHub repo |
| Workbook | The Workbook definition which displays the results guardrail PowerShell module executions, pulling from the Log Analytics workspace | Local clone of the GitHub repo |

## Update Process

1. Ensure you have the latest version of the Guardrails Solution Accelerator though one of the following processes:

    If you already have a clone of the GuardrailsSolutionAccelerator, navigate to that directory in PowerShell and use `git` to make sure you have the most recent changes:

    ```git
    cd GuardrailsSolutionAccelerator
    git fetch
    git checkout v1.0.6
    
    ```

    Otherwise, if you do not have a clone of the repo, use the `git` in a PowerShell console to pull a copy down to your system or Cloud Shell:

    ```git
    git clone https://github.com/Azure/GuardrailsSolutionAccelerator.git GuardrailsSolutionAccelerator
    
    ```

2. Import the GuardrailsSolutionAcceleratorPowershell module from your clone of the repo:

   ```powershell
   cd GuardrailsSolutionAccelerator # navigate to the GuardrailsSolutionAccelerator directory
   Import-Module ./src/GuardrailsSolutionAcceleratorSetup
   ```

3. Run the `Deploy-GuardrailsSolutionAccelerator` function with the `-updateComponent` parameter. Either pass in the JSON configuration file you used when deploying the Guardrails solution initially or pull the last used configuration from the specified KeyVault (recommended).

   Get the last used configuration from the specified Guardrails KeyVault (found in your Guardrails Solution resource group). This option is only available to deployments created or updated since release version `v1.0.6` of the solution. The executing user must have permissions to read secrets in the specified KeyVault. 

   ```powershell
      Get-GSAExportedConfig -KeyVaultName guardrails-xxxxx | Deploy-GuardrailsSolutionAccelerator -UpdateComponent All
   ```

   If you have the original JSON configuration file (or recreate one), you can pass it to the update process like this:

   ```powershell
      Deploy-GuardrailsSolutionAccelerator -UpdateComponent All -ConfigFilePath c:/myconfig.json
   ```