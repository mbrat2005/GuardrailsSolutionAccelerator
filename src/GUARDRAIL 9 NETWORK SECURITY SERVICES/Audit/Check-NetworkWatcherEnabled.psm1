function Get-NetworkWatcherStatus {
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $token,
        [Parameter(Mandatory=$true)]
        [string]
        $ControlName,
        [string] $itsgcode,
        [Parameter(Mandatory=$false)]
        [string]
        $ExcludedVNets,
        [hashtable] $msgTable,
        [Parameter(Mandatory=$true)]
        [string]
        $ReportTime,
        [Parameter(Mandatory=$true)]
        [string]
        $CBSSubscriptionName,
        [Parameter(Mandatory=$false)]
        [switch]
        $debuginfo
    )
    [PSCustomObject] $RegionList = New-Object System.Collections.ArrayList
    [PSCustomObject] $ErrorList = New-Object System.Collections.ArrayList
    $ExcludeVnetTag="GR9-ExcludeVNetFromCompliance"
    try {
        $subs=Get-AzSubscription -ErrorAction Stop | Where-Object {$_.State -eq 'Enabled' -and $_.Name -ne $CBSSubscriptionName}  
    }
    catch {
        $ErrorList.Add("Failed to execute the 'Get-AzSubscription' command--verify your permissions and the installion of the Az.Accounts module; returned error message: $_" )
        throw "Error: Failed to execute the 'Get-AzSubscription'--verify your permissions and the installion of the Az.Accounts module; returned error message: $_"                
    }
    if ($null -ne $ExcludedVNets)
    {
        $ExcludedVNetsList=$ExcludedVNets.Split(",")
    }

    $graphQuery = @"
        resourcecontainers | 
        where type == 'microsoft.resources/subscriptions' | 
        project subscriptionId, subscriptionName = name |
        join kind=leftouter (
            resources | 
                where type == 'microsoft.network/virtualnetworks' | 
                project vNetName = name, vnetId = id, location, vnetTags = tags, subscriptionId |
                join kind=leftouter (
                    resources | 
                        where type == 'microsoft.network/networkwatchers' | 
                        project networkWatcherName = name, location, subscriptionId
                        ) on location, subscriptionId
        ) on subscriptionId |
        project-away subscriptionId1,subscriptionId2,location1
"@
        
        $vnets = @()
        $allVNETs = @()

        $vnets = Search-AzGraph -Query $graphQuery -Subscription $subs.Id
        $allVNETs += $vnets
        # resource graph returns pages of 100 resources, if there are more than 100 resources in a batch, recursively query for more
        while ($vnets.count -eq 100 -and $vnets.SkipToken) {
            $vnets = Search-AzGraph -query $graphQuery -skipToken $vnets.SkipToken -Subscription $subs.Id
            $allVNETs += $vnets
        }

        # create grouping of vnets by subscription
        $allVNETsGrouped = $allVNETs | Group-Object -Property subscriptionName

        ForEach ($subscriptionVNETGroup in $allVNETsGrouped) {
            Write-Verbose "Working on subscription '$($subscriptionVNETGroup.Name)'"

            $allSubscriptionVNETs = $subscriptionVNETGroup.Group

            $includedVNETs=$allSubscriptionVNETs | Where-Object { $_.vnetTags.$ExcludeVnetTag -ine 'true' -and $_.vnetName -notin $ExcludedVNetsList }
            Write-Debug "Found $($allSubscriptionVNETs.count) VNets total; $($includedVNETs.count) not excluded by tag or -ExcludedVNets parameter."

            if ($includedVNETs.count -gt 0)
            {
                # create grouping of vnets by region
                $subscriptionVNETsGrouped = $includedVNETs | Group-Object -Property location

                # check if network watcher is enabled in the region
                ForEach ($vnetRegion in $subscriptionVNETsGrouped) {
                    Write-Verbose "Working on region '$($vnetRegion.Name)' '$($vnetRegion.Group.networkWatcherName -join ',')'"

                    If (![String]::IsNullOrEmpty($vnetRegion.Group.networkWatcherName)) {
                        # region has network watcher enabled and is compliant
                        $ComplianceStatus = $true 
                        $Comments= $msgTable.networkWatcherEnabled -f $vnetRegion.Name
                    }
                    Else {
                        # region does not have network watcher enabled and is not compliant
                        $ComplianceStatus = $false
                        $Comments = $msgTable.networkWatcherNotEnabled -f $vnetRegion.Name
                    }
                    # Create PSOBject with Information.
                    $RegionObject = [PSCustomObject]@{ 
                        SubscriptionName  = $subscriptionVNETGroup.Name
                        ComplianceStatus = $ComplianceStatus
                        Comments = $Comments
                        ItemName = $msgTable.networkWatcherConfig
                        itsgcode = $itsgcode
                        ControlName = $ControlName
                        ReportTime = $ReportTime
                    }
                    $RegionList.add($RegionObject) | Out-Null 
                }
            }
            else {
                $ComplianceStatus = $true
                $RegionObject = [PSCustomObject]@{ 
                    SubscriptionName  = $subscriptionVNETGroup.Name
                    ComplianceStatus = $ComplianceStatus
                    Comments = $Comments
                    ItemName = $msgTable.networkWatcherConfigNoRegions
                    itsgcode = $itsgcode
                    ControlName = $ControlName
                    ReportTime = $ReportTime
                }
                $RegionList.add($RegionObject) | Out-Null   
            }
        }
    if ($debuginfo){ 
        Write-Output "Listing $($RegionList.Count) List members."
    }
    #Creates Results object:
    $moduleOutput= [PSCustomObject]@{ 
        ComplianceResults = $RegionList 
        Errors=$ErrorList
        AdditionalResults = $AdditionalResults
    }
    return $moduleOutput
}


