---
name: outline-cli
description: Allow droids to interact with Outline Wiki via the outlinectl CLI (auth, collections, docs) with automation-friendly JSON output.
---

This skill enables droids to operate an Outline Wiki instance through the included .NET CLI (`Outlinectl.Cli`).

Use this skill for:
- Authenticating against an Outline instance
- Listing collections
- Searching, getting, creating, updating, and exporting documents

For automation, prefer `--json` output and non-interactive commands.

## Configuration
This skill is **environment-first**. Droids should read configuration from environment variables and only pass explicit CLI options when overriding defaults.

- `OUTLINE_BASE_URL` (recommended): Outline instance URL (e.g. `https://docs.example.com`)
- `OUTLINE_API_TOKEN` (recommended): Outline API token
- `profile` (optional): Defaults to `default` (used for local config/credential store)

Notes:
- The CLI currently does **not** read a default collection ID from environment variables.
- For `docs search`, provide `--collection-id` and/or `--parent-id` explicitly when you need scoped results.
- when parent-id is provided the user is looking for a sub-document, search all sub-documents of the parent-id for the information the user is looking for.

## Safety and Secrets
- Never print or log API tokens.
- Default login is environment-based (see below). Use `--token-stdin` when you cannot set `OUTLINE_API_TOKEN` safely (e.g., piping from a secret manager).
- For runtime auth (API calls), `OUTLINE_API_TOKEN` overrides the stored token.

## How to Run

From the repo (recommended for droids working in this workspace):

```powershell
cd 1-Presentation\Outlinectl.Cli
dotnet run -- --help
```

Notes:
- Everything after `--` is passed to the CLI.
- Global options are supported on all commands: `--json`, `--quiet`, `--verbose`.

## Output Contract (JSON Mode)

When `--json` is set, stdout is a single JSON envelope:

```json
{
	"ok": true,
	"command": "docs.search",
	"data": { },
	"meta": { "durationMs": 0, "version": "1.0.0" }
}
```

On errors:

```json
{
	"ok": false,
	"command": "docs.get",
	"error": { "code": "", "message": "...", "hint": "..." },
	"meta": { "durationMs": 0, "version": "1.0.0" }
}
```

## Exit Codes (Practical Handling)
- `0`: Success
- `2`: Invalid input / missing required values (e.g., missing token)
- `3`: Not logged in (local status check)
- `4`: Document not found / get failed
- `10`: Unknown/unhandled error
- `130`: Cancelled (Ctrl+C)

## Core Workflows

### 1) Authenticate First (Required)

Before running **any** commands, the agent MUST authenticate and confirm it succeeded.

Success criteria:
- Exit code is `0`.
- If `--json` is used, stdout JSON envelope has `"ok": true` for `auth.login`.

Default (environment-first, non-interactive):

# If --base-url and --token are omitted, outlinectl will pull from OUTLINE_BASE_URL and OUTLINE_API_TOKEN.
dotnet run --project .\\1-Presentation\\Outlinectl.Cli -- auth login --profile default --json
```

Then immediately verify local auth status:

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- auth status --json
```
If the agent fails to authenticate, it MUST exit and inform the user that it failed to authenticate.

### 2) Verify Auth Status

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- auth status --json
```

### 3) List Collections

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- collections list --limit 50 --offset 0 --json
```

### 4) Search Documents

```powershell
# Scope search to a collection (and optionally a parent document subtree).
dotnet run --project .\1-Presentation\Outlinectl.Cli -- docs search --query "policy" --collection-id "<COLLECTION_ID>" --parent-id "<PARENT_DOC_ID>" --limit 10 --offset 0 --json
```

Notes:
- `--query` is required by the CLI.
- For automation, treat `--collection-id` and `--parent-id` as required inputs if you don't have these values ask the user for them.

### 5) Get Document

Automation / structured:

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- docs get --id "<DOC_ID>" --format json --json
```

Human-readable markdown (stdout is raw markdown text; do NOT use `--json`):

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- docs get --id "<DOC_ID>" --format markdown
```

### 6) Create Document

From stdin (preferred for large content):

```powershell
@"
# Title

Body goes here.
"@ | dotnet run --project .\\1-Presentation\\Outlinectl.Cli -- docs create --title "My Doc" --stdin --json
```

From file:

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- docs create --title "My Doc" --collection-id "<COLLECTION_ID>" --file ".\doc.md" --json
```

### 7) Update Document

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- docs update --id "<DOC_ID>" --title "New Title" --file ".\updated.md" --json
```

### 8) Export Document

Exports markdown files to a directory (optionally including descendants):

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- docs export "<DOC_ID>" --output-dir ".\export" --subtree --json
```

## Interactive Shell (Optional)

Use the shell only for manual exploration; avoid it for automation:

```powershell
dotnet run --project .\1-Presentation\Outlinectl.Cli -- shell
```

Inside the shell, run commands as you would normally:

```text
docs search --query "onboarding" --json
auth status --json
exit
```

