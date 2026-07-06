# Schema Source Citation Matrix

Access date for all entries: 2026-07-02

## Foundry tracing and GenAI semantics
- Trace structure and operation names (`invoke_agent`, `execute_tool`, `chat`):
  - https://learn.microsoft.com/azure/foundry/how-to/develop/langchain-traces#understand-trace-structure
- Tracing setup and Application Insights linkage:
  - https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup#instrument-ai-agents

## Azure OpenAI diagnostics and metrics
- Resource log categories (`RequestResponse`, `Audit`, `Trace`, `AzureOpenAIRequestUsage`):
  - https://learn.microsoft.com/azure/foundry/openai/monitor-openai-reference#resource-logs
- Metrics (`AzureOpenAIRequests`, `ProcessedPromptTokens`, `GeneratedTokens`, `TokenTransaction`):
  - https://learn.microsoft.com/azure/foundry/openai/monitor-openai-reference#metrics

## Monitoring and routing guidance
- Diagnostic settings and data routing in Azure Monitor:
  - https://learn.microsoft.com/azure/ai-foundry/openai/how-to/monitor-openai#data-collection-and-routing-in-azure-monitor
