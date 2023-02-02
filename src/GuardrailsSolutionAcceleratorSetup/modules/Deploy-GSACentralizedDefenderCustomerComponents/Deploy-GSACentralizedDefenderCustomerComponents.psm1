
Function Deploy-GSACentralizedDefenderCustomerComponents {
    param (
        # config
        [Parameter(mandatory = $true)]
        [psobject]
        $config
    )
    $ErrorActionPreference = 'Stop'

    Write-Verbose "Initiating deployment of components Lighthouse delegation of access to Defender for Cloud"
    $lighthouseBicepPath = "$PSScriptRoot/../../../../setup/lighthouse/"

    #build parameter object for subscription Defender for Cloud access delegation
    $bicepParams = @{
        'managedByTenantId'       = $config.lighthouseServiceProviderTenantID
        'location'                = $config.region
        'managedByName'           = 'SSC CSPM - Defender for Cloud Access'
        'managedByDescription'    = 'SSC CSPM - Defender for Cloud Access'
        'managedByAuthorizations' = @(
            @{
                'principalIdDisplayName' = $config.lighthousePrincipalDisplayName
                'principalId'            = $config.lighthousePrincipalId
                'roleDefinitionId'       = '91c1777a-f3dc-4fae-b103-61d183457e46' # Managed Services Registration assignment Delete Role
            }
            @{
                'principalIdDisplayName' = $config.lighthousePrincipalDisplayName
                'principalId'            = $config.lighthousePrincipalId
                'roleDefinitionId'       = '39bc4728-0917-49c7-9d2c-d95423bc2eb4' # Security Reader
            }
        )
    }

    #deploy a custom role definition at the lighthouseTargetManagementGroupID, which will later be used to grant the Automation Account MSI permissions to register the Lighthouse Resource Provider
    try {
        $roleDefinitionDeployment = New-AzManagementGroupDeployment -ManagementGroupId $config.lighthouseTargetManagementGroupID `
            -Location $config.region `
            -TemplateFile $lighthouseBicepPath/lighthouse_registerRPRole.bicep `
            -Confirm:$false `
            -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to deploy lighthouse resource provider registration custom role template with error: $_"
        break
    }
    $lighthouseRegisterRPRoleDefinitionID = $roleDefinitionDeployment.Outputs.roleDefinitionId.value

    #deploy Guardrails Defender for Cloud permission delegation - this delegation adds a role assignment to every subscription under the target management group
    try {
        $policyDeployment = New-AzManagementGroupDeployment -ManagementGroupId $config.lighthouseTargetManagementGroupID `
            -Location $config.region `
            -TemplateFile $lighthouseBicepPath/lighthouseDfCPolicy.bicep `
            -TemplateParameterObject $bicepParams `
            -Confirm:$false `
            -ErrorAction Stop
    }
    catch {
        If ($_.Exception.message -like "*Status Message: Principal * does not exist in the directory *. Check that you have the correct principal ID.*") {
            Write-Warning "Deployment role assignment failed due to AAD replication delay, attempting to proceed with role assignment anyway..."
        }
        Else {
            Write-Error "Failed to deploy Lighthouse Defender for Cloud delegation by Azure Policy template with error: $_"
            break
        }
    }

    ### wait up to 5 minutes to ensure AAD has time to propagate MSI identities before assigning a roles ###
    $i = 0
    do {
        Write-Verbose "Waiting for Policy assignment MSI to be available..."
        Start-Sleep 5

        $i++
        If ($i -gt '60') {
            Write-Error "[$i/60]Timeout while waiting for MSI '$($policyDeployment.Outputs.policyAssignmentMSIRoleAssignmentID.value)' to exist in Azure AD"
            break
        }
    }
    until ((Get-AzADServicePrincipal -id $policyDeployment.Outputs.policyAssignmentMSIRoleAssignmentID.value -ErrorAction SilentlyContinue))

    # deploy an 'Owner' role assignment for the MSI associated with the Policy Assignment created in the previous step
    # Owner rights are required so that the MSI can then assign the requested 'Security Reader' role on each subscription under the target management group
    try {
        $null = New-AzManagementGroupDeployment -ManagementGroupId $config.lighthouseTargetManagementGroupID `
            -Location $config.region `
            -TemplateFile $lighthouseBicepPath/lighthouseDfCPolicyRoleAssignment.bicep `
            -TemplateParameterObject @{policyAssignmentMSIPrincipalID = $policyDeployment.Outputs.policyAssignmentMSIRoleAssignmentID.value } `
            -Confirm:$false `
            -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to deploy template granting the Defender for Cloud delegation policy rights to configure role assignments with error: $_"
        break   
    } 

    # deploy a custom role assignment, granting the Automation Account MSI permissions to register the Lighthouse resource provider on each subscription under the target management group
    try {
        $null = New-AzManagementGroupDeployment -ManagementGroupId $config.lighthouseTargetManagementGroupID `
            -Location $config.region `
            -TemplateFile $lighthouseBicepPath/lighthouse_assignRPRole.bicep `
            -TemplateParameterObject @{lighthouseRegisterRPRoleDefinitionID = $lighthouseRegisterRPRoleDefinitionID; guardrailsAutomationAccountMSI = $config.guardrailsAutomationAccountMSI } `
            -Confirm:$false `
            -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to deploy template granting the Azure Automation account rights to register the Lighthouse resource provider with error: $_"
        break   
    } 

    ### TO DO ### The remediation task created by the Bicep template should be all that is required, but does not seem to execute
    try {
        $ErrorActionPreference = 'Stop'
        $null = Start-AzPolicyRemediation -Name Redemdiation -ManagementGroupName $config.lighthouseTargetManagementGroupID -PolicyAssignmentId $policyDeployment.Outputs.policyAssignmentId.value
    }
    catch {
        Write-Error "Failed to create Remediation Task for policy assignment '$($policyDeployment.Outputs.policyAssignmentId.value)' with the following error: $_"
    }

    Write-Verbose "Completing deployment of components Lighthouse delegation of access to Defender for Cloud"
}
# SIG # Begin signature block
# MIInygYJKoZIhvcNAQcCoIInuzCCJ7cCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCC5wF2HDNGKh7K
# qVcPnSCh++wq3ogVuOU/QMBFo3zNyqCCDYEwggX/MIID56ADAgECAhMzAAACzI61
# lqa90clOAAAAAALMMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAxWhcNMjMwNTExMjA0NjAxWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCiTbHs68bADvNud97NzcdP0zh0mRr4VpDv68KobjQFybVAuVgiINf9aG2zQtWK
# No6+2X2Ix65KGcBXuZyEi0oBUAAGnIe5O5q/Y0Ij0WwDyMWaVad2Te4r1Eic3HWH
# UfiiNjF0ETHKg3qa7DCyUqwsR9q5SaXuHlYCwM+m59Nl3jKnYnKLLfzhl13wImV9
# DF8N76ANkRyK6BYoc9I6hHF2MCTQYWbQ4fXgzKhgzj4zeabWgfu+ZJCiFLkogvc0
# RVb0x3DtyxMbl/3e45Eu+sn/x6EVwbJZVvtQYcmdGF1yAYht+JnNmWwAxL8MgHMz
# xEcoY1Q1JtstiY3+u3ulGMvhAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUiLhHjTKWzIqVIp+sM2rOHH11rfQw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDcwNTI5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAeA8D
# sOAHS53MTIHYu8bbXrO6yQtRD6JfyMWeXaLu3Nc8PDnFc1efYq/F3MGx/aiwNbcs
# J2MU7BKNWTP5JQVBA2GNIeR3mScXqnOsv1XqXPvZeISDVWLaBQzceItdIwgo6B13
# vxlkkSYMvB0Dr3Yw7/W9U4Wk5K/RDOnIGvmKqKi3AwyxlV1mpefy729FKaWT7edB
# d3I4+hldMY8sdfDPjWRtJzjMjXZs41OUOwtHccPazjjC7KndzvZHx/0VWL8n0NT/
# 404vftnXKifMZkS4p2sB3oK+6kCcsyWsgS/3eYGw1Fe4MOnin1RhgrW1rHPODJTG
# AUOmW4wc3Q6KKr2zve7sMDZe9tfylonPwhk971rX8qGw6LkrGFv31IJeJSe/aUbG
# dUDPkbrABbVvPElgoj5eP3REqx5jdfkQw7tOdWkhn0jDUh2uQen9Atj3RkJyHuR0
# GUsJVMWFJdkIO/gFwzoOGlHNsmxvpANV86/1qgb1oZXdrURpzJp53MsDaBY/pxOc
# J0Cvg6uWs3kQWgKk5aBzvsX95BzdItHTpVMtVPW4q41XEvbFmUP1n6oL5rdNdrTM
# j/HXMRk1KCksax1Vxo3qv+13cCsZAaQNaIAvt5LvkshZkDZIP//0Hnq7NnWeYR3z
# 4oFiw9N2n3bb9baQWuWPswG0Dq9YT9kb+Cs4qIIwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZnzCCGZsCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgvxgzbWvW
# ZiFxL5CQdko4l7ILYtuMzWP19pDl96zeKN4wQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQAlgNRW69KVqc//ZBZsW/URPsW7BiU10XgK/HKb/NaB
# Z2LIe2h+CXR8HBNM4wAU17J3BQEASlR6ArGGScGDlUmeGj2KJBWSfUcEVwNEV/Qz
# qL2m6JMw9ZFsZn3cqTdAWf7nRY+XyOEnAlmLRVfLn1u+WR3oUwtDTy1GPRmPFidY
# HX3hwQGu7ucYfkvhSVBUsUu+JqFjI0wxnLp3UiFzHbntEZnCunX9zbB+8e7UwIEV
# dSQrW2fhFagw1itPJpg/Iq4qjnXyQxbSN1Yi715eoCM5hyH5EPKUgBzezJcE484o
# Y0G5icJQIb0DWeQbDMCSwDgrgRrttxY3oTkTPSJzAD4ToYIXKTCCFyUGCisGAQQB
# gjcDAwExghcVMIIXEQYJKoZIhvcNAQcCoIIXAjCCFv4CAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIDuN0F3h9WYrVcdiq6znMO5qEhYjA+5Oah4rcJ0k
# cwFsAgZjx91O30sYEzIwMjMwMjAyMTUwMTE5LjA3MVowBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046QTI0MC00QjgyLTEzMEUxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WgghF4MIIHJzCCBQ+gAwIBAgITMwAAAbgI1MG4eeBR
# SQABAAABuDANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMjA5MjAyMDIyMTZaFw0yMzEyMTQyMDIyMTZaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkEyNDAtNEI4Mi0xMzBFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnBux/BEc
# RGfkL3lA8affu0nm86Jj1paN4gPGmBpdpgaKqzDQbRy8Irdi6Wup6YR/YKQZJ1w4
# kAX74SqE5Kqs7XecZyOrDqEU2ewbAoA3LN13Cc47SPPWV8Egi7vtNt82+dpZvBJG
# 7QNMYcDufs9HQxgn1sL8eilK2lsV/rTospxNafBpS4R0CHHoUCqDWuSC6CK65prE
# rLFGR2MVksoVcRcv2nTU+3BLR8bq9mJFWcQqB5qXZN4u90AipqkHCW09iJ+Cqent
# nhUkxw+jRNaZE1UU5wdE3BYd6E33GDq6AgZc+juEylas+CDiagc7Z6lzRPfquCb2
# GUOuXbxsblNqSZXs0n3yRsXmWC2WujBPp5zARW24t3hrSDNiqFqdbvNoVmcN+3nI
# x7HLn2J8RN3OnACuPackDIiyKrU9jdc+baZQwuUAKSyp6Ucp9aKEr8V6HD+bOKi8
# FXCSSv8bQXX05aBH4wFQqJ/Ck7JCIsDGuq9Wd8JjhCMkJmIci5LXkcJD9Mi39CPj
# HVa9FrVSqOeaku7j/IFhZmx29mirxJcjuI6zua55wAl4SRiUzqI6QyKCHMSGNAr1
# OE+mgC2W5dsvuogcat8WUeZf/iyhzuOPWPy4HfVTfiAmUHZemGMxpP4T471IiaT/
# oZFX1KbwLzwWeabZV3AyW4I0BTM8WN+8fHcCAwEAAaOCAUkwggFFMB0GA1UdDgQW
# BBTE/UclN4XDM1ijWeN+5xe5R9BpbjAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAx
# MCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3Rh
# bXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEA
# n26TyaLCkygrDcP33qmITNt6AAbGQAEdifa8/aFuqeRL1T3uz/pCXJk6EYWxW51q
# It5FllOxobmFHSgK4Eg1n+V6WjnHMdz6YE6kFenFJpbWGqjFoIuxUfUQG3PuKfbk
# ePL56O4FyKUfoRnRm03GZYYhDPxHQC5LROPhWAlcciVc/11U6LIaj1V6WuT4UbH8
# EL6IS4Jop38izKkc+IJQKHnYMZz3WzZLuV1DHUfgKWM4C1qcN9u9J6MBJYuj+zfD
# RcwBsO6tY2ezReJ0AXZGcvU9rGg7LP1VhqQ0YrgXf+4lFmdWBuwJi7A1fUGZLAzV
# ls9KeCA1IZNnH8VDbQmP+6WsrSvIBu81s1viSRpLhrvruJ8Kq9Q4UuVRPw83jeGG
# V3EjrIc8w5Yi0mkQchkGJM0puUGxhsiuCFvVib219KwtrlkkPNVk2d1F+FSok7Jc
# X4JWb061WYUMb2QjAzpABfxDSJ/vbXPhU7Nk28PyS2DWUj5eNeBcMlWzeHjuwy70
# ZdJjOTL7t22CZzeJE+R1rdhVF2Y8m00U3Q0vJtyywTu+EUKKPvl4MZAEWrQDgpUb
# q4F2vpRNbATRUofEHPYGka+fsEKz7nLGcX4dXoJSJyQOqo+L8gjtmyx30Rs/27OP
# iW6V1cMA+tYa10ar7ArSh2UY1W4IzGwveGfz4qI71SIwggdxMIIFWaADAgECAhMz
# AAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9v
# dCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0z
# MDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP9
# 7pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMM
# tY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gm
# U3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130
# /o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP
# 3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7
# vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+A
# utuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz
# 1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6
# EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/Zc
# UlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZy
# acaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJ
# KwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVd
# AF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8G
# CCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3Mv
# UmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQC
# BAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
# VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZF
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcw
# AoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJB
# dXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cB
# MSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7
# bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/
# SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2
# EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2Fz
# Lixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0
# /fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9
# swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJ
# Xk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+
# pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW
# 4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N
# 7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIC1DCCAj0CAQEwggEAoYHYpIHVMIHSMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNy
# b3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxl
# cyBUU1MgRVNOOkEyNDAtNEI4Mi0xMzBFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQBwa15WoXH8htMpcct65cI9
# E8wPu6CBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqG
# SIb3DQEBBQUAAgUA54Yh5TAiGA8yMDIzMDIwMjE5NDk1N1oYDzIwMjMwMjAzMTk0
# OTU3WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDnhiHlAgEAMAcCAQACAgWLMAcC
# AQACAhE1MAoCBQDnh3NlAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkK
# AwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAbK3y
# BgwsT2crtK4+HAFOi2LN0AsxX9YGbUKqPSZ6gY3r0oDV9+sbcO/dPXsRSQWnHip/
# x5nVNnEU97KM3MalWhYqJfrDmBvgmwt8fE/o6wGSsh8sZEtXOxI+6O7GyePWvIkE
# gn94Yvw+xzxigqa3Q4XgECWxD5qP1efr9rydbOUxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAbgI1MG4eeBRSQABAAABuDAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCBA9aTAd0uu5ekzcu/T8xO3DlSM4TGdGq7sZjuxT8sSdzCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EICjr1jigcDtDilL5jU2wF+ukhhN5
# aw94ZNqaLRfQ8PsfMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAG4CNTBuHngUUkAAQAAAbgwIgQgmDEbMlz53Lue8WD1vRq8zEFzHd7X
# G/sUZQZ1Ck3i70IwDQYJKoZIhvcNAQELBQAEggIAfHpY8YPMxWtPC1m2xyixaTwQ
# o5AZ0hg7sbqFU3xe0lDgt/6C6eXNytIn2UNOnT8DEiBmB9NSyJNFvSiRRNmD8xPJ
# HF1cpXwoElJyyPfzW5WKPBX1u2fOiPoJdYqfLe+MFs9BO8SWIveJx6oACQzRT29/
# 9KhwJAWbDGwGReW/by0M6QzjVoRjg0+zSy74roFN+9ydsrmqolve1ucTldC7HfjO
# 70HKPWVqpqSZPQnQLUOuVK6x+nCQzsqbDQqDj+koa6XFP/tZwlwCcS3nIdoDR5Ps
# Oj/2Q0gdBZVO6Jf8dn4gQOa0tFPJUmXlfKdKoe2QD5vJK0KLMcT5UYkKxruxmkKx
# winf0HPZ7lAQD/prgFuZThRUKxyOvX3w8tX6pn6vhs1dBINt2vxmufsdAgldDokP
# JS7oiYJih54qBZKKtLm+UnF67H/2YcJ52kWiiWwT7XoSJxpfkGoL6oHmt7ZS0NDT
# MEmCz2nYsksfv3CvIVfkiLP4XxNSQ1mBfiM0fbduOylgyJKwsBJqq1ABP7EnLdiK
# EDqzwNxlDl0CRrKsp7wiCymroazqtCTlUntfM6xJLEBtjymtoYu+k80JPdw/H4pM
# qW/LczMLmMQpobyA6s1q65lzuyJz1KbubdY+zoFq7ieH7TSUE3Gh36V88tFi0lRS
# 7avbM2eyFVOK1lw9N7g=
# SIG # End signature block
