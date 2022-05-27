function read-exceptionFile {
param (
    [string] $StorageAccountName, [string] $ContainerName, [string] $ResourceGroupName, `
    [string] $SubscriptionID, [string] $FileName
    )
    $tempFileName='tempfile.json'
    $StorageAccount= Get-Azstorageaccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

    $StorageAccountContext = $StorageAccount.Context
    #try {
        $Blobs=Get-AzStorageBlob -Container $ContainerName -Context $StorageAccountContext
        if (($blobs | Where-Object {$_.Name -eq $FileName}) -ne $null) 
        { 
            Get-AzStorageBlobContent -Blob $blobs.Name -Container $ContainerName -Context $StorageAccountContext -Destination $tempFileName -Force
            return get-content -Path $tempFileName | ConvertFrom-Json
            rm $tempFileName     
        }
        else
        {
            $Comments = "Coudnt find index for " + $ItemName + ", please create upload a file with a name " +$FileName+ " to confirm you have completed the Item in the control "
            return $null
        }
    #}
    #catch
    #{
    #    Write-error "error reading file from storage."
    #}
}
$excludedSubnets=read-exceptionFile -StorageAccountName fguardrailsuzje -ContainerName 'exemptions' `
-FileName module8exceptions.json -ResourceGroupName fGuardrails-6eb08c2c -SubscriptionID '6c64f9ed-88d2-4598-8de6-7a9527dc16ca'
$excludedSubnets

break 

