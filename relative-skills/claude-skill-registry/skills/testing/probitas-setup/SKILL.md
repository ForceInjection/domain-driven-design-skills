---
name: probitas-setup
description: Probitas project setup and installation. Use when initializing Probitas, setting up E2E testing, or installing probitas CLI.
---

## Instructions

Run `/probitas-init` command to initialize the project.

If `probitas` CLI not found, install first:

```bash
# Shell installer
curl -fsSL https://raw.githubusercontent.com/probitas-test/probitas/main/install.sh | bash

# Or Homebrew
brew tap probitas-test/tap && brew install probitas
```

## Created Files

- `probitas/example.probitas.ts` - Sample scenario
- `probitas.jsonc` - Configuration
