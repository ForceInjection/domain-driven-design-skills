---
name: context-routing
description: 'Determines minimal context and routes tasks to the correct prompts, agents and tools.'
metadata:
  id: ce.skill.context-routing
  tags: [routing, context-min, context-debug]
  inputs:
    files: [ce.manifest.jsonc, .github/ce/routing-rules.md]
    concepts: [least-context]
    tools: []
  outputs:
    artifacts: []
    files: []
    actions: [select-files, select-prompt, select-handoff]
  dependsOn:
    artifacts: []
    files: [.github/ce/routing-rules.md]
  related:
    artifacts: [ce.prompt.debug-routing]
    files: []
---

# Context Routing Skill

The context-routing skill applies deterministic rules to decide which files, prompts, skills and
tools are necessary to answer a user request. Use this skill to minimise context loading and
avoid hallucinations.

## Steps

1. **Load the manifest.** Parse `ce.manifest.jsonc` to build an index of available artifacts,
   their tags, inputs, outputs and dependencies. Validate that the manifest is well-formed.

2. **Analyse signals.** Inspect the user’s request to detect intent, scope, risk and
   actionability signals (e.g. planning, implementation, review, debug). Use the routing
   rules documented in `.github/ce/routing-rules.md` to map signals to candidate targets.

3. **Select authoritative documents.** Always include the core project documents
   (`PRODUCT.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`) when relevant to the detected scope.
   Use tags and dependencies to decide which docs are required.

4. **Pick the primary prompt or skill.** Based on the intent signal, select one prompt or
   skill whose tags match the intent (e.g. `planning` → `create-plan.prompt.md`). Avoid
   loading multiple prompts for a single request.

5. **Resolve dependencies.** For each selected artifact, load its `dependsOn` files and
   artifacts. Ensure no more than the maximum configured in the manifest defaults
   (`maxFilesToLoad`) are included unless explicitly requested by the user.

6. **Return the route plan.** Produce a list of target files, skills, prompts and tools to be
   loaded, along with a brief justification for each selection. If the plan includes any
   action that modifies files or executes commands, ensure that a validation task is also
   included.

7. **Support debugging.** When invoked via the `debug-routing` prompt, explain why each
   artefact was selected and suggest any metadata or tag updates that would improve future
   routing.

This skill makes routing decisions transparent and reproducible, enabling precise control over
the AI’s context window and improving answer quality.
