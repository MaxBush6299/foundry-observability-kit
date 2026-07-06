# Foundry Agent Observability Starter Kit

A deployable Application Insights starter kit for monitoring **Microsoft Foundry prompt agents**. It provisions (or reuses) Azure Monitor resources and installs two ready-to-use Azure Workbooks built entirely on the [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) that Foundry emits:

- **Platform/Dev workbook** — agent runs, model/tool calls, token usage, latency, and reliability.
- **Governance workbook** — attribution ("who ran what"), access trail, and anomaly flags.

Both workbooks read the GenAI spans Foundry writes to Application Insights (`invoke_agent`, `chat`, `execute_tool`) from the `dependencies` table — no custom instrumentation required beyond connecting Foundry to Application Insights.

## Why Application Insights for agent observability?

Application Insights is the application performance monitoring (APM) feature of Azure Monitor, and it's the telemetry backend Microsoft Foundry uses for agent tracing. Based on Microsoft documentation:

- **It's where Foundry already sends traces.** Foundry stores agent traces in Application Insights using OpenTelemetry semantic conventions, and enables server-side tracing automatically for prompt and hosted agents once you connect a resource — no code changes required. See [Set up tracing in Microsoft Foundry](https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup).
- **Purpose-built agent monitoring.** The **Agents (preview)** view in Application Insights consolidates agent telemetry so you can track agent performance, analyze token usage and cost, troubleshoot errors, and optimize behavior. It's based on OpenTelemetry GenAI Semantics. See [Monitor AI agents with Application Insights](https://learn.microsoft.com/azure/azure-monitor/app/agents-view).
- **Vendor-neutral via OpenTelemetry.** Application Insights collects telemetry through OpenTelemetry, a standardized, vendor-neutral framework, so the same signals work across frameworks and tools. See [Application Insights overview](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview).
- **A rich analysis surface.** Beyond workbooks, you get Application Map, Live Metrics, Transaction Search, Failures/Performance views, KQL over Log Analytics, alerts, and Grafana dashboards — all over the same data. See [Application Insights overview](https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview).

In short: if your agents run in Foundry, their observability data already lives in Application Insights. This kit turns that raw telemetry into curated dashboards.

## Prerequisites

1. An Azure subscription with permission to create resource-group–scoped resources (and to assign roles if you use the optional shared-viewer feature).
2. [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) and [Azure Developer CLI (`azd`)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd), authenticated (`az login`, `azd auth login`).
3. **A Foundry project connected to Application Insights**, with agents that have run at least once. This is the key data prerequisite — without it the workbooks render but stay empty. Follow [Set up tracing in Microsoft Foundry](https://learn.microsoft.com/azure/foundry/observability/how-to/trace-agent-setup#connect-application-insights-to-your-foundry-project).
4. To query telemetry you need the [Log Analytics Reader role](https://learn.microsoft.com/azure/azure-monitor/logs/manage-access?tabs=portal#log-analytics-reader) on the connected Application Insights resource.

> The kit does not generate agent traffic. It visualizes the `gen_ai.*` spans your Foundry agents already emit.

## Deploy

### Option A — Reuse an existing Application Insights resource (recommended)

If your Foundry project is already connected to an Application Insights resource, point the kit at it. This is the fastest path and installs only the workbooks.

```powershell
az deployment group create `
  --resource-group "<your-rg>" `
  --template-file "infra/main.bicep" `
  --parameters `
    useExistingMonitoringResources=true `
    existingApplicationInsightsName="<your-app-insights-name>"
```

The workspace ID is derived automatically from the App Insights resource. If the resource lives in another resource group, pass explicit IDs instead:

```powershell
az deployment group create `
  --resource-group "<your-rg>" `
  --template-file "infra/main.bicep" `
  --parameters `
    useExistingMonitoringResources=true `
    applicationInsightsResourceId="<app-insights-resource-id>" `
    logAnalyticsWorkspaceId="<workspace-resource-id>"
```

### Option B — Provision new monitoring resources with `azd`

For a greenfield setup (new Log Analytics workspace + Application Insights + workbooks):

```powershell
azd auth login
azd env new <environment-name>
# set values in .azure/<environment-name>/.env (see .azure/.env.example)
azd up
```

`azd` reads parameter values from [infra/main.parameters.json](infra/main.parameters.json), which maps to the environment variables documented in [.azure/.env.example](.azure/.env.example).

## Deployment outputs

Both paths return:

- `workspaceResourceId`
- `appInsightsResourceId`
- `platformDevWorkbookResourceId`
- `governanceWorkbookResourceId`

Open either workbook from **Application Insights → Workbooks**, or directly by resource ID.

## What you'll see

| Section | Signal |
| --- | --- |
| Summary KPIs | Agent runs, active agents, failure rate, p95 latency, total tokens, tool calls |
| Agent activity | `invoke_agent` runs per agent and over time |
| Workload | `chat` (model) and `execute_tool` (tool) calls per agent |
| Token usage | Input vs. output tokens per agent and per model (from `chat` spans) |
| Performance | Agent run p50/p95 latency, model latency over time |
| Reliability | Errors by agent, failed dependencies, exceptions |

Use the **TimeRange** pills at the top to rescope every tile.

## Repository layout

```
azure.yaml                 # azd project definition
infra/                     # Bicep modules (monitoring, diagnostics, workbooks)
workbooks/                 # Workbook definitions deployed as serializedData
docs/                      # Prerequisites and deployment/validation guides
queries/                   # Reference KQL library
```

## Optional

- **Azure OpenAI diagnostics.** Pass `cognitiveServicesAccountName=<account>` to route Azure OpenAI resource logs/metrics into the same workspace. Skipped automatically when omitted.
- **Shared viewer access.** Pass `sharedViewerPrincipalObjectIds` to grant Reader on the workbooks.
