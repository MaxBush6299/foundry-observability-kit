targetScope = 'resourceGroup'

@description('Deployment location for workbook resources.')
param location string

@description('Application Insights resource ID used for workbook defaults.')
param appInsightsResourceId string

@description('Log Analytics workspace resource ID used by workbook queries.')
param workspaceResourceId string

@description('Price map array for directional cost estimation.')
param modelPriceMap array = []

@description('Optional object IDs for shared viewer role assignment at resource-group scope.')
param sharedViewerPrincipalObjectIds array = []

resource platformDevWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, 'platform-dev-workbook')
  location: location
  kind: 'shared'
  tags: {
    workspaceResourceId: workspaceResourceId
    priceMapConfigured: string(length(modelPriceMap) > 0)
  }
  properties: {
    category: 'workbook'
    displayName: 'Foundry Platform/Dev Observability'
    serializedData: loadTextContent('../workbooks/platform-dev.workbook')
    sourceId: appInsightsResourceId
    version: 'Workbook/1.0'
  }
}

resource governanceWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, 'governance-workbook')
  location: location
  kind: 'shared'
  tags: {
    workspaceResourceId: workspaceResourceId
    priceMapConfigured: string(length(modelPriceMap) > 0)
  }
  properties: {
    category: 'workbook'
    displayName: 'Foundry Governance Observability'
    serializedData: loadTextContent('../workbooks/governance.workbook.json')
    sourceId: appInsightsResourceId
    version: 'Workbook/1.0'
  }
}

resource sharedViewerAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalObjectId in sharedViewerPrincipalObjectIds: {
  name: guid(resourceGroup().id, principalObjectId, 'shared-workbook-viewer')
  properties: {
    principalId: principalObjectId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
    principalType: 'User'
  }
}]

output platformDevWorkbookResourceId string = platformDevWorkbook.id
output governanceWorkbookResourceId string = governanceWorkbook.id
