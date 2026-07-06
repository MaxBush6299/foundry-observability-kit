# Configuration Hardcoding Audit Checklist

## Goal
Ensure no environment-specific values are hardcoded and all deploy-time variables are parameterized.

## Checklist
- [ ] No subscription IDs hardcoded in Bicep modules.
- [ ] No tenant IDs hardcoded in workbook files.
- [ ] Monitoring resources can be created or reused by parameter.
- [ ] Cognitive services diagnostic target is provided as parameter.
- [ ] Shared viewer principal IDs are parameterized.
- [ ] Model price map is externalized and assumption-labeled.
- [ ] Retention days are parameterized and enforce minimum 30.

## Review Scope
- infra/main.bicep
- infra/monitoring.bicep
- infra/diagnostics.bicep
- infra/workbooks.bicep
- workbooks/platform-dev.workbook
- workbooks/governance.workbook
- .azure/.env.example
