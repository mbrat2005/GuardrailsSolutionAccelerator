<#
.SYNOPSIS
   The module will look for a P2 equivalent licensing assigned to the BG accounts.


.DESCRIPTION
    The module will look for the AAD_PREMIUM_P2 service plan in all of the licences assigned to the user, once it finds "AAD_PREMIUM_P2", the check mark status will be changed from (❌) to (✔️).



.PARAMETER Name
        token : auth token 
        FirstBreakGlassUPN: UPN for the first Break Glass account 
        SecondBreakGlassUPN: UPN for the second Break Glass account
        ControlName :-  GUARDRAIL 1 PROTECT ROOT  GLOBAL ADMINS ACCOUNT
        ItemName, 
        WorkSpaceID : Workspace ID to ingest the logs 
        WorkSpaceKey: Workspace Key for the Workdspace 
        LogType: GuardrailsCompliance, it will show in log Analytics search as GuardrailsCompliance_CL
#>
function Get-BreakGlassAccountLicense {
    param (
        [string] $FirstBreakGlassUPN,
        [string] $SecondBreakGlassUPN, 
        [string] $ControlName, 
        [string] $ItemName, 
        [string] $itsgcode,
        [hashtable] $msgTable,      
        [Parameter(Mandatory = $true)]
        [string]
        $ReportTime
    )
    [bool] $IsCompliant = $false
    [string] $Comments = $null

    [PSCustomObject] $BGAccounts = New-Object System.Collections.ArrayList
    [PSCustomObject] $ErrorList = New-Object System.Collections.ArrayList
     
    $FirstBreakGlassAcct = [PSCustomObject]@{
        UserPrincipalName = $FirstBreakGlassUPN
        ID                = $null
        LicenseAADP2Found = $false
    }
    $SecondBreakGlassAcct = [PSCustomObject]@{
        UserPrincipalName = $SecondBreakGlassUPN
        ID                = $null
        LicenseAADP2Found = $false
    }
    $BGAccounts.add( $FirstBreakGlassAcct) | Out-Null
    $BGAccounts.add( $SecondBreakGlassAcct) | Out-Null

    foreach ($BGAccount in $BGAccounts) {
        
        $urlPath = '/users/' + $BGAccount.UserPrincipalName

        try {
            $response = Invoke-GraphQuery -urlPath $urlPath -ErrorAction Stop
        }
        catch {
            $ErrorList.Add("Failed to call Microsoft Graph REST API at URL '$urlPath'; returned error message: $_")
            Write-Error "Error: Failed to call Microsoft Graph REST API at URL '$urlPath'; returned error message: $_"
        }
        $data = $response.Content
        $BGAccount.ID = $data.id

        # if BGA account exists, check for license details
        If ($BGAccount.ID) {
            $urlPath = '/users/' + $BGAccount.UserPrincipalName + '/licenseDetails'

            try {
                $response = Invoke-GraphQuery -urlPath $urlPath -ErrorAction Stop
            }
            catch {
                If ($response.statusCode -eq 404) { continue }
                $ErrorList.Add("Failed to call Microsoft Graph REST API at URL '$urlPath'; returned error message: $_")
                Write-Error "Error: Failed to call Microsoft Graph REST API at URL '$urlPath'; returned error message: $_"
            }

            $data = $response.Content

            # A user can have multiple licences, so we need to look for all license sku that have AAD_PREMIUM_P2 in the service plans included
            # https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference
            if (($data.value).Length -gt 0 ) {
                $BGAccount.LicenseAADP2Found = $data.value.servicePlans.ServicePlanName -contains 'AAD_PREMIUM_P2'
            }
        }
    }
    if (($FirstBreakGlassAcct.LicenseAADP2Found) -and ($SecondBreakGlassAcct.LicenseAADP2Found)) {
        $IsCompliant = $true
        $Comments = $msgTable.firstBgAccount + ' ' + $msgTable.bgValidLicenseAssigned + " & " +
        $msgTable.secondBgAccount + ' ' + $msgTable.bgValidLicenseAssigned 
    }
    else {
        if (!$FirstBreakGlassAcct.LicenseAADP2Found) {
            $Comments = $msgTable.bgNoValidLicenseAssigned + ' ' + $msgTable.firstBgAccount
        }
        if (!$SecondBreakGlassAcct.LicenseAADP2Found) {
            $Comments += ' ' + $msgTable.bgNoValidLicenseAssigned + ' ' + $msgTable.secondBgAccount
        }
    }

    $PsObject = [PSCustomObject]@{
        ComplianceStatus = $IsCompliant
        ControlName      = $ControlName
        Comments         = $Comments
        ItemName         = $ItemName
        ReportTime       = $ReportTime
        itsgcode         = $itsgcode
    }
    $moduleOutput = [PSCustomObject]@{ 
        ComplianceResults = $PsObject
        Errors            = $ErrorList
        AdditionalResults = $AdditionalResults
    }
    return $moduleOutput
}


# SIG # Begin signature block
# MIInqgYJKoZIhvcNAQcCoIInmzCCJ5cCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDZoUBTyIFjZ4SB
# jxifmATFhgx2ZpTzniO+CxoapvfGG6CCDYEwggX/MIID56ADAgECAhMzAAACzI61
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZfzCCGXsCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgHUtlI0Ky
# IleKBfJJwSkmBCxVmS28EubDc9NkjjvJKhgwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQBej+2Wph1T8opIjP9jh0RZKa9vXuRthASLxCh18/Gj
# xNxVpZ/IZB+BGVQsMflgMMWolhpxeUVnbqZtLKQ3yKkoiza9v0n3XviW9TeIlMpL
# p3F7HvkQQ+/HIE3cHqhOUMnF58npHhyVc3HACpCiCw4aZuavf4J4Ne36UlU0e4Ht
# T6mtId826dyXUFNRa9/ioblJgcKW5UVVGNMzyk/8SAQka2K1pI90GvHGEwxAC+i/
# ewthihT3PyUwCsYT11bdGaeUHnPlvpjc67pkzz9zbJDTkheONxVBUJ6cIObiQuUu
# JPhYnNstGLpx8tjsuAUBn+kTrJhHMUIVqnm+N9blXLqWoYIXCTCCFwUGCisGAQQB
# gjcDAwExghb1MIIW8QYJKoZIhvcNAQcCoIIW4jCCFt4CAQMxDzANBglghkgBZQME
# AgEFADCCAVUGCyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIAuq5YFuJsMwe27GPIL7z8vBOwKAtSu74wOE7LSt
# iDrfAgZjxoxkCt4YEzIwMjMwMjA2MTUwOTIyLjI2NlowBIACAfSggdSkgdEwgc4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1p
# Y3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjpDNEJELUUzN0YtNUZGQzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEVwwggcQMIIE+KADAgECAhMzAAABo/uas457hkNPAAEA
# AAGjMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIyMDMwMjE4NTExNloXDTIzMDUxMTE4NTExNlowgc4xCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVy
# YXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpDNEJE
# LUUzN0YtNUZGQzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vydmlj
# ZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAO+9TcrLeyoKcCqLbNtz
# 7Nt2JbP1TEzzMhi84gS6YLI7CF6dVSA5I1bFCHcw6ZF2eF8Qiaf0o2XSXf/jp5sg
# mUYtMbGi4neAtWSNK5yht4iyQhBxn0TIQqF+NisiBxW+ehMYWEbFI+7cSdX/dWw+
# /Y8/Mu9uq3XCK5P2G+ZibVwOVH95+IiTGnmocxWgds0qlBpa1rYg3bl8XVe5L2qT
# UmJBvnQpx2bUru70lt2/HoU5bBbLKAhCPpxy4nmsrdOR3Gv4UbfAmtpQntP758NR
# Phg1bACH06FlvbIyP8/uRs3x2323daaGpJQYQoZpABg62rFDTJ4+e06tt+xbfvp8
# M9lo8a1agfxZQ1pIT1VnJdaO98gWMiMW65deFUiUR+WngQVfv2gLsv6o7+Ocpzy6
# RHZIm6WEGZ9LBt571NfCsx5z0Ilvr6SzN0QbaWJTLIWbXwbUVKYebrXEVFMyhuVG
# QHesZB+VwV386hYonMxs0jvM8GpOcx0xLyym42XA99VSpsuivTJg4o8a1ACJbTBV
# FoEA3VrFSYzOdQ6vzXxrxw6i/T138m+XF+yKtAEnhp+UeAMhlw7jP99EAlgGUl0K
# kcBjTYTz+jEyPgKadrU1of5oFi/q9YDlrVv9H4JsVe8GHMOkPTNoB4028j88OEe4
# 26BsfcXLki0phPp7irW0AbRdAgMBAAGjggE2MIIBMjAdBgNVHQ4EFgQUUFH7szwm
# CLHPTS9Bo2irLnJji6owHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIw
# XwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3Js
# MGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
# JTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcD
# CDANBgkqhkiG9w0BAQsFAAOCAgEAWvLep2mXw6iuBxGu0PsstmXI5gLmgPkTKQnj
# gZlsoeipsta9oku0MTVxlHVdcdBbFcVHMLRRkUFIkfKnaclyl5eyj03weD6b/pUf
# FyDZB8AZpGUXhTYLNR8PepM6yD6g+0E1nH0MhOGoE6XFufkbn6eIdNTGuWwBeEr2
# DNiGhDGlwaUH5ELz3htuyMyWKAgYF28C4iyyhYdvlG9VN6JnC4mc/EIt50BCHp8Z
# QAk7HC3ROltg1gu5NjGaSVdisai5OJWf6e5sYQdDBNYKXJdiHei1N7K+L5s1vV+C
# 6d3TsF9+ANpioBDAOGnFSYt4P+utW11i37iLLLb926pCL4Ly++GU0wlzYfn7n22R
# yQmvD11oyiZHhmRssDBqsA+nvCVtfnH183Df5oBBVskzZcJTUjCxaagDK7AqB6QA
# 3H7l/2SFeeqfX/Dtdle4B+vPV4lq1CCs0A1LB9lmzS0vxoRDusY80DQi10K3SfZK
# 1hyyaj9a8pbZG0BsBp2Nwc4xtODEeBTWoAzF9ko4V6d09uFFpJrLoV+e8cJU/hT3
# +SlW7dnr5dtYvziHTpZuuRv4KU6F3OQzNpHf7cBLpWKRXRjGYdVnAGb8NzW6wWTj
# ZjMCNdCFG7pkKLMOGdqPDFdfk+EYE5RSG9yxS76cPfXqRKVtJZScIF64ejnXbFIs
# 5bh8KwEwggdxMIIFWaADAgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3
# DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw
# MAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAx
# MDAeFw0yMTA5MzAxODIyMjVaFw0zMDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFBDQSAyMDEwMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
# 5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/
# XE/HZveVU3Fa4n5KWv64NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1
# hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7
# M62AW36MEBydUv626GIl3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3K
# Ni1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy
# 1cCGMFxPLOJiss254o2I5JasAUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF80
# 3RKJ1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQc
# NIIP8BDyt0cY7afomXw/TNuvXsLz1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahha
# YQFzymeiXtcodgLiMxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkL
# iWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV
# 2xo3xwgVGD94q0W29R6HXtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIG
# CSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUp
# zxD/LwTuMB0GA1UdDgQWBBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBT
# MFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYI
# KwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGG
# MA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186a
# GMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3Br
# aS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsG
# AQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcN
# AQELBQADggIBAJ1VffwqreEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1
# OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYA
# A7AFvonoaeC6Ce5732pvvinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbz
# aN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6L
# GYnn8AtqgcKBGUIZUnWKNsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3m
# Sj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0
# SCyxTkctwRQEcb9k+SS+c23Kjgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxko
# JLo4S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFm
# PWn9y8FBSX5+k77L+DvktxW/tM4+pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC482
# 2rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7
# vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJtpQUQwXEGahC0HVUzWLOhcGbyoYICzzCC
# AjgCAQEwgfyhgdSkgdEwgc4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNv
# MSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpDNEJELUUzN0YtNUZGQzElMCMGA1UE
# AxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUA
# Hl/pXkLMAbPapCwa+GXc3SlDDROggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIFAOeLZ7kwIhgPMjAyMzAyMDYxNTQ5
# MTNaGA8yMDIzMDIwNzE1NDkxM1owdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA54tn
# uQIBADAHAgEAAgIafzAHAgEAAgISSTAKAgUA54y5OQIBADA2BgorBgEEAYRZCgQC
# MSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqG
# SIb3DQEBBQUAA4GBAA760/O0SGBvPwULkFPxPjQd7Kcko6aEG9OZg8wBFEmj1n7b
# /7vLw7Y2PS6iPIVsk4so8pyaVKMwoc8jmIEAsl6DWrNm+eXHIx5KYqVla25Wmsqp
# jX9A/jYfeUEtTGI85Z6AhiUMXVfiAbjSJxT+mtZEj2vU9U5U8Kl4KkAPUqwCMYIE
# DTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGj
# +5qzjnuGQ08AAQAAAaMwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzEN
# BgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgwidrbUO4Z4PS1d/piZzY9D0T
# b2oHrt4x9jnDTD5g1NkwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCCM+Liw
# BnHMMoOd/sgbaYxpwvEJlREZl/pTPklz6euN/jCBmDCBgKR+MHwxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABo/uas457hkNPAAEAAAGjMCIEIKHaSnbq
# CCANYijEilJ1AoZz0Vmx1INIVR3wMzxkkXHxMA0GCSqGSIb3DQEBCwUABIICAFY1
# du7nQnSMmJLoXlFC0+ShLfKSOjw9aZr9H7iYawEpe0qhkqZVxmnx65oyCivSmCoI
# c84mYrrSOejz9YU+o0O5GCtEK07iar8hHzxSazUOsA8E8tbjq1vFwYYbhZyfQYLY
# r8CJQw8B64jFbDz1zawYcpyO08yyHeao6mPMerE/VrJyXbP9NY1KVdfvxYgpBqwc
# g67mpJ9QvlblYe2NIqCOhlLHMFKtB9HtsPMW9qOAnvXwitAwQ/tucSi4sKAylUSG
# d9XVuVgWT9pn0LrzAWYz3r49WdeFfTxnf6Dtfrz961SXxIfq89a461yNW6vLJEX2
# krIfX08p3Y1w3l33jOr+eDiWlsVj8m1fw9GYkKmo+5Rz6hpOV1XIoGGfehNolpUM
# o8wCSb4b9TcZRtspRZ0pBco/Lmjo7uhWRciXSclpo3hHZvuPjmAuCt6xj9eUuBFx
# /TjK2vJdq6FcQq4cWhRXE1fvRwUV0PHTwKn8c+ToZZTBxOBF0uQUijKJj2Jw024w
# NDcM665iMtTOLG1MTRNpuAbf63ToedhAO5oGuJjtLvy8c91j98d8KytesVCjUR9O
# 0df9yeZGbE2+4zaHxxFeC5auxcBLAr0vMLdRpeLXGayq3r8vcYVYvSpBLplBYuG0
# ILW0og7j27bZ1U3jOwqA31sfiZrDOQD9amqIQpbH
# SIG # End signature block
