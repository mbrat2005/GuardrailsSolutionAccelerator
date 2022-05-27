function Get-VNetComplianceInformation {
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $token,
        [Parameter(Mandatory=$true)]
        [string]
        $ControlName,
        [Parameter(Mandatory=$true)]
        [string]
        $WorkSpaceID,
        [Parameter(Mandatory=$true)]
        [string]
        $workspaceKey,
        [Parameter(Mandatory=$false)]
        [string]
        $LogType="GuardrailsCompliance",
        [Parameter(Mandatory=$false)]
        [string]
        $ExcludedVNets
    )
[PSCustomObject] $VNetList = New-Object System.Collections.ArrayList

$subs=Get-AzSubscription | Where-Object {$_.State -eq 'Enabled'}

if ($ExcludedVNets -ne $null)
{
    $ExcludedVNetsList=$ExcludedVNets.Split(",")
}
foreach ($sub in $subs)
{
    Write-Verbose "Selecting subscription..."
    Select-AzSubscription -SubscriptionObject $sub
    
    $VNets=Get-AzVirtualNetwork
    Write-Debug "Found $($VNets.count) VNets."
    if ($VNets)
    {
        foreach ($VNet in $VNets)
        {
            Write-Debug "Working on $($VNet.Name) VNet..."
            $ev=get-tagValue -tagKey "ExcludeFromCompliance" -object $VNet
            if ($ev -ne "true" -and $vnet.Name -notin $ExcludedVNetsList)
            {
                if ($Vnet.EnableDdosProtection) 
                {
                    $ComplianceStatus = $true 
                    $Comments="DDos Protection Enabled. $($VNet.DdosProtectionPlan.Id)"
                    $MitigationCommands="N/A"
                }
                else {
                    $ComplianceStatus = $false
                    $Comments="DDos Protection not enabled."
                    $MitigationCommands=@"
                    Select-azsubscription $($sub.SubscriptionId)
                    $plan=new-azddosProtectionPlan -ResourceGroupName $($Vnet.ResourceGroupName) -Name '$($Vnet.Name)-plan' -Location '$($vnet.Location)'
                    $vnet=Get-AzVirtualNetwork -Name $($vnet.Name) -ResourceGroupName $($Vnet.ResourceGroupName)
                    $vnet.EnableDdosProtection=$true
                    $vnet.DdosProtectionPlan.Id=$plan.id
                    Set-azvirtualNetwork -VirtualNetwork $vnet
"@
                }
                # Create PSOBject with Information.
                $VNetObject = [PSCustomObject]@{ 
                    VNETName = $VNet.Name
                    SubscriptionName  = $sub.Name 
                    ComplianceStatus = $ComplianceStatus
                    Comments = $Comments
                    ItemName = "VNet DDos configuration"
                    ControlName = $ControlName
                    MitigationCommands=$MitigationCommands
                }
                $VNetList.add($VNetObject) | Out-Null                
            }
            else {
                Write-Verbose "Excluding $($VNet.Name) (Tag or parameter)."
            }    
        }
    }
}
Write-Output "Listing $($VNetList.Count) List members."
foreach ($s in $VNetList)
{
    if ($s.Compliant)
    {
        Write-Output "VNet: $($s.VNETName) - Compliant: $($s.ComplianceStatus) Comments: $($s.Comments)" 
    }
    else {
        Write-Output "VNet: $($s.VNETName) - Compliant: $($s.ComplianceStatus) Comments: $($s.Comments)"
    }
}
   # Convert data to JSON format for input in Azure Log Analytics
   $JSONVNetList = ConvertTo-Json -inputObject $VNetList #| Out-File c:\temp\guestUsers.txt
   Send-OMSAPIIngestionFile  -customerId $WorkSpaceID `
  -sharedkey $workspaceKey `
  -body $JSONVNetList `
  -logType $LogType `
  -TimeStampField Get-Date 
}
