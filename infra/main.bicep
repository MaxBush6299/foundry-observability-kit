targetScope = 'resourceGroup'

@description('Deployment location for all resources that are created by this template.')
param location string = resourceGroup().location

@description('Enable to reuse an existing Log Analytics workspace and Application Insights instance.')
param useExistingMonitoringResources bool = false

@description('Resource ID of an existing Log Analytics workspace. Required when reuse is enabled.')
param logAnalyticsWorkspaceId string = ''

@description('Resource ID of an existing Application Insights component. Required when reuse is enabled.')
param applicationInsightsResourceId string = ''

@description('Name of an existing Application Insights component in this resource group. Used when reuse is enabled and resource ID is not provided.')
param existingApplicationInsightsName string = ''

@description('Name of the Azure OpenAI/Cognitive Services account in this resource group for diagnostics.')
param cognitiveServicesAccountName string = ''

@description('Minimum retention days for operational signals.')
@minValue(30)
param retentionDays int = 30

@description('Model price map used by workbook directional cost tiles.')
param modelPriceMap array = []

@description('Optional object IDs for principals that should get shared workbook viewer access.')
param sharedViewerPrincipalObjectIds array = []

module monitoring './monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    useExistingMonitoringResources: useExistingMonitoringResources
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    applicationInsightsResourceId: applicationInsightsResourceId
    existingApplicationInsightsName: existingApplicationInsightsName
    retentionDays: retentionDays
  }
}

module diagnostics './diagnostics.bicep' = {
  name: 'diagnostics'
  params: {
    targetResourceName: cognitiveServicesAccountName
    workspaceResourceId: monitoring.outputs.workspaceResourceId
  }
}

module workbooks './workbooks.bicep' = {
  name: 'workbooks'
  params: {
    location: location
    appInsightsResourceId: monitoring.outputs.appInsightsResourceId
    workspaceResourceId: monitoring.outputs.workspaceResourceId
    modelPriceMap: modelPriceMap
    sharedViewerPrincipalObjectIds: sharedViewerPrincipalObjectIds
  }
}

output workspaceResourceId string = monitoring.outputs.workspaceResourceId
output appInsightsResourceId string = monitoring.outputs.appInsightsResourceId
output platformDevWorkbookResourceId string = workbooks.outputs.platformDevWorkbookResourceId
output governanceWorkbookResourceId string = workbooks.outputs.governanceWorkbookResourceId
