targetScope = 'resourceGroup'

@description('Deployment location for monitoring resources.')
param location string

@description('When true, existing monitoring resources are used.')
param useExistingMonitoringResources bool = false

@description('Existing Log Analytics workspace resource ID.')
param logAnalyticsWorkspaceId string = ''

@description('Existing Application Insights component resource ID.')
param applicationInsightsResourceId string = ''

@description('Existing Application Insights component name in this resource group. Used if resource ID is not provided.')
param existingApplicationInsightsName string = ''

@description('Minimum retention days for workspace tables.')
@minValue(30)
param retentionDays int = 30

var workspaceName = 'law-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appi-${uniqueString(resourceGroup().id)}'

var derivedAppInsightsFromExisting = !empty(existingApplicationInsightsName)
  ? resourceId('Microsoft.Insights/components', existingApplicationInsightsName)
  : ''

var derivedWorkspaceFromExisting = !empty(existingApplicationInsightsName)
  ? reference(derivedAppInsightsFromExisting, '2020-02-02', 'full').properties.WorkspaceResourceId
  : ''

var resolvedWorkspaceResourceId = useExistingMonitoringResources
  ? (!empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : derivedWorkspaceFromExisting)
  : workspace.id

var resolvedAppInsightsResourceId = useExistingMonitoringResources
  ? (!empty(applicationInsightsResourceId) ? applicationInsightsResourceId : derivedAppInsightsFromExisting)
  : appInsights.id

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (!useExistingMonitoringResources) {
  name: workspaceName
  location: location
  properties: {
    retentionInDays: retentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (!useExistingMonitoringResources) {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
    RetentionInDays: retentionDays
    IngestionMode: 'ApplicationInsights'
  }
}

output workspaceResourceId string = resolvedWorkspaceResourceId
output appInsightsResourceId string = resolvedAppInsightsResourceId
