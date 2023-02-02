<#
.SYNOPSIS
    
.DESCRIPTION
    
.NOTES
    
.LINK
    
.EXAMPLE

#>

Function Remove-GSACentralizedDefenderCustomerComponents {
    param (
        [Parameter(mandatory = $true, parameterSetName = 'hashtable', ValueFromPipelineByPropertyName = $true)]
        [string]
        $configString,

        [Parameter(mandatory = $true, ParameterSetName = 'configFile')]
        [string]
        [Alias(
            'configFileName'
        )]
        $configFilePath,

        # Parameter help description
        [Parameter(Mandatory = $true, parameterSetname = 'manualParams')]
        [string]
        $lighthouseTargetManagementGroupID,

        # force removal of resources
        [Parameter(Mandatory = $false)]
        [switch]
        $force,

        # wait for removal of resources
        [Parameter(Mandatory = $false)]
        [switch]
        $wait
    )
    $ErrorActionPreference = 'Stop'
    
    Import-Module ((Split-Path $PSScriptRoot -Parent) + "\Deploy-GuardrailsSolutionAccelerator\Deploy-GuardrailsSolutionAccelerator.psd1") -Function 'Confirm-GSASubscriptionSelection', 'Confirm-GSAConfigurationParameters'

    If ($configString) {
        If (Test-Json -Json $configString) {
            $config = ConvertFrom-Json -InputObject $configString
        }
        Else {
            Write-Error -Message "The config parameter (or value from the pipeline) is not valid JSON. Please ensure that the config parameter is a valid JSON string or a path to a valid JSON file." -ErrorAction Stop
        }
    }
    ElseIf ($configFilePath) {
        $config = Confirm-GSAConfigurationParameters -configFilePath $configFilePath
    }

    If (!$lighthouseTargetManagementGroupID) {
        $lighthouseTargetManagementGroupID = $config.lighthouseTargetManagementGroupID
    }

    If (!$force.IsPresent) {
        Write-Warning "This action will delete the role definitions and assignments associated with granting managing tenant access to Defender for Cloud in this tenant at management group '$lighthouseTargetManagementGroupID'. `n`nIf you are not certain you want to perform this action, press CTRL+C to cancel; otherwise, press ENTER to continue."
        Read-Host
    }

$lighthouseTargetManagementGroupID = 'mb_co'
If ($lighthouseTargetManagementGroupID -eq (Get-AzContext).Tenant.Id) {
    $assignmentScopeMgmtmGroupId = '/'
}
Else {
    $assignmentScopeMgmtmGroupId = $lighthouseTargetManagementGroupID
}

# check if a lighthouse defender for cloud policy MSI role assignment already exists - assignment name always 2cb8e1b1-fcf1-439e-bab7-b1b8b008c294 
Write-Verbose "Checking for role assignments at management group '$assignmentScopeMgmtmGroupId' for role 'Owner'"
$uri = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Authorization/roleAssignments/{1}?&api-version=2018-01-01-preview' -f $lighthouseTargetManagementGroupID, '2cb8e1b1-fcf1-439e-bab7-b1b8b008c294'
$response = Invoke-AzRestMethod -Uri $uri -Method GET -Verbose 

If ($response.StatusCode -notin 200, 404) {
    Write-Error "Error checking for role assignments at management group '$assignmentScopeMgmtmGroupId' for role 'Owner'. Status code: $($response.StatusCode). Response: $($response.Content)"
    Return
}

$roleAssignments = $response | Select-Object -Expand Content | ConvertFrom-Json
If ($roleAssignments.id) {
    Write-Verbose "Deleteing role assignments '$roleAssignments'"
    $uri = 'https://management.azure.com/{0}?api-version=2015-07-01' -f $roleAssignments.id
    $response = Invoke-AzRestMethod -Uri $uri -Method DELETE -Verbose

    If ($response.StatusCode -in 200, 202, 204) {
        Write-Verbose "Role assignment deleted successfully"
    }
    Else {
        Write-Error "Error deleting role assignment: $response"
    }
}
Else {
    Write-Verbose "No DfC role assignments found..."
}

      
# check if a lighthouse Azure Automation MSI role assignment to register the Lighthouse resource provider already exists - assignment name always  5de3f84b-8866-4432-8811-24859ccf8146
Write-Verbose "Checking for role assignments at management group '$assignmentScopeMgmtmGroupId' for role 'Custom-RegisterLighthouseResourceProvider'"
$uri = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Authorization/roleAssignments/{1}?&api-version=2018-01-01-preview' -f $lighthouseTargetManagementGroupID, '5de3f84b-8866-4432-8811-24859ccf8146'
$response = Invoke-AzRestMethod -Uri $uri -Method GET 

If ($response.StatusCode -notin 200, 404) {
    Write-Error "Error checking for role assignments at management group '$assignmentScopeMgmtmGroupId' for role 'Custom-RegisterLighthouseResourceProvider'. Status code: $($response.StatusCode). Response: $($response.Content)"
    Return
}
      
$roleAssignments = $response | Select-Object -Expand Content | ConvertFrom-Json   

If ($roleAssignments.id) { 
    Write-Verbose "Deleteing role assignments '$roleAssignments'"
    $uri = 'https://management.azure.com/{0}?api-version=2015-07-01' -f $roleAssignments.id
    $response = Invoke-AzRestMethod -Uri $uri -Method DELETE -verbose

    If ($response.StatusCode -in 200, 202, 204) {
        Write-Verbose "Role assignment deleted successfully"
    }
    Else {
        Write-Error "Error deleting role assignment: $response"
    }
}
else {
    Write-Verbose "No MSI role assignemnts found"
}

# check if lighthouse Custom-RegisterLighthouseResourceProvider exists at a different scope
Write-Verbose "Checking for existing role definitions with name 'Custom-RegisterLighthouseResourceProvider'"
$uri = "https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Authorization/roleDefinitions?`$filter=roleName eq '{1}'&api-version=2018-01-01-preview" -f $lighthouseTargetManagementGroupID, 'Custom-RegisterLighthouseResourceProvider'
$response = Invoke-AzRestMethod -Uri $uri -Method Get

If ($response.StatusCode -notin 200, 404) {
    Write-Error "Error checking for role definition 'Custom-RegisterLighthouseResourceProvider' at management group '$lighthouseTargetManagementGroupID'. Status code: $($response.StatusCode). Response: $($response.Content)"
    Return
}

$roleDefinition = $response.Content | ConvertFrom-Json
If ($roleDefId = $roleDefinition.Name) {
    $uri = 'https://management.azure.com/providers/Microsoft.Management/managementGroups/{0}/providers/Microsoft.Authorization/roleDefinitions/{1}?api-version=2018-01-01-preview' -f $lighthouseTargetManagementGroupID, $roleDefId

    $response = Invoke-AzRestMethod -Method DELETE -Uri $uri

    If ($response.StatusCode -notin 200, 202, 204) {
        Write-Error "Error deleting role definition '$roleDefId' at management group '$lighthouseTargetManagementGroupID'. Status code: $($response.StatusCode). Response: $($response.Content)"
        Return
    }
    Else {
        Write-Verbose "Role definition '$roleDefId' deleted successfully"
    }
}
Else {
    Write-Verbose "No role definition found with name 'Custom-RegisterLighthouseResourceProvider'"
}

Write-Host "Completed removing Lighthouse role assignments and role definitions for Defender for Cloud access" -ForegroundColor Green
}
# SIG # Begin signature block
# MIInzQYJKoZIhvcNAQcCoIInvjCCJ7oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAD+CGN9mO3hBE1
# a7KZnx27TeSBNfidNrB7az4etlc0zqCCDYEwggX/MIID56ADAgECAhMzAAACzI61
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZojCCGZ4CAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgCYzljHqq
# MmfsZjs+JClKc54QVWUSXiGqcKZHiaArYFAwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQAQKPifM3PxIjTsXId5YBGeq2TV1F2TGs0dhLnKZFX3
# cHpsqmbEzjLlLrofT2O1bUBChn1YQFnnV8Zt2/ypKUrLIUFNCI1THn9SnmM6IehI
# x1hLAl0vHzEGx7Xlhf1U2cFYCQlGhVdqrkmswbmwk5Qj3b3+Gbu73gOAml/X8xU4
# dI4ybCQnnxJCngY6xEmJpNwxJiTojAZ1oX0TF5Q5EB0iiYP+l03r6luCOnZ3lEqx
# DZ9Ohq0jzdRcrfUKCr8mEqRI2OJ2zQlsYN+UNvmsXUmKrUdAOCIzgWmyEEvZeREp
# jUSfl6tPTzsgN7ln8yAmP0i37SWXI4lNBx0MbbkxjdzyoYIXLDCCFygGCisGAQQB
# gjcDAwExghcYMIIXFAYJKoZIhvcNAQcCoIIXBTCCFwECAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIN0GQSGiIHBn0Po+DKGrAmd8A/5YYCYJPeZlvi6h
# qcNVAgZjx91C8YYYEzIwMjMwMjAyMTUwMTE5LjI5NVowBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RkM0MS00QkQ0LUQyMjAxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WgghF7MIIHJzCCBQ+gAwIBAgITMwAAAbn2AA1lVE+8
# AwABAAABuTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMjA5MjAyMDIyMTdaFw0yMzEyMTQyMDIyMTdaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkZDNDEtNEJENC1EMjIwMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA40k+yWH1
# FsfJAQJtQgg3EwXm5CTI3TtUhKEhNe5sulacA2AEIu8JwmXuj/Ycc5GexFyZIg0n
# +pyUCYsis6OdietuhwCeLGIwRcL5rWxnzirFha0RVjtVjDQsJzNj7zpT/yyGDGqx
# p7MqlauI85ylXVKHxKw7F/fTI7uO+V38gEDdPqUczalP8dGNaT+v27LHRDhq3HSa
# QtVhL3Lnn+hOUosTTSHv3ZL6Zpp0B3LdWBPB6LCgQ5cPvznC/eH5/Af/BNC0L2WE
# DGEw7in44/3zzxbGRuXoGpFZe53nhFPOqnZWv7J6fVDUDq6bIwHterSychgbkHUB
# xzhSAmU9D9mIySqDFA0UJZC/PQb2guBI8PwrLQCRfbY9wM5ug+41PhFx5Y9fRRVl
# Sxf0hSCztAXjUeJBLAR444cbKt9B2ZKyUBOtuYf/XwzlCuxMzkkg2Ny30bjbGo3x
# UX1nxY6IYyM1u+WlwSabKxiXlDKGsQOgWdBNTtsWsPclfR8h+7WxstZ4GpfBunhn
# zIAJO2mErZVvM6+Li9zREKZE3O9hBDY+Nns1pNcTga7e+CAAn6u3NRMB8mi285Kp
# wyA3AtlrVj4RP+VvRXKOtjAW4e2DRBbJCM/nfnQtOm/TzqnJVSHgDfD86zmFMYVm
# AV7lsLIyeljT0zTI90dpD/nqhhSxIhzIrJUCAwEAAaOCAUkwggFFMB0GA1UdDgQW
# BBS3sDhx21hDmgmMTVmqtKienjVEUjAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAx
# MCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3Rh
# bXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEA
# zdxns0VQdEywsrOOXusk8iS/ugn6z2SS63SFmJ/1ZK3rRLNgZQunXOZ0+pz7Dx4d
# OSGpfQYoKnZNOpLMFcGHAc6bz6nqFTE2UN7AYxlSiz3nZpNduUBPc4oGd9UEtDJR
# q+tKO4kZkBbfRw1jeuNUNSUYP5XKBAfJJoNq+IlBsrr/p9C9RQWioiTeV0Z+OcC2
# d5uxWWqHpZZqZVzkBl2lZHWNLM3+jEpipzUEbhLHGU+1x+sB0HP9xThvFVeoAB/T
# Y1mxy8k2lGc4At/mRWjYe6klcKyT1PM/k81baxNLdObCEhCY/GvQTRSo6iNSsElQ
# 6FshMDFydJr8gyW4vUddG0tBkj7GzZ5G2485SwpRbvX/Vh6qxgIscu+7zZx4NVBC
# 8/sYcQSSnaQSOKh9uNgSsGjaIIRrHF5fhn0e8CADgyxCRufp7gQVB/Xew/4qfdeA
# wi8luosl4VxCNr5JR45e7lx+TF7QbNM2iN3IjDNoeWE5+VVFk2vF57cH7JnB3ckc
# Mi+/vW5Ij9IjPO31xTYbIdBWrEFKtG0pbpbxXDvOlW+hWwi/eWPGD7s2IZKVdfWz
# vNsE0MxSP06fM6Ucr/eas5TxgS5F/pHBqRblQJ4ZqbLkyIq7Zi7IqIYEK/g4aE+y
# 017sAuQQ6HwFfXa3ie25i76DD0vrII9jSNZhpC3MA/0wggdxMIIFWaADAgECAhMz
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
# 7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIC1zCCAkACAQEwggEAoYHYpIHVMIHSMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNy
# b3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxl
# cyBUU1MgRVNOOkZDNDEtNEJENC1EMjIwMSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDHYh4YeGTnwxCTPNJaScZw
# uN+BOqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqG
# SIb3DQEBBQUAAgUA54YhtjAiGA8yMDIzMDIwMjE5NDkxMFoYDzIwMjMwMjAzMTk0
# OTEwWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDnhiG2AgEAMAoCAQACAhLBAgH/
# MAcCAQACAhFPMAoCBQDnh3M2AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQB
# hFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEA
# Zo58Eyg3vwb0FTMv1vqporFceMk9Fn8R/r9HE+EI31lEiI2mpDDTdcaZ0durLYn4
# dfXNvmTxgim9oBJ5ZF1tyzpLlQd/tm1O7FmoMX/m45TRGoMEbNRFdYyAj89bRyBS
# 3L+ca3mMIlieu4gs0HC99w9X3DLdoDHXDs/PgnyffKgxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAbn2AA1lVE+8AwABAAAB
# uTANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCD/DTKaHyYBYa+M8c1sOpM14CUri9f5mgNNdPQ5ivRz
# DzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIGTrRs7xbzm5MB8lUQ7e9fZo
# tpAVyBwal3Cw6iL5+g/0MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAG59gANZVRPvAMAAQAAAbkwIgQgGZtAzWIsdL7/yvvUkymRLmbf
# BrDWQ169QDhNZFNrZDAwDQYJKoZIhvcNAQELBQAEggIAsiZxHCdENb45Vy5nv3ep
# fPp0DQ6IiKmPgGGiZ18xbpgtaR+lVqMF4UgPFG34A5Rwedw5sf3ytQyvsd6Y95ie
# eOd05Ym2Nr7n+PhcN+Bjr6lIl24BlOOh+Kjcith7YqDQdAy6nPYF8EvEPwH5qR33
# 7XC+XVEDqKq8HO++SJ6WqMgX+Hb0hjszqTtIzzlobdzbbg2GS2HNxY2Ut6XJ3JjE
# PPMtAYExP63q8gJ1Qdo5V+8Ucri3Pcp4q9/YRvDEYnrbMfEW3NN3najRgEXUTukA
# b4wm/GlT8bLBS5erHvNlk71+NV3L0cX9doFf9b+2V4t806DE096Wm1/Me1hoFUXf
# 8U4Hbrx47iz+WtxJ8LzNb8eVZa1EroU2dagqwaCD8oSHa0ZMOaTbqJ9GE1juzQah
# +Ldh119/ecKggnmtH46beX/FKLNKmHkfUPzUcKc5BaZ00xkEt6m/q0XRVdF9ZDV2
# 7CgCgit7IaYqDPEX+DxPM5QL1GjqxeuVXIgVotpQcyNYKApUcb1PWNU4/mQEdjo0
# pjASceZ9KZKv10nITOYyM1kfLtzddXy/iyj7ORE9IRj/wt7MXb3X5GNI8iSOsjeC
# imGAGDUyykxFIUugLFm7rGJTzDzMZqBQKu6nKPAD6SrpZRTKa5FrCGoo8ynLwNTL
# lFS+wOxI4tam41qux6ah/ws=
# SIG # End signature block
