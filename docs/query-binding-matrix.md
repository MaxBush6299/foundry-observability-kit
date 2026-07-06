# Query to Workbook Binding Matrix

## Shared query assets
| Query file | Platform/Dev workbook | Governance workbook | Purpose |
|---|---|---|---|
| queries/shared/readiness-signals.kql | readiness | readiness | Required signal gate status |
| queries/shared/readiness-summary.kql | readiness-summary | readiness-summary | Landing readiness by audience |
| queries/shared/correlation-base.kql | (indirect, operational queries) | (indirect) | Multi-agent normalization base |
| queries/shared/price-map-normalization.kql | directional-cost (indirect) | n/a | Directional cost normalization |

## Platform/Dev bindings
| Query file | Workbook item |
|---|---|
| queries/platform-dev/fleet-health.kql | fleet-health |
| queries/platform-dev/trace-waterfall.kql | trace-waterfall |
| queries/platform-dev/multi-agent-map.kql | multi-agent-map |
| queries/platform-dev/tool-call-inspector.kql | tool-call-inspector |
| queries/platform-dev/token-throughput.kql | token-throughput |
| queries/platform-dev/model-deployment-health.kql | model-deployment-health |
| queries/platform-dev/cost-estimator.kql | directional-cost |

## Governance bindings
| Query file | Workbook item |
|---|---|
| queries/governance/who-ran-what.kql | who-ran-what |
| queries/governance/safety-outcomes.kql | safety-outcomes |
| queries/governance/access-trail.kql | access-trail |
| queries/governance/anomaly-flags.kql | anomaly-flags |
| queries/governance/config-policy-drift.kql | config-policy-drift |
