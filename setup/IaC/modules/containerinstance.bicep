param AllowedLocationPolicyId string
param automationAccountName string
param CBSSubscriptionName string
param containername string
param CustomModulesBaseURL string
param DepartmentNumber string
param DepartmentName string
param guardrailsKVname string
param guardrailsLogAnalyticscustomerId string
param guardrailsStoragename string
param HealthLAWResourceId string
param lighthouseTargetManagementGroupID string
param Locale string
param location string
param newDeployment bool = true
param PBMMPolicyID string
param releaseDate string
param releaseVersion string
param SecurityLAWResourceId string
param TenantDomainUPN string
param updatePSModules bool = false
param updateCoreResources bool = false

resource containerinstance 'Microsoft.ContainerInstance/containerGroups@2022-09-01' = {
  name: '${automationAccountName}-main'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    releaseVersion:releaseVersion
    releasedate: releaseDate
  }
  properties: {
    restartPolicy: 'Never'
    containers: [
      {
        name: 'guardrails-main'
        properties: {
          image: 'mbrat2005/guardrailssolutionaccelerator:latest'
          resources: {
            requests: {
              cpu: 2
              memoryInGB: 2
            }
          }
          environmentVariables: [
            {
              name: 'KeyvaultName'
              value: guardrailsKVname
            }
            {
              name: 'WorkSpaceID'
              value: guardrailsLogAnalyticscustomerId
            }
            { 
              name: 'LogType'
              value: 'GuardrailsCompliance'
            }
            { 
              name: 'PBMMPolicyID'
              value: '/providers/Microsoft.Authorization/policySetDefinitions/${PBMMPolicyID}'
            }
            { 
              name: 'GuardrailWorkspaceIDKeyName'
              value: 'WorkSpaceKey'
            }
            { 
              name: 'StorageAccountName'
              value: guardrailsStoragename
            }
            { 
              name: 'ContainerName'
              value: containername
            }
            { 
              name: 'ResourceGroupName'
              value: resourceGroup().name
            }
            { 
              name: 'AllowedLocationPolicyId'
              value: '/providers/Microsoft.Authorization/policyDefinitions/${AllowedLocationPolicyId}'
            }
            { 
              name: 'DepartmentNumber'
              value: DepartmentNumber
            }
            { 
              name: 'CBSSubscriptionName'
              value: CBSSubscriptionName
            }
            { 
              name: 'SecurityLAWResourceId'
              value: SecurityLAWResourceId
            }
            { 
              name: 'HealthLAWResourceId'
              value: HealthLAWResourceId
            }
            { 
              name: 'TenantDomainUPN'
              value: TenantDomainUPN
            }
            { 
              name: 'GuardRailsLocale'
              value: Locale
            }
            { 
              name: 'lighthouseTargetManagementGroupID'
              value: lighthouseTargetManagementGroupID
            }
            { 
              name: 'DepartmentName'
              value: DepartmentName
            }
          ]
        }
      }
    ]
    osType: 'Linux'
  }
}

output guardrailsContainerInstanceMSI string = containerinstance.identity.principalId
