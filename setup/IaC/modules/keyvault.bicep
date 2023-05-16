param kvName string
param location string
param currentUserObjectId string = ''
param automationAccountMSI string = ''
param releaseVersion string
param releaseDate string
param vaultUri string
param tenantId string
param deployKV bool

resource guardrailsKV 'Microsoft.KeyVault/vaults@2021-06-01-preview' = if (deployKV) {
  name: kvName
  location: location
  tags: {
    releaseVersion:releaseVersion
    releasedate: releaseDate
  }
  properties: {
    sku: {
      family: 'A'
      name:  'standard'
    }
    //tenantId: guardrailsAC.identity.tenantId
    tenantId: tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: false
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    vaultUri: vaultUri
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource adminUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (currentUserObjectId != '') {
  name: 'adminUserRoleAssignment'
  scope: guardrailsKV
  properties: {
    // key vault administrator role definition id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
    principalId: currentUserObjectId
  }
}

resource automationAccountRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (automationAccountMSI != '') {
  name: 'automationAccountRoleAssignment'
  scope: guardrailsKV
  properties: {
    // key vault secret user role definition id
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4633458b-17de-408a-b874-0445c86b69e6')
    principalId: automationAccountMSI
  }
}
