---
name: aws-cli
description: |
  CLI-first AWS orchestration skill for Lambda, ECS/Fargate, and S3 workflows rooted in `.☁️` runbooks.
version: 0.1.0
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, codebase_investigator, web_fetch, write_todos
---

## Why This Skill Exists
Early proto helpers (`b00t-aws-tools`) duplicated SDK logic yet shipped no usable tools. This skill re-centers AWS work on the official `aws` CLI plus the canonical `_b00t_/clouds.云☁️/aws.🦉.云☁️` sketches, ensuring every agent follows the same ceremony.

## When To Load
- Deploy/invoke a Lambda (`lambda.invoke.sketch.sh`).
- Publish an image to ECR and run it on ECS/Fargate (`ecs.fargate.sketch.sh`).
- Inspect/download objects from S3 buckets (`s3.bucket.sketch.sh`).
- Bridge into AWS MCP servers after credentials are verified.

## Operating Instructions
1. `b00t learn aws` → review the `.☁️` README for prerequisites and environment variables.
2. Export account-specific env vars (bucket names, subnet IDs, function names). Never hardcode them.
3. Run the appropriate sketch script; capture JSON receipts/log output for the Operator and stash sensitive artifacts in the secure storage path, not git.
4. If an official AWS MCP server suffices, configure it per https://github.com/awslabs/mcp instead of writing new helpers.

## Melvins (🤓)
- **CLI SSOT**: `aws sts get-caller-identity` is the authoritative source for Account/ARN context.
- **.☁️ Canon**: All cloud runbooks live under `_b00t_/clouds.云☁️/…`; keep additions there.
- **No stray secrets**: env vars or datums supply parameters; scripts stay generic.
- **Verify outputs**: Lambda/ECS scripts emit receipts—read them before declaring success.

## References
- `_b00t_/clouds.云☁️/aws.🦉.云☁️/README.md`
- `_b00t_/clouds.云☁️/aws.🦉.云☁️/lambda.invoke.sketch.sh`
- `_b00t_/clouds.云☁️/aws.🦉.云☁️/ecs.fargate.sketch.sh`
- `_b00t_/clouds.云☁️/aws.🦉.云☁️/s3.bucket.sketch.sh`
- https://github.com/awslabs/mcp
