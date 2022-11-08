param(
    $pipelineModulesStagingRGName,
    $pipelineModulesStagingStorageAccountName,
    $configFilePath
    )
# clean up existing deployment
    ipmo ./src/GuardrailsSolutionAcceleratorSetup
    Push-Location -Path setup
    try {
        $ErrorActionPreference = 'Stop'
        Remove-gsacentralizedReportingCustomerComponents -Force -configFilePath $configFilePath
        Remove-GSACentralizedDefenderCustomerComponents -Force -configFilePath $configFilePath
        Remove-GSACoreResources -Force -Wait -configFilePath $configFilePath
    }
    catch {
        throw "Failed test deploy of solution with error: $_"
    }
    finally {
    If (!$?) {throw "Failed test deploy of solution with error: $($error[0]) $_"}
    Pop-Location
    }
# zip all modules
    $moduleManifestFilesObjs = Get-ChildItem -Path .\src -Recurse -Include *.psm1
    Write-Host "'$($moduleManifestFiles.count)' module manifest files "
    ForEach ($moduleManifest in $moduleManifestFilesObjs) {
        $moduleCodeFile = Get-Item -Path $moduleManifest.FullName.replace('psd1','psm1')
        If ($moduleManifestFilesObjs.FullName -icontains $moduleManifest.FullName -or $moduleManifestFilesObjs.FullName -icontains $moduleCodeFile.FullName) {
            Write-Host "Module '$($moduleManifest.BaseName)' found, zipping module files..."
            $destPath = "./psmodules/$($moduleManifest.BaseName).zip"
            Compress-Archive -Path "$($moduleManifest.Directory)/*" -DestinationPath $destPath -Force
        }
        Else {
            Write-Host "Neither the manifest '$($moduleManifest.FullName.toLower())' or script file '$($moduleCodeFile.FullName.ToLower())' for module '$($moduleManifest.BaseName)' was changed, skipping zipping..."
        }
    }
# push modules to storage account for AA to pick up
    $storageContext = (Get-AzStorageAccount -ResourceGroupName $pipelineModulesStagingRGName -Name $pipelineModulesStagingStorageAccountName).Context
    $zippedModules = Get-ChildItem -Path ./psmodules/* -Include *.zip -File
    ForEach ($moduleZip in $zippedModules) {
    Set-AzStorageBlobContent -Context $storageContext -Container psmodules -File $moduleZip.FullName -Blob $moduleZip.Name -Force -ErrorAction Stop
    }
# deploy solution
    $modulesStagingURI = $storageContext.BlobEndpoint.ToString() + 'psmodules'
    $alternatePSModulesURL = $modulesStagingURI
    Write-Output "alternatePSModulesURL is '$alternatePSModulesURL'"
    Push-Location -Path setup
    try {
        $ErrorActionPreference = 'Stop'
        ./setup.ps1 -configFilePath $configFilePath -configureLighthouseAccessDelegation -alternatePSModulesURL $alternatePSModulesURL -Yes -Verbose
    }
    catch {
        throw "Failed test deploy of solution with error: $_"
    }
    finally {
    If (!$?) {throw "Failed test deploy of solution with error: $($error[0]) $_"}
    Pop-Location
    }