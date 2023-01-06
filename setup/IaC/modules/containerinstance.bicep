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
  name: automationAccountName
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
          command: [
            'tail'
            '-f'
            '/dev/null'
          ]
          environmentVariables: [
            {
              name: 'KeyvaultName'
              secureValue: '"${guardrailsKVname}"'
            }
            {
              name: 'WorkSpaceID'
              secureValue: '"${guardrailsLogAnalyticscustomerId}"'
            }
            { 
              name: 'LogType'
              secureValue: '"GuardrailsCompliance"'
            }
            { 
              name: 'PBMMPolicyID'
              secureValue: '"/providers/Microsoft.Authorization/policySetDefinitions/${PBMMPolicyID}"'
            }
            { 
              name: 'GuardrailWorkspaceIDKeyName'
              secureValue: '"WorkSpaceKey"'
            }
            { 
              name: 'StorageAccountName'
              value: '"${guardrailsStoragename}"'
            }
            { 
              name: 'ContainerName'
              secureValue: '"${containername}"'
            }
            { 
              name: 'ResourceGroupName'
              value: '"${resourceGroup().name}"'
            }
            { 
              name: 'AllowedLocationPolicyId'
              secureValue: '"/providers/Microsoft.Authorization/policyDefinitions/${AllowedLocationPolicyId}"'
            }
            { 
              name: 'DepartmentNumber'
              value: '"${DepartmentNumber}"'
            }
            { 
              name: 'CBSSubscriptionName'
              secureValue: '"${CBSSubscriptionName}"'
            }
            { 
              name: 'SecurityLAWResourceId'
              secureValue: '"${SecurityLAWResourceId}"'
            }
            { 
              name: 'HealthLAWResourceId'
              secureValue: '"${HealthLAWResourceId}"'
            }
            { 
              name: 'TenantDomainUPN'
              value: '"${TenantDomainUPN}"'
            }
            { 
              name: 'GuardRailsLocale'
              value: '"${Locale}"'
            }
            { 
              name: 'lighthouseTargetManagementGroupID'
              secureValue: '"${lighthouseTargetManagementGroupID}"'
            }
            { 
              name: 'DepartmentName'
              value: '"${DepartmentName}"'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
  }
}

output guardrailsContainerInstanceMSI string = containerinstance.identity.principalId
