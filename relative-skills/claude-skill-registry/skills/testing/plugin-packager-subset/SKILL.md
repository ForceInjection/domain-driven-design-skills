---
name: plugin-packager-subset
description: Package language-specific subsets of claudefiles
---

# Subset Packaging

## Go-Only

```json
{
  "name": "claudefiles-go",
  "version": "1.0.0",
  "commands": "./commands/golang/",
  "agents": "./agents/golang/",
  "skills": "./skills/golang/",
  "hooks": "./hooks/golang/hooks.json"
}
```

## TypeScript-Only

```json
{
  "name": "claudefiles-typescript",
  "version": "1.0.0",
  "commands": "./commands/typescript/",
  "agents": "./agents/typescript/"
}
```

## Python-Only

```json
{
  "name": "claudefiles-python",
  "version": "1.0.0",
  "agents": "./agents/python/"
}
```

## Security-Only

```json
{
  "name": "claudefiles-security",
  "version": "1.0.0",
  "hooks": "./hooks/security/hooks.json"
}
```

## Component Matrix

| Want | Include |
|------|---------|
| Go dev | agents/golang, commands/golang, skills/golang, hooks/golang |
| TS dev | agents/typescript, commands/typescript |
| Python | agents/python |
| Security | hooks/security |
| Docs | agents/docs, commands/docs |
