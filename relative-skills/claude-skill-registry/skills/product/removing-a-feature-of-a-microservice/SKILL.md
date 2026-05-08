---
name: Removing a Feature of a Microservice
description: Removes a configuration property, functional endpoint, event source, event sink, web handler endpoint, ticker or metric, from a microservice. Use when explicitly asked by the user to remove a feature of a microservice.
---

## Workflow

Copy this checklist and track your progress:

```
Removing a part of a microservice:
- [ ] Step 1: Remove Definition From service.yaml
- [ ] Step 2: Remove Implementation
- [ ] Step 3: Remove Test
- [ ] Step 4: Remove Unused Custom Types
- [ ] Step 5: Update Boilerplate code
- [ ] Step 6: Document the Microservice
```

#### Step 1: Remove Definition From `service.yaml`

Remove the definition from `service.yaml`.

#### Step 2: Remove Implementation

Remove any implementation code from `service.go`.

#### Step 3: Remove Test

Remove the corresponding test fom `service_test.go`.

#### Step 4: Remove Unused Custom Types

If the deleted definition was using non-primitive custom types that are no longer used elsewhere, remove the definition of the unused types from the API directory.

#### Step 5: Update Boilerplate Code

Run `go generate` to update the boilerplate code.

#### Step 6: Update Documentation

Update the microservice's local `AGENTS.md` to reflect the removal.
