# Creating a new module

- Write PowerShell Module, sign it and zip it.
- Store the compress file in the psmodules folder
- Add module import to the bicep file
- Update modules.json file with the modules information:
{
   "ModuleName": "Name of your module",
   "Script": "how to call the module with all parameters.",
   "variables":
   [
     {
       "Name":"Name of a variable to be used in the Script block above. This is the name that you be available as $vars.Name",
       "Value":"the value of the Variable name in the Automation account"
     }
   ]
}
- Add automation account variable to the bicep file and update setup/config/etc if required.

## Standard variables

These variables can be used in the module calls without the needs of creating custom variables in the modules.json file.

- $WorkSpaceID : log analytics
- $LogType : the type of logs
- $KeyVaultName: name of the keyvault
- $GuardrailWorkspaceIDKeyName : Name of the variable object name in the AA containing the keyvault key.
- $ResourceGroupName : name of the resource group for guardrails.
- $StorageAccountName : Name of the Storage Account.
- $ReportTime: the unified report time for all modules in each execution.
