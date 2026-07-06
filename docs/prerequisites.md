# Deployment Prerequisites

## Required tooling
- Azure subscription with permission to create/update resource-group scoped resources.
- Azure CLI and Azure Developer CLI installed and authenticated (`az login`, `azd auth login`).
- Bicep CLI available via Azure CLI.

## Required signal source (the key prerequisite)
The workbooks visualize the OpenTelemetry GenAI spans that Microsoft Foundry writes to Application Insights. Before deploying, make sure this data is flowing:

- A **Foundry project connected to an Application Insights resource**. Foundry enables server-side tracing automatically for prompt and hosted agents once connected. See [Set up tracing in Microsoft Foundry](https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup#connect-application-insights-to-your-foundry-project).
- At least one **agent run**, so `invoke_agent` / `chat` / `execute_tool` spans exist in the `dependencies` table.
- The [Log Analytics Reader role](https://learn.microsoft.com/azure/azure-monitor/logs/manage-access?tabs=portal#log-analytics-reader) on the connected Application Insights resource (required to query telemetry).

### Signals the workbooks read
All tiles are keyed on the [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/), found in the `dependencies` table:

| Span (`gen_ai.operation.name`) | Used for | Key attributes |
| --- | --- | --- |
| `invoke_agent` | agent runs, latency, errors | `gen_ai.agent.name`, `gen_ai.agent.id`, `gen_ai.conversation.id` |
| `chat` | model calls, token usage | `gen_ai.request.model`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens` |
| `execute_tool` | tool/A2A calls | `gen_ai.tool.name` |

## Configuration inputs
- Deployment location and resource group.
- Monitoring mode: create new or reuse an existing Log Analytics workspace + Application Insights.
- Reuse mode: existing App Insights name (same resource group) or explicit resource IDs.

## Optional inputs
- `cognitiveServicesAccountName` — attach Azure OpenAI resource diagnostics to the workspace (skipped when omitted).
- `sharedViewerPrincipalObjectIds` — assign Reader on the workbooks. Requires the deploying identity to have permission to create role assignments.
