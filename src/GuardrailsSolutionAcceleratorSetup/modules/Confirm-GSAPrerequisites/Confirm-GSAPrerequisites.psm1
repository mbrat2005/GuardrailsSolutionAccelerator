
Function Confirm-GSAPrerequisites {

    param (
        # config
        [Parameter(mandatory = $true)]
        [psobject]
        $config,

        # optional components included in the install
        [Parameter(Mandatory = $false)]
        [string[]]
        $newComponents
    )

    $ErrorActionPreference = 'Stop'

    Write-Verbose "Starting verification of the Guardrails Solution Accelerator prerequisites."

    If ($newComponents -contains 'CoreComponents') {
        Write-Verbose "Verifying prerequisites for Core Components..."

        # confirm that executing user required permission to complete the deployment
        Write-Verbose "Checking that user '$($config['runtime']['userId'])' has role 'User Access Administrator' or 'Owner' assigned at the root management group scope (id: '$($config['runtime']['tenantRootManagementGroupId'])')"
        Write-Verbose "`t Getting role assignments with cmd: Get-AzRoleAssignment -Scope $($config['runtime']['tenantRootManagementGroupId']) -RoleDefinitionName 'User Access Administrator' -ObjectId $($config['runtime']['userId']) -ErrorAction Continue"
        Write-Verbose "`t Getting role assignments with cmd: Get-AzRoleAssignment -Scope $($config['runtime']['tenantRootManagementGroupId']) -RoleDefinitionName 'Owner' -ObjectId $($config['runtime']['userId']) -ErrorAction Continue"
        $roleAssignments = @()
        $roleAssignments += Get-AzRoleAssignment -Scope $config['runtime']['tenantRootManagementGroupId'] -RoleDefinitionName 'User Access Administrator' -ObjectId $config['runtime']['userId'] -ErrorAction Continue
        $roleAssignments += Get-AzRoleAssignment -Scope $config['runtime']['tenantRootManagementGroupId'] -RoleDefinitionName 'Owner' -ObjectId $config['runtime']['userId'] -ErrorAction Continue

        Write-Verbose "`t Count of role assignments '$($roleAssignments.Count)'"
        if ($roleAssignments.count -eq 0) {
            Write-Error "Specified user ID '$($config['runtime']['userId'])' does not have role 'User Access Administrator' or 'Owner' assigned at the root management group scope!"
            Break                                                
        }
        Else {
            Write-Verbose "`t Sufficent role assignment for current user exists..."
        }

        # confirm that target resources do not already exist

        ## storage account
        Write-Verbose "Verifying that storage account name '$($config['runtime']['storageAccountName'])' is available"
        $nameAvailability = Get-AzStorageAccountNameAvailability -Name $config['runtime']['storageaccountName']
        if (($nameAvailability).NameAvailable -eq $false) {
            Write-Error "Storage account $($config['runtime']['storageaccountName']) is not available. Message: $($nameAvailability.Message)"
            break
        }
        Else {
            Write-Verbose "Storage account name '$($config['runtime']['storageAccountName'])' is available"
        }

        ## keyvault
        Write-Verbose "Verifying the Key Vault name '$($config['runtime']['keyVaultName'])' is available"
        $kvContent = ((Invoke-AzRest -Uri "https://management.azure.com/subscriptions/$($config['runtime']['subscriptionId'])/providers/Microsoft.KeyVault/checkNameAvailability?api-version=2021-11-01-preview" `
                    -Method Post -Payload "{""name"": ""$config['runtime']['keyVaultName']"",""type"": ""Microsoft.KeyVault/vaults""}").Content | ConvertFrom-Json).NameAvailable
        if (!($kvContent) -and $deployKV) {
            write-output "Error: keyvault name '$($config['runtime']['keyVaultName'])' is not available. Specify another prefix in config.json or a different unique resource name suffix"
            break
        }
    }

    # confirm lighthouse prereqs met
    If (($newComponents -contains 'CentralizedCustomerReportingSupport') -or ($newComponents -contains 'CentralizedCustomerDefenderForCloudSupport')) {
        # verify Lighthouse config parameters
        $lighthouseServiceProviderTenantID = $config.lighthouseServiceProviderTenantID
        $lighthousePrincipalDisplayName = $config.lighthousePrincipalDisplayName
        $lighthousePrincipalId = $config.lighthousePrincipalId
        $lighthouseTargetManagementGroupID = $config.lighthouseTargetManagementGroupID

        If ($newComponents -contains 'CentralizedCustomerReportingSupport') {
            Write-Verbose "Verifying prerequisites for Centralized Customer Reporting Support..."

            Write-Verbose "Confirming that the GSA core resources exist or will be deployed..."
            If ($newComponents -notcontains 'CoreComponents') {
                If (-NOT (Get-AzResourceGroup -Name $config['runtime']['resourceGroup'] -ErrorAction SilentlyContinue)) {
                    Write-Error "Unable to locate the resource group '$($config['runtime']['resourceGroup'])'; deployment of the centralized management components require that the core components be deployed first."
                    break
                }
                Else {
                    Write-Verbose "`tFound resource group '$($config['runtime']['resourceGroup'])'"
                }

                If (-NOT (Get-AzOperationalInsightsWorkspace -ResourceGroupName $config['runtime']['resourceGroup'] -Name $config['runtime']['logAnalyticsWorkspaceName'] -ErrorAction SilentlyContinue)) {
                    Write-Error "Unable to locate the Log Analytics workspace '$($config['runtime']['logAnalyticsWorkspaceName'])'; deployment of the centralized management components require that the core components be deployed first."
                    break
                }
                Else {
                    Write-Verbose "`tFound Log Analytics workspace '$($config['runtime']['logAnalyticsWorkspaceName'])'"
                }
            }

            # get lighthouse definitions for the managing tenant
            Write-Verbose "Checking for lighthouse registration definitions for managing tenant '$lighthouseServiceProviderTenantID'..."

            $uri = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.ManagedServices/registrationdefinitions?api-version=2022-01-01-preview&$filter=managedByTenantId eq {1}' -f `
                $config['runtime']['subscriptionId'], "'$lighthouseServiceProviderTenantID'"
            $response = Invoke-AzRestMethod -Method GET -Uri $uri

            If ($response.StatusCode -notin '200', '404') {
                Write-Error "An error occurred while retrieving Lighthouse registration definitions. Error: $($response.Content)"
                break
            }

            Write-Verbose "Found $($response.Content.value.Count) registration definitions for managing tenant '$lighthouseServiceProviderTenantID', filtering for registration definitions with the name 'SSC CSPM - Read Guardrail Status'..."
            $definitionsValue = $response.Content | ConvertFrom-Json | Select-Object -ExpandProperty value
            $guardrailReaderDefinitions = $definitionsValue | Where-Object { $_.Properties.registrationDefinitionName -eq 'SSC CSPM - Read Guardrail Status' }

            If ($guardrailReaderDefinitions.count -eq 0) {
                Write-Verbose "No Lighthouse registration definitions found for the managing tenant ID '$lighthouseServiceProviderTenantID'."
            }
            ElseIf (($guardrailReaderDefinitions.count -gt 1)) {
                Write-Error "More than 1 Lighthouse registration definition found for the managing tenant ID '$lighthouseServiceProviderTenantID' with the description 'SSC CSPM - Read Guardrail Status', please remove these registrations before continuing..."
                break
            }
            Else {
                Write-Verbose "Found '$($guardrailReaderDefinitions.count)' Lighthouse registration definitions for the managing tenant ID '$lighthouseServiceProviderTenantID' with the description 'SSC CSPM - Read Guardrail Status'."
                #remove lighthouse assignments
                Write-Verbose "Checking for Lighthouse assignments for managing tenant '$lighthouseServiceProviderTenantID' and definition ID '$($guardrailReaderDefinitions.id)'..."
                $uri = 'https://management.azure.com/subscriptions/{0}/providers/Microsoft.ManagedServices/registrationAssignments?api-version=2022-01-01-preview&$filter=registrationDefinitionId eq {1}' -f `
                    $config['runtime']['subscriptionId'], "'$($guardrailReaderDefinitions.id)'"
                $response = Invoke-AzRestMethod -Method GET -Uri $uri -Verbose

                If ($response.StatusCode -notin '200', '404') {
                    Write-Error "An error occurred while retrieving Lighthouse assignments. Error: $($response.Content)"
                    break
                }

                $assignmentValue = $response.Content | ConvertFrom-Json

                If ($assignmentValue.count -gt 0) {
                    Write-Error "Found $($assignmentValue.count) Lighthouse assignments for the managing tenant ID '$lighthouseServiceProviderTenantID' and definition ID '$($guardrailReaderDefinitions.id)', please remove these assignments before continuing."
                    break
                }
            }
        }
    
        If ($newComponents -contains 'CentralizedCustomerDefenderForCloudSupport') {
            Write-Verbose "Verifying prerequisites for Centralized Customer Defender for Cloud Support..."
            # check that user has correct permissions for deploying to tenant root mgmt group
            ## this permission is required so that a Policy Definition and Assignment can be deployed at the target management group, applying to all subscriptions in the tenant
            if ($lighthouseTargetManagementGroupID -eq $config['runtime']['tenantId']) {
                Write-Verbose "lighthouseTargetManagementGroupID is the tenant root managment group, which requires explicit owner permissions for the exeucting user; verifying..."
        
                $existingAssignment = Get-AzRoleAssignment -Scope '/' -RoleDefinitionName Owner -ObjectId $config['runtime']['userId'] | Where-Object { $_.Scope -eq '/' }
                If (!$existingAssignment) {
                    Write-Error "In order to deploy resources at the Tenant Root Management Group '$lighthouseTargetManagementGroupID', the executing user must be explicitly granted Owner 
                        rights at the root level. To create this role assignment, run 'New-AzRoleAssignment -Scope '/' -RoleDefinitionName Owner -ObjectId $($config['runtime']['userId'])' 
                        then execute this script again. This role assignment only needs to exist during the Lighthouse resource deployments and can (and should) be removed after this script completes."
                    Exit
                }
            }
        
            If ($lighthouseTargetManagementGroupID -eq $config['runtime']['tenantId']) {
                $assignmentScopeMgmtmGroupId = '/'
            }
            Else {
                $assignmentScopeMgmtmGroupId = $lighthouseTargetManagementGroupID
            }

            # check if a lighthouse defender for cloud policy MSI role assignment already exists - assignment name always 2cb8e1b1-fcf1-439e-bab7-b1b8b008c294 
            Write-Verbose "Checking for role assignments at management group '$assignmentScopeMgmtmGroupId' for role 'Owner'"
            $uri = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Authorization/roleAssignments/{1}?&api-version=2015-07-01' -f $lighthouseTargetManagementGroupID, '2cb8e1b1-fcf1-439e-bab7-b1b8b008c294'
            $roleAssignments = Invoke-AzRestMethod -Uri $uri -Method GET | Select-Object -Expand Content | ConvertFrom-Json
            If ($roleAssignments.id) {
                Write-Verbose "role assignment: $(($roleAssignments).id)"
                Write-Error "A role assignment exists with the name '2cb8e1b1-fcf1-439e-bab7-b1b8b008c294' at the Management group '$lighthouseTargetManagementGroupID'. This was likely
                created by a previous Guardrails deployment and must be removed. Navigate to the Managment Group in the Portal and delete the Owner role assignment listed as 'Identity Not Found'"
                Exit
            }
    
            # check if lighthouse Custom-RegisterLighthouseResourceProvider exists at a different scope
            Write-Verbose "Checking for existing role definitions with name 'Custom-RegisterLighthouseResourceProvider'"
            $roleDef = Get-AzRoleDefinition -Name 'Custom-RegisterLighthouseResourceProvider'
            $targetAssignableScope = "/providers/Microsoft.Management/managementGroups/$lighthouseTargetManagementGroupID"
            
            Write-Verbose "Found '$($roleDef.count)' role definitions with name 'Custom-RegisterLighthouseResourceProvider'. Verifying assignable scopes includes '$targetAssignableScope'"
            If ($roleDef -and $roleDef.AssignableScopes -notcontains $targetAssignableScope) {
                Write-Error "Role definition name 'Custom-RegisterLighthouseResourceProvider' already exists and has an assignable scope of '$($roleDef.AssignableScopes)'. Assignable scopes
                should include '$targetAssignableScope'. Delete the role definition (and any assignments) and run the script again."
                Exit
            }
    
            # check if a lighthouse Azure Automation MSI role assignment to register the Lighthouse resource provider already exists - assignment name always  5de3f84b-8866-4432-8811-24859ccf8146
            Write-Verbose "Checking for role assignments at management group '$assignmentScopeMgmtmGroupId' for role 'Custom-RegisterLighthouseResourceProvider'"
            $uri = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Authorization/roleAssignments/{1}?&api-version=2015-07-01' -f $lighthouseTargetManagementGroupID, '5de3f84b-8866-4432-8811-24859ccf8146'
            $roleAssignments = Invoke-AzRestMethod -Uri $uri -Method GET | Select-Object -Expand Content | ConvertFrom-Json   
            If ($roleAssignments.id) {  
                Write-Verbose "role assignment: $(($roleAssignments).id)"  
                Write-Error "A role assignment exists with the name '5de3f84b-8866-4432-8811-24859ccf8146' at the Management group '$lighthouseTargetManagementGroupID'. This was likely
                created by a previous Guardrails deployment and must be removed. Navigate to the Managment Group in the Portal and delete the 'Custom-RegisterLighthouseResourceProvider' role assignment listed as 'Identity Not Found'"
                Exit
            
            }
        }
    }
    
    Write-Host "Prerequisite validation completed successfully!" -ForegroundColor Green

    Write-Verbose "Completed verification of the Guardrails Solution Accelerator prerequisites."
}
# SIG # Begin signature block
# MIInogYJKoZIhvcNAQcCoIInkzCCJ48CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCfQr/8wNvnPfA5
# tOuYnSikTYkGzzPU+4LjuuSvuK7v2KCCDYUwggYDMIID66ADAgECAhMzAAACzfNk
# v/jUTF1RAAAAAALNMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAyWhcNMjMwNTExMjA0NjAyWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDrIzsY62MmKrzergm7Ucnu+DuSHdgzRZVCIGi9CalFrhwtiK+3FIDzlOYbs/zz
# HwuLC3hir55wVgHoaC4liQwQ60wVyR17EZPa4BQ28C5ARlxqftdp3H8RrXWbVyvQ
# aUnBQVZM73XDyGV1oUPZGHGWtgdqtBUd60VjnFPICSf8pnFiit6hvSxH5IVWI0iO
# nfqdXYoPWUtVUMmVqW1yBX0NtbQlSHIU6hlPvo9/uqKvkjFUFA2LbC9AWQbJmH+1
# uM0l4nDSKfCqccvdI5l3zjEk9yUSUmh1IQhDFn+5SL2JmnCF0jZEZ4f5HE7ykDP+
# oiA3Q+fhKCseg+0aEHi+DRPZAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU0WymH4CP7s1+yQktEwbcLQuR9Zww
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzQ3MDUzMDAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AE7LSuuNObCBWYuttxJAgilXJ92GpyV/fTiyXHZ/9LbzXs/MfKnPwRydlmA2ak0r
# GWLDFh89zAWHFI8t9JLwpd/VRoVE3+WyzTIskdbBnHbf1yjo/+0tpHlnroFJdcDS
# MIsH+T7z3ClY+6WnjSTetpg1Y/pLOLXZpZjYeXQiFwo9G5lzUcSd8YVQNPQAGICl
# 2JRSaCNlzAdIFCF5PNKoXbJtEqDcPZ8oDrM9KdO7TqUE5VqeBe6DggY1sZYnQD+/
# LWlz5D0wCriNgGQ/TWWexMwwnEqlIwfkIcNFxo0QND/6Ya9DTAUykk2SKGSPt0kL
# tHxNEn2GJvcNtfohVY/b0tuyF05eXE3cdtYZbeGoU1xQixPZAlTdtLmeFNly82uB
# VbybAZ4Ut18F//UrugVQ9UUdK1uYmc+2SdRQQCccKwXGOuYgZ1ULW2u5PyfWxzo4
# BR++53OB/tZXQpz4OkgBZeqs9YaYLFfKRlQHVtmQghFHzB5v/WFonxDVlvPxy2go
# a0u9Z+ZlIpvooZRvm6OtXxdAjMBcWBAsnBRr/Oj5s356EDdf2l/sLwLFYE61t+ME
# iNYdy0pXL6gN3DxTVf2qjJxXFkFfjjTisndudHsguEMk8mEtnvwo9fOSKT6oRHhM
# 9sZ4HTg/TTMjUljmN3mBYWAWI5ExdC1inuog0xrKmOWVMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGXMwghlvAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAALN82S/+NRMXVEAAAAA
# As0wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEINRC
# HOK5HHxIFNr5Juaa3tUy6INGUjsv/CcCkp1M6JxJMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAa6qapnLMVawYYlA6bXYQoQB7DjU0gig4q676
# goY0SL+pc3VfXbDHAAIQ4lrd+mqqsh8O8imSfBH90PV5OTHFVUBH1ELnnwe7kCsB
# 1UIY6VawWoYoYBOArUqTEZ7hMmCo6elFP+8FLfp6SQ6VjKj+6F52DInsObPJ7S9H
# 9ZDsWEfYJQJfyAZxylmI5iI9n1z2qKRhoyR7KEuN0gb+0g58GytJxok67cZT2lx0
# YvNBkGEtUBuDs8HB9bfpZcCCNMB340JSmIH3Z//lmqoOeA+dvBXZ7kganHPIYBu4
# zB/iuQA4zOfQniuuPi8vvj/H8wsPPiGaW87QwO5kNsUv8VwTwqGCFv0wghb5Bgor
# BgEEAYI3AwMBMYIW6TCCFuUGCSqGSIb3DQEHAqCCFtYwghbSAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCB6OYTJA0AkS46Oeds7wXSUTDVF+MuC9IjR
# +0V3c3k5zQIGY21D76t4GBMyMDIyMTEzMDE4MTEzMy45NTNaMASAAgH0oIHQpIHN
# MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjoyMjY0LUUzM0UtNzgwQzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEVQwggcMMIIE9KADAgECAhMzAAABwT6gg5zgCa/FAAEA
# AAHBMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIyMTEwNDE5MDEyN1oXDTI0MDIwMjE5MDEyN1owgcoxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjIyNjQtRTMz
# RS03ODBDMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5LHXMydw2hUC4pJU0I5uPJnM
# eRm8LKC4xaIDu3Fxx3IpZ/We2qXLj4NOmow/WPFeY4vaT4/S4T9xoDsFGg5wEJM6
# OLZVfa7BUNu0tDt4rkl7QBYNHzz6pcr9bwaq2qm7x6P9yi5W0Y8sjoj+QTgtmmXo
# xCoNXhJ1oG6GbqADQXDZkTcDjIAiteE6TxrhBpIb7e6upifTGZNfcChPfuzHq61F
# SIwJ0XCxcaR1BwAlSKhb/NUOuQGPr9Zzd6OnIcA+RctxwKgfOKB9aWEEHlt0jhKK
# gpEBvcJnMMP+WaTwmMhob1e+hoCEFx/nI0YHupi6082kFdNFraE72msOYQrwrUyW
# CeSmN202LZDpTzxZVty6QrBOk+f+BErsR+M5evkKuUTWVJHI3vtNgb6K5+gk6EuQ
# w0ocsDdspiPp+qlxBaW50yUbr6wnfzYjJh7QkPcfBIZbJAhWQHaV0uS3T7OkObdC
# ssCRMWH7VWUAeSbemuUqOXCR7rdpFTfY/SXKO9lCIQBAQSh+wzwh5Zv1b+jT2zWw
# Vl82By3YHmST8b8CKnRXSCjLtgoyy7ERLwkbzPIkCfBXcyVneC1w2/wUnqPiAjK0
# wQfztfXFfoMQr8YUcLHnAtek8OVNPuRIV6bcERbF6rtFXmnjjD4ZwVxIZ/HM4cje
# VGsEwkFA9XTzqX9W1P8CAwEAAaOCATYwggEyMB0GA1UdDgQWBBRfr2MJ6x7yE+gP
# 5uX9xWGTwpRC+jAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
# HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYI
# KwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
# MDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0G
# CSqGSIb3DQEBCwUAA4ICAQBfuiaBgsecHvM90RZiTDlfHblL09r9X+5q9ckuMR0B
# s1Sr5B2MALhT5Y0R3ggLufRX6RQQbSc7WxRXIMr5tFEgB5zy/7Yg81Cn2dhTf1Gz
# jCb7/n3wtJSGtr2QwHsa1ehYWdMfi+ETLoEX1G79VPFrs0t6Giwpr74tv+CLE3s6
# m10VOwe80wP4yuT3eiFfqRV8poUFSdL2wclgQKoSwbCpbJlNC/ESaDQbbQFli9uO
# 5j2f/G7S4TMG/gyyxvMQ5QJui9Fw2s7qklmozQoX2Ah4aKubKe9/VZveiETNYl1A
# ZPj0kj1g51VNyWjvHw+Hz1xZekWIpfMXQEi0wrGdWeiW4i8l92rY3ZbdHsErFYqz
# h6FRFOeXgazNsfkLmwy+TK17mA7CTEUzaAWMq5+f9K4Y/3mhB4r6UristkWpdkPW
# Eo8b9tbkdKSY00E+FS5DUtjgAdCaRBNaBu8cFYCbErh9roWDxc+Isv8yMQAUDuEw
# XSy0ExnIAlcVIrhzL40OsG2ca5R5BgAevGP1Hj9ej4l/y+Sh0HVcN9N6LmPDmI/M
# aU2rEZ7Y+jRfCZ1d+l5DESdLXIxDTysYXkT+3VM/1zh6y2s0Zsb/3vPaGnp2zejw
# f2YlGWl1XpChNZTelF5eOCCfSzUUn3qHe7IyyDKhahgbnKpmwcEkMVBs+RHbVkNW
# qDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQEL
# BQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNV
# BAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4X
# DTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzAR
# BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
# bXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM
# 57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm
# 95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzB
# RMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBb
# fowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCO
# Mcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYw
# XE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW
# /aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/w
# EPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPK
# Z6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2
# BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXbGjfH
# CBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYB
# BAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8v
# BO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYM
# KwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEF
# BQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBW
# BgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUH
# AQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# L2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518Jx
# Nj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+
# iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2
# pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefw
# C2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7
# T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFO
# Ry3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhL
# mm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3L
# wUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5
# m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE
# 0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLLMIICNAIB
# ATCB+KGB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UE
# CxMdVGhhbGVzIFRTUyBFU046MjI2NC1FMzNFLTc4MEMxJTAjBgNVBAMTHE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAESKOtSK7RVV
# K+Si+aqFd0YSY+VPoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwDQYJKoZIhvcNAQEFBQACBQDnMXZAMCIYDzIwMjIxMTMwMTQyNzEyWhgPMjAy
# MjEyMDExNDI3MTJaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOcxdkACAQAwBwIB
# AAICBb0wBwIBAAICEdEwCgIFAOcyx8ACAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYK
# KwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUF
# AAOBgQAbFgA05XaTPtfIkfdJ1iGLQd/y82kvGEmIH2SsHh3aTmTDLNdsWj3MLGUN
# AhLzVpFjmOH0c0Q8+sGBynDsmypNQ2sLumJTR+xaJ4oYmxeZW0qFcGE0skezN8Bw
# ZO3PNy52bNL2zQgylUh4qMPbyXRi2MFh9dJNjDlIo3g+0qEfZjGCBA0wggQJAgEB
# MIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABwT6gg5zgCa/F
# AAEAAAHBMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcN
# AQkQAQQwLwYJKoZIhvcNAQkEMSIEILptvesxgtS97NAw7Y6d8c/1jiVLaBZ+HJ94
# qYzzvejBMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgCrkg6tgYHeSgIsN3
# opR2z7EExWA0YkirkvVYSTBgdtQwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMAITMwAAAcE+oIOc4AmvxQABAAABwTAiBCB6/finKRxuiIoj1CZY
# 6HAUHHAQ0f96hSwKFJs2vXMK8jANBgkqhkiG9w0BAQsFAASCAgAqQBZfi1p0KL/u
# 5hXtQb1loq7ZF+xc71G+HEJrN/z5X8T9lBDgHt9Adkp68LMJPufLxJ0NFWmdqRar
# bgkbIsg5Z2LIx5x4yTlSsEtywwjEo9Q9e71uAch9tW7JDzVmEx9XLdYwZZ90hRDI
# 1GHM24iKonmtHUehdlPILaqxwmsB3xQAy1zNLMqyibo+WpnJbTVREw8PBh1WyuKI
# dyXseUKu3qZVlPJcD2jT7Ho6OUVh+hodNQtjctPujQaW2O5+XfVt3C4Vr/W04BCl
# +yZ7yNXAabtVYzwTYurf0xFrSYCyJB3eDbHTIzG+wWLO/87i3gRJEHvszCVsnGlo
# +/P+KYbLh6mPAZq2aMuZPeSagEH0nbStD7Geg1KRqvKZv2swQf5MBNOgL8hrQJnL
# PcY55thmNSXkn5tjWU7SllSI/DiIyXQpqj+WcdlY/SLE4amdUgDW+PRSIr8OfR4r
# EmJFYi273RJocCIHInhiDcYNs0QWwiwFx/r9MKDCRLVUvYdoWCiQv7fODOdKq9yR
# w0DSG7ogc8KHX5sYwGJ4Paui+66LelBr9vQVJmVoM3FrLVMhtsMUhl7S1+haCyBr
# QNEcT0iP9kjtNTQfrQB3VFxU7TsneXxh2xgIhjSWehjFm5T3EAZvL/8sTUuwGVuh
# QR8KLzAgefjh781QHYrj1YLwzqlYVg==
# SIG # End signature block
