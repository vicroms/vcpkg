---
name: analyze-ci-failures
description: >
  Analyze vcpkg Azure DevOps CI failures. Downloads logs, identifies regression root causes,
  generates a report by package and triplet.

  USE FOR: CI failure analysis, regression triage, log diagnosis.

  DO NOT USE FOR: general coding, creating ports, modifying portfiles.

  **UTILITY SKILL** INVOKES: Azure DevOps REST API, PowerShell.
---

# vcpkg CI Failures Analyzer

## When to Use

- Investigating CI failures on Azure DevOps
- Identifying regressions in a PR or scheduled build
- Triaging root causes before assigning bugs

## Overview

Fetches build metadata and failure logs via Azure DevOps REST API, cross-references with baselines, produces a regression report.

## MCP Tools

| Tool | Purpose |
|------|---------|
| `github-mcp-server-get_file_contents` | Read baseline files |

## Prerequisites

- **GitHub MCP server** — needed for PR URL input

## Workflow

1. **Parse input** — Extract `buildId` or resolve PR URL. See [references/azure-devops-api.md](references/azure-devops-api.md).
2. **Fetch metadata** — Build info and timeline; find failed jobs.
3. **Scan step logs (critical)** — For each failed job, find the `"*** Test Modified Ports"` task (`type == "Task"`) and fetch its log via `log.url`. REGRESSION lines are at the **end** after `REGRESSIONS:`. Use this exact PowerShell — do not modify the regex:
   ```powershell
   $logText = Invoke-RestMethod "$($task.log.url)?api-version=7.0"
   $regressions = $logText -split "`n" | Where-Object { $_ -match 'REGRESSION:' }
   ```
   This captures **all** regression types including:
   - `failed with BUILD_FAILED` / `FILE_CONFLICTS` / `POST_BUILD_CHECKS_FAILED`
   - `is marked as fail but one dependency is not supported` (these are baseline-configuration regressions — the baseline entry is stale because a dependency dropped support for that triplet; they must be reported with a recommendation to update the baseline)
   
   `FILE_CONFLICTS` only appear in step logs, never in artifacts. **Report every REGRESSION line in the output** — do not filter or skip any.
4. **Download logs** — `Invoke-WebRequest` for artifact ZIPs (not `web_fetch`). Focus on artifacts named `"failure logs for {triplet}"`. Start with smallest artifacts. Extract ZIPs into `ci-failure-analysis/{scope}/logs/{triplet}/` where `{scope}` is `ci-{buildId}` for scheduled/manual builds or `pr-{prNumber}` for PR builds. Remove ZIPs after extraction.
5. **Analyze** — For each failing port, read `stdout-{triplet}.log` last lines first. Classify per [references/vcpkg-failure-patterns.md](references/vcpkg-failure-patterns.md).
6. **Baselines** — Check both `ci.baseline.txt` and `ci.feature.baseline.txt`.
7. **Report** — Your response **must be the complete report** (not a summary). Save the same content to `ci-failure-analysis/{scope}/report.md`. Format per [references/report-template.md](references/report-template.md). For each port, list every affected triplet individually and use exact failure type from REGRESSION lines (e.g. `BUILD_FAILED`, `FILE_CONFLICTS`).

## Output Structure

```
ci-failure-analysis/
├── ci-129315/         ← scheduled build
│   ├── report.md
│   └── logs/
│       ├── x64-windows/
│       └── arm64-linux/
└── pr-51202/          ← PR build
    ├── report.md
    └── logs/
```

## Critical Rules

- Use `Invoke-WebRequest` for ZIPs — `web_fetch` can't download binaries
- Artifact type is `PipelineArtifact` — Container API won't work
- Scan step logs first — `FILE_CONFLICTS` only appear there
- Check **both** baseline files
- Never suggest `<=` version constraints or `VCPKG_BUILD_TYPE release`
- Include full build URL in report header: `[{buildNumber}](https://dev.azure.com/vcpkg/public/_build/results?buildId={buildId})`
