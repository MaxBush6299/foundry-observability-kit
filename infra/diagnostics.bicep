targetScope = 'resourceGroup'

@description('Target resource name to attach diagnostic settings to (Azure OpenAI/Cognitive Services).')
param targetResourceName string

@description('Log Analytics workspace resource ID destination.')
param workspaceResourceId string

@description('Enable diagnostic logs and metrics.')
param enabled bool = true

resource target 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = if (!empty(targetResourceName)) {
  name: targetResourceName
}

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enabled && !empty(targetResourceName)) {
  name: 'foundry-observability-diagnostics'
  scope: target
  properties: {
    workspaceId: workspaceResourceId
    logs: [
      {
        category: 'RequestResponse'
        enabled: true
      }
      {
        category: 'Audit'
        enabled: true
      }
      {
        category: 'Trace'
        enabled: true
      }
      {
        category: 'AzureOpenAIRequestUsage'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
