Disable-AzContextAutosave

Import-LocalizedData -BaseDirectory werwer -BindingVariable "msgTable" -FileName qweer -UICulture "en-CA"

#region Parameters 
$CtrName1 = "GUARDRAIL 1: PROTECT ROOT / GLOBAL ADMINS ACCOUNT"
$CtrName2 = "GUARDRAIL 2: MANAGEMENT OF ADMINISTRATIVE PRIVILEGES"
$CtrName3 = "GUARDRAIL 3: CLOUD CONSOLE ACCESS"
$CtrName4 = "GUARDRAIL 4: ENTERPRISE MONITORING ACCOUNTS"
$CtrName5 = "GUARDRAIL 5: DATA LOCATION"
$CtrName6 = "GUARDRAIL 6: PROTECTION OF DATA-AT-REST"
$CtrName7 = "GUARDRAIL 7: PROTECTION OF DATA-IN-TRANSIT"
$CtrName8 = "GUARDRAIL 8: NETWORK SEGMENTATION AND SEPARATION"
$CtrName9 = "GUARDRAIL 9: NETWORK SECURITY SERVICES"
$CtrName10 = "GUARDRAIL 10: CYBER DEFENSE SERVICES"
$CtrName11 = "GUARDRAIL 11: LOGGING AND MONITORING"
$CtrName12 = "GUARDRAIL 12: CONFIGURATION OF CLOUD MARKETPLACES"

#Standard variables
$WorkSpaceID=Get-AutomationVariable -Name "WorkSpaceID" 
$LogType=Get-AutomationVariable -Name "LogType" 
$KeyVaultName=Get-AutomationVariable -Name "KeyVaultName" 
$GuardrailWorkspaceIDKeyName=Get-AutomationVariable -Name "GuardrailWorkspaceIDKeyName" 
$ResourceGroupName=Get-AutomationVariable -Name "ResourceGroupName"
$ReportTime=(get-date).tostring("dd-MM-yyyy-hh:mm:ss")
$StorageAccountName=Get-AutomationVariable -Name "StorageAccountName" 


#$modulesList=Get-AutomationVariable -Name "ModulesList" # Disabled for now
#temporarily testing from a file.
Write-Output "Reading configuration file."
read-blob -FilePath ".\modules.json" -resourcegroup $ResourceGroupName -storageaccountName $StorageAccountName -containerName "configuration"
try {
    $modulesList=Get-Content .\modules.json
}
catch {
    Write-Error "Couldn't find module configuration file."    
    break
}
$modules=$modulesList | convertfrom-json

Write-Output "Found $($modules.Count) modules."

#$ContainerName=Get-AutomationVariable -Name "ContainerName" 
#$PBMMPolicyID=Get-AutomationVariable -Name "PBMMPolicyID"
#$AllowedLocationPolicyId=Get-AutomationVariable -Name "AllowedLocationPolicyId"
#$DepartmentNumber=Get-AutomationVariable -Name "DepartmentNumber"
#$CBSSubscriptionName =Get-AutomationVariable -Name "CBSSubscriptionName"
#$SecurityLAWResourceId=Get-AutomationVariable -Name "SecurityLAWResourceId"
#$HealthLAWResourceId=Get-AutomationVariable -Name "HealthLAWResourceId"

# Connects to Azure using the Automation Account's managed identity
Connect-AzAccount -Identity
$SubID = (Get-AzContext).Subscription.Id
$tenantID = (Get-AzContext).Tenant.Id

[String] $WorkspaceKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $GuardrailWorkspaceIDKeyName -AsPlainText 
# Gets a token for the current sessions (Automation account's MI that can be used by the modules.)
[String] $GraphAccessToken = (Get-AzAccessToken -ResourceTypeName MSGraph).Token

foreach ($module in $modules)
{
    $NewScriptBlock = [scriptblock]::Create($module.Script)
    Write-Output "Processing Module $($module.modulename)" -ForegroundColor Yellow
    $variables=$module.variables
    $secrets=$module.secrets
    $localVariables=$module.$localVariables
    $vars = [PSCustomObject]@{}          
    if ($variables -ne $null)
    {
        foreach ($v in $variables)
        {
            $tempvarvalue=Get-AutomationVariable -Name $v.value
            $vars | Add-Member -MemberType Noteproperty -Name $($v.Name) -Value $tempvarvalue
        }      
    }
    if ($secrets -ne $null)
    {
        foreach ($v in $secrets)
        {
            $tempvarvalue=Get-AzKeyVaultSecret -VaultName $KeyVaultName -AsPlainText -Name $v.value
            $vars | Add-Member -MemberType Noteproperty -Name $($v.Name) -Value $tempvarvalue
        }
    }
    if ($localVariables -ne $null)
    {
        foreach ($v in $localVariables)
        {
            $vars | Add-Member -MemberType Noteproperty -Name $($v.Name) -Value $v.value
        }
    }
    $vars
    Write-host $module.Script
    $NewScriptBlock.Invoke()
}
break
<#
"Check-ADDeletedUsers"
Check-ADDeletedUsers -Token $GraphAccessToken -ControlName $CtrName2 -ItemName "Remove deprecated accounts" `
    -LogType $LogType -WorkSpaceID $WorkSpaceID -WorkspaceKey $WorkspaceKey -ReportTime $ReportTime 
"Check-ExternalUsers"    
Check-ExternalUsers -Token $GraphAccessToken -ControlName $CtrName2 -ItemName "Remove External accounts" `
    -LogType $LogType -WorkSpaceID $WorkSpaceID -WorkspaceKey $WorkspaceKey -ReportTime $ReportTime 
"Check-MonitorAccountCreation"
Check-MonitorAccountCreation -Token $GraphAccessToken -DepartmentNumner $DepartmentNumber -ControlName $CtrName4 -ItemName "Monitor Account Creation" `
    -LogType $LogType -WorkSpaceID $WorkSpaceID -WorkspaceKey $WorkspaceKey -ReportTime $ReportTime 
"Verify-PBMMPolicy"
#Verify-PBMMPolicy -ControlName $CtrName5  -ItemName "PBMMPolicy Compliance" -PolicyID $PBMMPolicyID -LogType $LogType -WorkSpaceID $WorkSpaceID -WorkspaceKey $workspaceKey$CtrName6 = "GUARDRAIL 6: PROTECTION OF DATA-AT-REST"
$ItemName6="PROTECTION OF DATA-AT-REST"
$ItemName7="PROTECTION OF DATA-IN-TRANSIT"
Verify-PBMMPolicy -ControlName $CtrName5 -ItemName "PBMMPolicy Compliance" `
-CtrName6 $CtrName6 -ItemName6 $ItemName6 `
-CtrName7 $CtrName7 -ItemName7 $ItemName7 `
-PolicyID $PBMMPolicyID -LogType $LogType `
-WorkSpaceID $WorkSpaceID -WorkspaceKey $WorkspaceKey `
-ReportTime $ReportTime -CBSSubscriptionName $CBSSubscriptionName
"Verify-AllowedLocationPolicy"
Verify-AllowedLocationPolicy -ControlName $CtrName5 -ItemName "AllowedLocationPolicy" `
-PolicyID $AllowedLocationPolicyId -LogType $LogType `
-WorkSpaceID $WorkSpaceID -workspaceKey $workspaceKey `
-ReportTime $ReportTime -CBSSubscriptionName $CBSSubscriptionName
#Guardrail module 8
"Get-SubnetComplianceInformation" 
Get-SubnetComplianceInformation -ControlName $CtrName8 -WorkSpaceID $WorkSpaceID -workspaceKey $WorkspaceKey `
-ReportTime $ReportTime -CBSSubscriptionName $CBSSubscriptionName
#Guardrail module 9
"Get-VnetComplianceInformation"
Get-VnetComplianceInformation -ControlName $CtrName9 -WorkSpaceID $WorkSpaceID -workspaceKey $WorkspaceKey  `
-ReportTime $ReportTime -CBSSubscriptionName $CBSSubscriptionName
#Guradrail modul 10
"Check-CBSSensors"
Check-CBSSensors -SubscriptionName $CBSSubscriptionName  -TenantID $TenantID -ControlName $CtrName10 `
                 -WorkSpaceID $WorkSpaceID -workspaceKey $WorkspaceKey -ReportTime $ReportTime -LogType $LogType
#Guardrail Module 11
"Check-LoggingAndMonitoring"
Check-LoggingAndMonitoring -SecurityLAWResourceId $SecurityLAWResourceId `
-HealthLAWResourceId $HealthLAWResourceId `
-LogType $LogType `
-WorkSpaceID $WorkSpaceID -WorkspaceKey $WorkspaceKey  `
-ControlName $CtrName11 `
-ReportTime $ReportTime `
-CBSSubscriptionName $CBSSubscriptionName
#Guardrail module 12 
"Check-PrivateMarketPlaceCreation"
Check-PrivateMarketPlaceCreation -ControlName $Ctrname12  -WorkSpaceID $WorkSpaceID -workspaceKey $WorkspaceKey -ReportTime $ReportTime -LogType $LogType
#>
