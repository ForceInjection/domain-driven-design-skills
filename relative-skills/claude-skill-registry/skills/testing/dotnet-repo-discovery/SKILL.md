---
name: dotnet-repo-discovery
description: Discover the primary .sln, list projects, and emit a solution map with target frameworks and test flags.
---

# dotnet-repo-discovery

Locate the primary solution file, enumerate projects, extract target frameworks and test flags, and generate a solution map artifact.

## Outputs
- `artifacts/codex/solution-map.json`
- `artifacts/codex/solution-map.md`

## Requirements
- `dotnet` CLI
- `rg` (ripgrep)
- `python3` (bash script only)
- PowerShell (`pwsh`) for Windows

## Run

Bash:
```bash
bash .codex/skills/dotnet-repo-discovery/scripts/discover-dotnet-repo.sh
```

PowerShell:
```powershell
pwsh -File .codex/skills/dotnet-repo-discovery/scripts/discover-dotnet-repo.ps1
```

The scripts prefer a solution in the repo root. If none exists, they pick the shortest path to a `.sln` file.
