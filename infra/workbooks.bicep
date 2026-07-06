targetScope = 'resourceGroup'

@description('Deployment location for workbook resources.')
param location string

@description('Application Insights resource ID used for workbook defaults.')
param appInsightsResourceId string

@description('Log Analytics workspace resource ID used by workbook queries.')
param workspaceResourceId string

@description('Optional object IDs for shared viewer (Reader) role assignment scoped to the workbooks.')
param sharedViewerPrincipalObjectIds array = []

@description('Principal type for the shared viewer role assignments.')
@allowed([
  'User'
  'Group'
  'ServicePrincipal'
])
param sharedViewerPrincipalType string = 'User'

var readerRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')

resource platformDevWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, 'platform-dev-workbook')
  location: location
  kind: 'shared'
  tags: {
    workspaceResourceId: workspaceResourceId
  }
  properties: {
    category: 'workbook'
    displayName: 'Foundry Platform/Dev Observability'
    serializedData: loadTextContent('../workbooks/platform-dev.workbook.json')
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
  }
  properties: {
    category: 'workbook'
    displayName: 'Foundry Governance Observability'
    serializedData: loadTextContent('../workbooks/governance.workbook.json')
    sourceId: appInsightsResourceId
    version: 'Workbook/1.0'
  }
}

resource platformViewerAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalObjectId in sharedViewerPrincipalObjectIds: {
  name: guid(platformDevWorkbook.id, principalObjectId, 'workbook-reader')
  scope: platformDevWorkbook
  properties: {
    principalId: principalObjectId
    roleDefinitionId: readerRoleDefinitionId
    principalType: sharedViewerPrincipalType
  }
}]

resource governanceViewerAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalObjectId in sharedViewerPrincipalObjectIds: {
  name: guid(governanceWorkbook.id, principalObjectId, 'workbook-reader')
  scope: governanceWorkbook
  properties: {
    principalId: principalObjectId
    roleDefinitionId: readerRoleDefinitionId
    principalType: sharedViewerPrincipalType
  }
}]

output platformDevWorkbookResourceId string = platformDevWorkbook.id
output governanceWorkbookResourceId string = governanceWorkbook.id
