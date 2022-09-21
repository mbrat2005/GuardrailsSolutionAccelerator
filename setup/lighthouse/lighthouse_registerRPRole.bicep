targetScope = 'managementGroup'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: 'Custom-RegisterLighthouseResourceProvider'
  properties: {
    roleName: 'Custom-RegisterLighthouseResourceProvider'
    description: 'Permits assignees to register the Microsoft.ManagedServices resource provider in the target scope.'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.ManagedServices/register/action'
        ]
        notActions: []
      }
    ]
    assignableScopes: [
      '/providers/Microsoft.Management/managementGroups/${managementGroup().name}'
    ]
  }
}

output roleDefinitionId string = roleDefinition.id
