# Deployment and Validation Guide

## Purpose
This guide defines repeatable deployment and validation steps for the Foundry Agent Observability Starter Kit. The workbooks read the OpenTelemetry GenAI spans (`invoke_agent`, `chat`, `execute_tool`) that Foundry writes to Application Insights.

## Deployment

### Option A — Reuse an existing Application Insights resource (recommended)
Use when your Foundry project is already connected to Application Insights.

```bash
az deployment group create \
  --resource-group "<your-rg>" \
  --template-file "infra/main.bicep" \
  --parameters \
    useExistingMonitoringResources=true \
    existingApplicationInsightsName="<your-app-insights-name>"
```

If the resource is in another resource group, pass `applicationInsightsResourceId` and `logAnalyticsWorkspaceId` explicitly instead of the name.

### Option B — Provision new monitoring resources with `azd`
1. Authenticate: `az login`, `azd auth login`.
2. Create/select environment: `azd env new <environment-name>`.
3. Set values in `.azure/<environment-name>/.env` (see `.azure/.env.example`).
4. Run deployment: `azd up`.

### Confirm outputs
- `workspaceResourceId`
- `appInsightsResourceId`
- `platformDevWorkbookResourceId`
- `governanceWorkbookResourceId`

## Validation
1. Open the Platform/Dev workbook from **Application Insights → Workbooks**.
2. Confirm the **Summary** KPI tiles populate (Agent runs, Active agents, Failure rate, p95 latency, Total tokens, Tool calls). Empty values mean no `gen_ai.*` spans in the selected window — generate agent traffic or widen the **TimeRange**.
3. Confirm **Agent activity** shows one bar per agent from `invoke_agent` spans.
4. Confirm **Token usage** splits input vs. output from `chat` spans.
5. Open the Governance workbook and confirm **who ran what** and **access trail** populate from `invoke_agent` / `execute_tool` spans.

### Data readiness check
If tiles are empty, verify spans exist:

```kusto
dependencies
| where timestamp > ago(24h)
| summarize count() by op = tostring(customDimensions['gen_ai.operation.name'])
```

Expect rows for `invoke_agent`, `chat`, and (if tools are used) `execute_tool`. If none appear, confirm the Foundry project is connected to this Application Insights resource and that an agent has run. See [Set up tracing in Microsoft Foundry](https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup).

## Cross-Platform Deployment Validation Matrix
| Platform | Shell | Validation Steps | Expected Result |
|---|---|---|---|
| Windows | PowerShell | `az login`, `azd auth login`, `azd up` (or Option A) | Deployment succeeds with workbook outputs; tiles populate when telemetry exists |
| macOS | zsh/bash | `az login`, `azd auth login`, `azd up` (or Option A) | Deployment succeeds with workbook outputs; tiles populate when telemetry exists |
| Linux | bash | `az login`, `azd auth login`, `azd up` (or Option A) | Deployment succeeds with workbook outputs; tiles populate when telemetry exists |

## Platform/Developer Investigation Workflow
1. Open the Platform/Dev workbook and set the **TimeRange** pill.
2. Review **Summary** KPIs for overall health (runs, failure rate, p95 latency, tokens).
3. Use **Agent activity** to see which agents ran and when.
4. Use **Workload** to break down model (`chat`) and tool (`execute_tool`) calls per agent.
5. Use **Token usage** to attribute input/output tokens by agent and model.
6. Use **Performance** to spot slow agents (p50/p95) and model latency trends.
7. Use **Reliability** (errors by agent, failed dependencies, exceptions) to triage, then open **Recent operations** and drill into a single `operation_Id`.

## Governance Investigation Workflow
1. Open the Governance workbook and set `timeRange`.
2. Review **who ran what** for attribution (actor, target agent, conversation).
3. Use **access trail** to analyze actor/agent/tool activity over time.
4. Inspect **anomaly flags** for off-hours or spike conditions in agent runs.

## Audience Boundary
- Platform/Dev workbook focuses on operational diagnosis and performance behavior.
- Governance workbook focuses on attribution and access visibility.
- Both workbooks share the same GenAI telemetry but remain independently usable.
