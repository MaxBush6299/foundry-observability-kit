# Foundry Agent Observability Starter Kit — Plan

**Owner:** Max Bush
**Created:** 2026-07-02
**Status:** Brainstorm captured — pre-build. No artifacts generated yet.

## Goal
A reusable "observability starter kit" that Max can deploy alongside any Azure AI
Foundry demo to answer customer questions about **governance and traceability** for
Foundry agents. Customers should also be able to **self-deploy** it into their own
subscription in ~10 minutes.

## Scope decisions (locked)
- **Primary buyer:** Platform / Developer (hero experience).
- **Secondary buyer:** Security / Governance (companion pack, same data layer).
- **Coverage:** Foundry **Agent Service** + **model deployments** (Azure OpenAI / Foundry models).
- **Multi-agent:** first-class from v1 (agent-to-agent handoffs, correlation across agents).
- **Deploy vehicle:** `azd up` (Bicep under the hood). Deploy-to-Azure button optional later.
- **Cost table:** parameterized (customer edits a model→price map; not hardcoded).
- **Schema:** verified against Microsoft Learn 2026-07-02 (see Verified Schema below).

## Verified schema (grounded 2026-07-02, Microsoft Learn)
### Foundry Agent tracing (OpenTelemetry GenAI conventions → Application Insights)
- Traces land in App Insights via the Foundry project's connected AI resource.
- Span operations (`gen_ai.operation.name`): `invoke_agent`, `execute_tool`, `chat`.
  - Note: Foundry Agent Service requires the top span to be `invoke_agent`.
- Key span attributes:
  - `gen_ai.agent.id`, `gen_ai.agent.name`, `gen_ai.agent.description`
  - `gen_ai.conversation.id`  ← multi-agent / thread correlation key
  - `gen_ai.provider.name`, `gen_ai.request.model`
  - `gen_ai.tool.name`, `gen_ai.tool.definitions`
  - `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`
  - `gen_ai.input.messages`, `gen_ai.output.messages`
- App Insights query surfaces: `dependencies`, `requests`, `traces`, `customEvents`,
  `exceptions` (classic schema) / `AppDependencies`, `AppRequests`, `AppTraces`,
  `AppEvents`, `AppExceptions` (workspace-based Log Analytics schema).
  ACTION at build: confirm which schema the kit targets (default: workspace-based).

### Model deployments (Azure OpenAI / Cognitive Services) — diagnostic settings
- Resource-log categories: `RequestResponse`, `Audit`, `Trace`, `AzureOpenAIRequestUsage`.
  - Land in `AzureDiagnostics` (or resource-specific table) in Log Analytics.
- Platform metrics: `AzureOpenAIRequests`, `ProcessedPromptTokens`, `GeneratedTokens`,
  `ProcessedInferenceTokens`, `TokenTransaction` (+ latency / rate-limit metrics).

## Proposed repo structure
```
observability-starter-kit/
├── azure.yaml                 # azd project definition
├── infra/                     # Bicep
│   ├── main.bicep             # orchestrator; params: reuse-existing vs create
│   ├── diagnostics.bicep      # diagnostic settings on AOAI/Foundry -> Log Analytics
│   ├── app-insights.bicep     # AI resource + Foundry project connection
│   └── workbooks.bicep        # deploy workbooks as ARM resources
├── workbooks/
│   ├── platform-dev.workbook  # Pack A (hero)
│   └── governance.workbook    # Pack B (companion)
├── queries/                   # standalone copy-pasteable KQL library
├── alerts/                    # optional scheduled-query alerts
└── docs/                      # prerequisites + 10-min self-deploy guide
```

## Pack A — Platform/Dev dashboard (hero)
| Tile | Question | Signal |
| --- | --- | --- |
| Fleet health | Agents up? error rate/latency by agent | requests/dependencies |
| Trace waterfall | One run end-to-end: prompt→tools→model→output | gen_ai.* spans |
| Multi-agent map | Agent-to-agent handoffs within a conversation | gen_ai.conversation.id + agent.id |
| Tool-call inspector | Which tools fired, args, failures, latency | execute_tool spans |
| Token & throughput | Tokens in/out by model & agent; TPM trend | gen_ai.usage.* |
| Model deployment health | Per-deployment latency, 429s, capacity headroom | AOAI metrics |
| RAG diagnostics | Retrieval count, empty-retrieval %, sources | spans |
| Error drilldown | Top exceptions + correlated trace ID | exceptions |
| Cost estimator | Tokens → $ via parameterized price map | usage + workbook param |

## Pack B — Governance/Security dashboard (companion)
| Tile | Question | Signal |
| --- | --- | --- |
| Who ran what | Caller identity, agent, timestamp audit grid | resource logs / Entra |
| Content Safety / RAI | Filter hits by category, blocked rate | Content Safety logs |
| Groundedness & eval | Quality scores over time; low-groundedness runs | evaluation events |
| Data-access trail | Which sources/tools touched which data | spans |
| Config / policy drift | Deployment SKU, region, network posture | Azure Resource Graph |
| Anomaly flags | Token/error/off-hours spikes | KQL over metrics |

## Multi-agent handling (v1 requirement)
- Correlate on `gen_ai.conversation.id` to reconstruct a full multi-agent conversation.
- Group/segment spans by `gen_ai.agent.id` / `gen_ai.agent.name` to show handoffs.
- Trace explorer must render nested `invoke_agent` → `execute_tool` → `chat` across agents.
- Vertical drill: agent run → model deployment → token cost → 429 (ties Pack A tiles together).

## Readiness / honesty gate
- Both workbooks include a **readiness tile**: KQL that reports which signals are present
  (traces? token metrics? content-safety logs?) so self-deploy shows an honest state
  instead of empty tiles.
- Prereqs the deploy must set or check:
  - Foundry tracing enabled + App Insights connected to the project.
  - Diagnostic settings on AOAI/Foundry resource → Log Analytics (Bicep can set these).
  - Optional (governance): Content Safety logging + evaluation runs.

## Open items to resolve at build time
1. Confirm App Insights schema target (classic vs workspace-based) — default workspace-based.
2. Finalize `azd` env params: reuse existing App Insights / Log Analytics vs create new.
3. Price-map parameter format (JSON param in workbook).
4. Whether to ship optional scheduled-query alerts in v1 or defer.

## Suggested v1 cut
Platform/Dev workbook + shared Bicep/azd + readiness tile + multi-agent trace explorer.
Governance workbook ships as a parallel file reusing the same data layer ("flip the tab").

## Next step (when we move from brainstorm to build)
- Re-verify any drift-prone schema names, scaffold `azd` project, author KQL library first
  (queries are the substance), then wrap into workbook JSON, then Bicep, then docs.
