Disable-AzContextAutosave

#Standard variables
$WorkSpaceID=Get-AutomationVariable -Name "WorkSpaceID" 
$LogType=Get-AutomationVariable -Name "LogType" 
$KeyVaultName=Get-AutomationVariable -Name "KeyVaultName" 
$GuardrailWorkspaceIDKeyName=Get-AutomationVariable -Name "GuardrailWorkspaceIDKeyName" 
$ResourceGroupName=Get-AutomationVariable -Name "ResourceGroupName"
# This is one of the valid date format (ISO-8601) that can be sorted properly in KQL
$ReportTime=(get-date).tostring("yyyy-MM-dd HH:mm:ss")
$StorageAccountName=Get-AutomationVariable -Name "StorageAccountName" 
$Locale=Get-AutomationVariable -Name "GuardRailsLocale" 

# Connects to Azure using the Automation Account's managed identity
try {
    Connect-AzAccount -Identity -ErrorAction Stop
}
catch {
    throw "Critical: Failed to connect to Azure with the 'Connect-AzAccount' command and '-identity' (MSI) parameter; verify that Azure Automation identity is configured. Error message: $_"
}
$SubID = (Get-AzContext).Subscription.Id
$tenantID = (Get-AzContext).Tenant.Id

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

try {
    [String] $WorkspaceKey = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $GuardrailWorkspaceIDKeyName -AsPlainText -ErrorAction Stop
}
catch {
    throw "Failed to retrieve workspace key with secret name '$GuardrailWorkspaceIDKeyName' from KeyVault '$KeyVaultName'. Error message: $_"
}

Add-LogEntry 'Information' "Starting execution of main runbook" -workspaceGuid $WorkSpaceID -workspaceKey $WorkspaceKey -moduleName main `
    -additionalValues @{reportTime=$ReportTime; locale=$locale}

# Gets a token for the current sessions (Automation account's MI that can be used by the modules.)
[String] $GraphAccessToken = (Get-AzAccessToken -ResourceTypeName MSGraph).Token

# This loads the file containing all of the messages in the culture specified in the automation account variable "GuardRailsLocale"
Write-Output "Loading messages in $($Locale)" 
Import-LocalizedData -BindingVariable "msgTable" -UICulture $Locale -FileName "GR-ComplianceChecks-Msgs" -BaseDirectory "C:\Modules\User\GR-ComplianceChecks" #-ErrorAction SilentlyContinue
Write-Output "Loaded $($msgTable.Count) messages." 

foreach ($module in $modules)
{
    $NewScriptBlock = [scriptblock]::Create($module.Script)
    Write-Output "Processing Module $($module.modulename)" 
    $variables=$module.variables
    $secrets=$module.secrets
    $localVariables=$module.localVariables
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

    try {
        $NewScriptBlock.Invoke()
    }
    catch {
        $sanitizedScriptblock = $($ExecutionContext.InvokeCommand.ExpandString(($module.script -ireplace '$workspaceKey','***')))
        
        Add-LogEntry 'Error' "Failed invoke the module execution script for module '$($module.moduleName)', script '$sanitizedScriptblock' `
            with error: $_" -workspaceGuid $WorkSpaceID -workspaceKey $WorkspaceKey -moduleName main
        Write-Error "Failed invoke the module execution script for module '$($module.moduleName)', script '$sanitizedScriptblock' with error: $_"
    }
}

Add-LogEntry 'Information' "Completed execution of main runbook" -workspaceGuid $WorkSpaceID -workspaceKey $WorkspaceKey -moduleName main `
    -additionalValues @{reportTime=$ReportTime; locale=$locale}
# SIG # Begin signature block
# MIInpAYJKoZIhvcNAQcCoIInlTCCJ5ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBAKuxvO6cUjgQ1
# wq4gHYjqwxDRQ384cG8p1vNMHYkp9qCCDXYwggX0MIID3KADAgECAhMzAAACURR2
# zMWFg24LAAAAAAJRMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjEwOTAyMTgzMjU5WhcNMjIwOTAxMTgzMjU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDBIpXR3b1IYAMunV9ZYBVYsaA7S64mqacKy/OJUf0Lr/LW/tWlJDzJH9nFAhs0
# zzSdQQcLhShOSTUxtlwZD9dnfIcx4pZgu0VHkqQw2dVc8Ob21GBo5sVrXgEAQxZo
# rlEuAl20KpSIFLUBwoZFGFSQNSMcqPudXOw+Mhvn6rXYv/pjXIjgBntn6p1f+0+C
# 2NXuFrIwjJIJd0erGefwMg//VqUTcRaj6SiCXSY6kjO1J9P8oaRQBHIOFEfLlXQ3
# a1ATlM7evCUvg3iBprpL+j1JMAUVv+87NRApprPyV75U/FKLlO2ioDbb69e3S725
# XQLW+/nJM4ihVQ0BHadh74/lAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUMLgM7NX5EnpPfK5uU6FPvn2g/Ekw
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzQ2NzU5NjAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIVJlff+Fp0ylEJhmvap
# NVv1bYLSWf58OqRRIDnXbHQ+FobsOwL83/ncPC3xl8ySR5uK/af4ZDy7DcDw0yEd
# mKbRLzHIfcztZVSrlsg0GKwZuaB2MEI1VizNCoZlN+HlFZa4DNm3J0LhTWrZjVR0
# M6V57cFW0GsV4NlqmtelT9JFEae7PomwgAV9xOScz8HzvbZeERcoSRp9eRsQwOw7
# 8XeCLeglqjUnz9gFM7RliCYP58Fgphtkht9LNEcErLOVW17m6/Dj75zg/IS+//6G
# FEK2oXnw5EIIWZraFHqSaee+NMgOw/R6bwB8qLv5ClOJEpGKA3XPJvS9YgOpF920
# Vu4Afqa5Rv5UJKrsxA7HOiuH4TwpkP3XQ801YLMp4LavXnvqNkX5lhFcITvb01GQ
# lcC5h+XfCv0L4hUum/QrFLavQXJ/vtirCnte5Bediqmjx3lswaTRbr/j+KX833A1
# l9NIJmdGFcVLXp1en3IWG/fjLIuP7BqPPaN7A1tzhWxL+xx9yw5vQiT1Yn14YGmw
# OzBYYLX0H9dKRLWMxMXGvo0PWEuXzYyrdDQExPf66Fq/EiRpZv2EYl2gbl9fxc3s
# qoIkyNlL1BCrvmzunkwt4cwvqWremUtqTJ2B53MbBHlf4RfvKz9NVuh5KHdr82AS
# MMjU4C8KNTqzgisqQdCy8unTMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGYQwghmAAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAJRFHbMxYWDbgsAAAAAAlEwDQYJYIZIAWUDBAIB
# BQCggbAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIJkWK2lMrZ1xy1J3Fzk5XFrD
# tjhomi7k16tAV6m2bHjpMEQGCisGAQQBgjcCAQwxNjA0oBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEcgBpodHRwczovL3d3dy5taWNyb3NvZnQuY29tIDANBgkqhkiG9w0B
# AQEFAASCAQCxvJNIqRKnQdGYWTSkdpkopBcegrJhvy+b1qRMTYyO5BRc1odbHjjp
# whwaNkrkb/N4YnWMSdV3zolmk3WeVCFTL3pm1PXA3dULBw6RF1cPhi5XZpHs6SFR
# KJIhIIMhkbPjTC3nD0oNLiY/TmtLwcLZHAZTIF67P4o9RNZUqIiZk9ew3jQ/Kw+k
# GCp/OCzLQ3lCzoGxzT8lWssvXLPue74a+tU6kWczrHcOegexgVUIhjwY8VzW6voz
# 9jOsAknC4XaHpIUJakNVR1GSIwDWUexNKx842hL9qCWS5mEQPZMcStBWFrLuIWgH
# q+SZcMkO+8H7Sg1O20DuWbd3pFp9ClNFoYIXDDCCFwgGCisGAQQBgjcDAwExghb4
# MIIW9AYJKoZIhvcNAQcCoIIW5TCCFuECAQMxDzANBglghkgBZQMEAgEFADCCAVUG
# CyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMBMDEwDQYJYIZI
# AWUDBAIBBQAEIGm8MLP4qaB7oqtgdx5k4cSwDlTKTPU/gfzuzHu3WjzlAgZi2sqL
# 4pUYEzIwMjIwNzI2MTgzNjQwLjE2MVowBIACAfSggdSkgdEwgc4xCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBP
# cGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjow
# QTU2LUUzMjktNEQ0RDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaCCEV8wggcQMIIE+KADAgECAhMzAAABpzW7LsJkhVApAAEAAAGnMA0GCSqG
# SIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTIyMDMw
# MjE4NTEyMloXDTIzMDUxMTE4NTEyMlowgc4xCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjowQTU2LUUzMjktNEQ0
# RDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAO0jOMYdUAXecCWm5V6TRoQZ4hsPLe0V
# p6CwxFiTA5l867fAbDyxnKzdfBsf/0XJVXzIkcvzCESXoklvMDBDa97SEv+CuLEI
# ooMbFBH1WeYgmLVO9TbbLStJilNITmQQQ4FB5qzMEsDfpmaZZMWWgdOjoSQed9Ur
# jjmcuWsSskntiaUD/VQdQcLMnpeUGc7CQsAYo9HcIMb1H8DTcZ7yAe3aOYf766P2
# OT553/4hdnJ9Kbp/FfDeUAVYuEc1wZlmbPdRa/uCx4iKXpt80/5woAGSDl8vSNFx
# i4umXKCkwWHm8GeDZ3tOKzMIcIY/64FtpdqpNwbqGa3GkJToEFPR6D6XJ0WyqebZ
# vOZjMQEeLCJIrSnF4LbkkfkX4D4scjKz92lI9LRurhMPTBEQ6pw3iGsEPY+Jrcx/
# DJmyQWqbpN3FskWu9xhgzYoYsRuisCb5FIMShiallzEzum5xLE4U5fuxEbwk0uY9
# ZVDNVfEhgiQedcSAd3GWvVM36gtYy6QJfixD7ltwjSm5sVa1voBf2WZgCC3r4RE7
# VnovlqbCd3nHyXv5+8UGTLq7qRdRQQaBQXekT9UjUubcNS8ZYeZwK8d2etD98mSI
# 4MqXcMySRKUJ9OZVQNWzI3LyS5+CjIssBHdv19aM6CjXQuZkkmlZOtMqkLRg1tmh
# gI61yFC+jxB3AgMBAAGjggE2MIIBMjAdBgNVHQ4EFgQUH2y4fwWYLjCFb+EOQgPz
# 9PpaRYMwHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYDVR0fBFgw
# VjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWlj
# cm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwGCCsGAQUF
# BwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
# aW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgx
# KS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG
# 9w0BAQsFAAOCAgEATxL6MfPZOhR91DHShlzal7B8vOCUvzlvbVha0UzhZfvIcZA/
# bT3XTXbQPLnIDWlRdjQX7PGkORhX/mpjZCC5J7fD3TJMn9ZQQ8MXnJ0sx3/QJIlN
# gPVaOpk9Yk1YEqyItOyPHr3Om3v/q9h5f5qDk0IMV2taosze0JGlM3M5z7bGkDly
# +TfhH9lI03D/FzLjjzW8EtvcqmmH68QHdTsl84NWGkd2dUlVF2aBWMUprb8H9EhP
# UQcBcpf11IAj+f04yB3ncQLh+P+PSS2kxNLLeRg9CWbmsugplYP1D5wW+aH2mdyB
# lPXZMIaERJFvZUZyD8RfJ8AsE3uU3JSd408QBDaXDUf94Ki3wEXTtl8JQItGc3ix
# RYWNIghraI4h3d/+266OB6d0UM2iBXSqwz8tdj+xSST6G7ZYqxatEzt806T1BBHe
# 9tZ/mr2S52UjJgAVQBgCQiiiixNO27g5Qy4CDS94vT4nfC2lXwLlhrAcNqnAJKmR
# qK8ehI50TTIZGONhdhGcM5xUVeHmeRy9G6ufU6B6Ob0rW6LXY2qTLXvgt9/x/XEh
# 1CrnuWeBWa9E307AbePaBopu8+WnXjXy6N01j/AVBq1TyKnQX1nSMjU9gZ3EaG8o
# S/zNM59HK/IhnAzWeVcdBYrq/hsu9JMvBpF+ZEQY2ZWpbEJm7ELl/CuRIPAwggdx
# MIIFWaADAgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGI
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylN
# aWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5
# MzAxODIyMjVaFw0zMDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciEL
# eaLL1yR5vQ7VgtP97pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa
# 4n5KWv64NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxR
# MTegCjhuje3XD9gmU3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEByd
# Uv626GIl3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi9
# 47SHJMPgyY9+tVSP3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJi
# ss254o2I5JasAUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+
# /NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY
# 7afomXw/TNuvXsLz1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtco
# dgLiMxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH
# 29wb0f2y1BzFa/ZcUlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94
# q0W29R6HXtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcV
# AQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0G
# A1UdDgQWBBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQB
# gjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
# cGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# GQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB
# /wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0f
# BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJv
# ZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4w
# TDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0
# cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIB
# AJ1VffwqreEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRs
# fNB1OW27DzHkwo/7bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6
# Ce5732pvvinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveV
# tihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKB
# GUIZUnWKNsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoy
# GtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQE
# cb9k+SS+c23Kjgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFU
# a2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+
# k77L+DvktxW/tM4+pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0
# +CQ1ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cir
# Ooo6CGJ/2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIC0jCCAjsCAQEwgfyh
# gdSkgdEwgc4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAn
# BgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQL
# Ex1UaGFsZXMgVFNTIEVTTjowQTU2LUUzMjktNEQ0RDElMCMGA1UEAxMcTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAwH7vHimSAzeD
# LN0qzWNb2p2vRH+ggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDANBgkqhkiG9w0BAQUFAAIFAOaKjvUwIhgPMjAyMjA3MjYyMDA0MDVaGA8yMDIy
# MDcyNzIwMDQwNVowdzA9BgorBgEEAYRZCgQBMS8wLTAKAgUA5oqO9QIBADAKAgEA
# AgIiNQIB/zAHAgEAAgIRSjAKAgUA5ovgdQIBADA2BgorBgEEAYRZCgQCMSgwJjAM
# BgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEB
# BQUAA4GBAFLhjtwPHTTI6q3+L5r3E4gmYup/EjP0LNzKxSQsbU0IURGr+Ev77Kwz
# 26TZI7W9z12WF5LKnnPp61GwThpq6YNmQL+g5ChjYGmAGSRn8EqxHEvNa6/y+OL9
# 3FpuDEsVhPpvExFd27CBu0nSTSU4hQ+gyMXrb63WY8KxtcBBQI3bMYIEDTCCBAkC
# AQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGnNbsuwmSF
# UCkAAQAAAacwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG
# 9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgQ36pPJWjo5LClj2amz5UWBRa8hLvwddL
# QRLi9sefuLYwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCBH8H/nCZUC4L0Y
# qbz3sH3w5kzhwJ4RqCkXXKxNPtqOGzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFBDQSAyMDEwAhMzAAABpzW7LsJkhVApAAEAAAGnMCIEIE4GHlZx4Hx5rAMD
# tHU7wYfL93m7VwaNoqAyI2HitYTXMA0GCSqGSIb3DQEBCwUABIICAM+gJB2TVUkN
# nW/mnlvx9aYBwk4suGAa+7lPD3tbWRBEWngS+TSnYb2xYJTDHoWmFSb0yLGzGZSy
# EcP1NHPzaC2+gkp9eMppO2i0wSqL6zsVLBqcKhX2mTXnSSHThL43O1OHBZLhpUL5
# 3ySv+V2LcfBJFR49rHE+zrosx/aWpKr1Ebiv+peg/d2qE2gI3w/q/hhEJ2cO1oSA
# omogoNEe5qz/QqWUQPsEmiy3QGdHEMpQd/CXMF5jDb+aAvMpF56lnBYxGfyTolwx
# DP46kWf4cYXOWU81zvvEIwgkcPu6DIj6c0Jb8uCMP0zmWVBwlMSm7Rjknaij2RwW
# b794u9X8pAXSvLNdIIesaYXzoRjj8m7bMeR/3qTFQJf1lXatFe1Amt6mJrC1EIWJ
# diGFYU8lQuOi7HYBJ+j9xtvVU835JaRWF7jBQytYyv+8A/syCfpR9WPN7blx1AEA
# /MQrE1wPffTKdTAW0QrKRf8cdeh6nsYpw2ckBfhEOnbj10uQhWU5V6u6TF/doYko
# PxByDoAf8YN4Rsug1XfW3/ypjdfx1K4aL3nFP9zkEUiQYmZJOtyO2ikM9vZLplDR
# S8PkWo6SJUotmfD0PBt8lJJmuL8d5Wsv5oRnr9KRht5jlX/b7/UyJeVyPnoUJ5sq
# v+xpicXFPQ9ZAxMVtpxom+/uSSxQMQ2b
# SIG # End signature block
