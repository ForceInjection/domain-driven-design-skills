---
name: hardened-outline-driven-development
description: Automated validation orchestration across proof, spec, type, contract, and test artifacts with configurable precedence and gating. This skill provides both reference documentation AND execution capabilities for the full PLAN -> CREATE -> EXECUTE -> REPORT workflow.
---

# Hardened Outline-Driven Development Skill

## Capability

Outline-Strong orchestrates multi-layer validation pipelines, coordinating proofs, specifications, types, contracts, and tests with configurable precedence and gating rules.

- **Multi-layer Validation**: Coordinate 5 validation layers
- **Configurable Precedence**: Custom validation order
- **Gating Rules**: Upstream failures block downstream stages
- **Stop-on-fail or All-errors**: Flexible execution modes

---

## When to Use

- Projects requiring comprehensive validation
- Multi-paradigm verification (proofs + specs + tests)
- CI/CD pipelines with validation gates
- Coordinating multiple verification tools
- Ensuring layered correctness guarantees

---

## Workflow Overview

```nomnoml
[<start>Requirements] -> [Phase 1: PLAN]
[Phase 1: PLAN|
  Analyze validation needs
  Design layer architecture
  Configure gating rules
] -> [Phase 2: CREATE]
[Phase 2: CREATE|
  Generate artifacts per layer
  Proofs, specs, contracts, tests
] -> [Phase 3: EXECUTE]
[Phase 3: EXECUTE|
  Run validation chain
  Apply gating rules
] -> [Phase 4: REPORT]
[Phase 4: REPORT|
  Summarize results
  Per-layer coverage
] -> [<end>Success]
```

---

## Phase 1: PLAN (Validation Chain Design)

### Process

1. **Understand Requirements**
   - Identify validation needs across all layers
   - Use sequential-thinking to plan validation cascade
   - Map requirements to appropriate validation types

2. **Artifact Detection**
   ```bash
   fd -e lean -e v -e dfy -e idr $ARGUMENTS              # Proofs
   fd -e qnt -e tla -e als $ARGUMENTS                     # Specifications
   rg '#\[pre\(|z\.object|@pre|checkArgument' $ARGUMENTS  # Contracts
   fd -g '*test*' -g '*spec*' -e ts -e py -e rs $ARGUMENTS # Tests
   ```

3. **Design Validation Chain**
   - Design artifacts for each applicable layer
   - Plan validation order and dependencies
   - Configure gating between stages

### Layer 0: Static Verification (PREFER FIRST)

**Hierarchy**: `Static Assertions > Test/Debug > Runtime Contracts`

| Language   | Tool                      | Command                     |
| ---------- | ------------------------- | --------------------------- |
| C++        | `static_assert`, Concepts | `g++ -std=c++20`            |
| TypeScript | `satisfies`, `as const`   | `tsc --strict`              |
| Python     | `assert_type`, `Final`    | `pyright --strict`          |
| Java       | Checker Framework         | `javac -processor nullness` |
| Rust       | `static_assertions` crate | `cargo check`               |
| Kotlin     | contracts, sealed         | `kotlinc -Werror`           |

**Principle**: Verify at compile-time before runtime. No runtime contracts for statically provable properties.

### Validation Chain Template

```
Layer 0: STATIC VERIFICATION (Compile-Time)
+-- Target: Source code type annotations
+-- Tool: Type checker + static_assert
+-- Gate: Must pass before Layer 1

Layer 1: PROOF (Highest Assurance)
+-- Target: .outline/proofs/
+-- Tool: Lean 4 / Idris 2
+-- Gate: Must pass before Layer 2

Layer 2: SPECIFICATION
+-- Target: .outline/specs/
+-- Tool: Quint
+-- Gate: Must pass before Layer 3

Layer 3: TYPE CHECKING
+-- Target: Source code
+-- Tool: Language type system
+-- Gate: Must pass before Layer 4

Layer 4: CONTRACTS
+-- Target: .outline/contracts/
+-- Tool: Language-specific
+-- Gate: Must pass before Layer 5

Layer 5: TESTS
+-- Target: .outline/tests/
+-- Tool: Test framework
+-- Final validation layer
```

---

## Phase 2: CREATE (Generate Artifacts)

### Setup

```bash
mkdir -p .outline/{proofs,specs,contracts,tests}
```

Generate artifacts per layer using respective skills:

- **Proofs**: See proof-driven skill
- **Specifications**: See validation-first skill
- **Contracts**: See design-by-contract skill
- **Tests**: See test-driven skill

---

## Phase 3: EXECUTE (Validation Chain)

### Configuration

```bash
ORDER="proof,spec,type,contract,tests"       # Default order
ORDER="${VALIDATION_ORDER:-$ORDER}"          # Custom order
STOP_ON_FAIL=${STOP_ON_FAIL:-true}           # Execution mode
```

### Stage Execution

#### Stage 1: Proof Validation

```bash
run_proof_stage() {
  echo "=== Stage 1: PROOF ==="
  if fd -e lean .outline/proofs | grep -q .; then
    cd .outline/proofs && lake build || return 13
    rg '\bsorry\b' . && return 13
  fi
  return 0
}
```

#### Stage 2: Specification Verification

```bash
run_spec_stage() {
  echo "=== Stage 2: SPECIFICATION ==="
  if fd -e qnt .outline/specs | grep -q .; then
    quint typecheck .outline/specs/*.qnt || return 13
    quint verify .outline/specs/*.qnt || return 13
  fi
  return 0
}
```

#### Stage 3: Type Checking

```bash
run_type_stage() {
  echo "=== Stage 3: TYPE CHECKING ==="
  test -f tsconfig.json && tsc --noEmit || return 13
  test -f Cargo.toml && cargo check || return 13
  fd -e py . | grep -q . && pyright . || return 13
  return 0
}
```

#### Stage 4: Contract Verification

```bash
run_contract_stage() {
  echo "=== Stage 4: CONTRACTS ==="
  if fd . .outline/contracts | grep -q .; then
    unset CONTRACTS_DISABLE
    test -f Cargo.toml && cargo test
    test -f package.json && npm test
    test -f pyproject.toml && pytest
  fi
  return 0
}
```

#### Stage 5: Test Execution

```bash
run_test_stage() {
  echo "=== Stage 5: TESTS ==="
  test -f package.json && npm test || return 13
  test -f Cargo.toml && cargo test || return 13
  test -f pyproject.toml && pytest || return 13
  test -f go.mod && go test ./... || return 13
  return 0
}
```

### Orchestration Loop

```bash
execute_chain() {
  local first_failure=0
  for stage in ${ORDER//,/ }; do
    case $stage in
      proof)    run_proof_stage ;;
      spec)     run_spec_stage ;;
      type)     run_type_stage ;;
      contract) run_contract_stage ;;
      tests)    run_test_stage ;;
    esac
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
      [ $first_failure -eq 0 ] && first_failure=$exit_code
      [ "$STOP_ON_FAIL" = "true" ] && break
    fi
  done
  return $first_failure
}
```

---

## Commands Reference

### ols-validate

Execute full validation chain in precedence order.

**Usage**: `ols-validate [--order ORDER] [--stop-on-fail] [--all-errors]`

### ols-check

Detect validation artifacts and report coverage.

**Usage**: `ols-check [--stage STAGE] [--missing] [--summary]`

### ols-override

Configure validation order and behavior.

**Usage**: `ols-override --order "type,contract,tests" [--continue-on-error]`

---

## Exit Codes

| Code | Meaning                 | Action                      |
| ---- | ----------------------- | --------------------------- |
| 0    | All stages pass         | Validation complete         |
| 1    | Precondition violation  | Fix contract preconditions  |
| 2    | Postcondition violation | Fix contract postconditions |
| 3    | Invariant violation     | Fix contract invariants     |
| 11   | No artifacts            | Run plan phase first        |
| 13   | Stage failed            | Fix issues in failed stage  |
| 15   | Config error            | Check ORDER, valid stages   |

---

## Gating Mechanism

| Upstream | Gates    | Rationale                       |
| -------- | -------- | ------------------------------- |
| proof    | spec     | Proofs validate core properties |
| spec     | type     | Specs define valid behaviors    |
| type     | contract | Types catch basic errors        |
| contract | tests    | Contracts validate interfaces   |

**Type -> Contract**: Type errors prevent contract checking
**Contract -> Tests**: Contract violations prevent test execution

---

## Precedence Override

### Environment Variable (Highest Priority)

```bash
export VALIDATION_ORDER="type,contract,tests"
ols-validate
```

### Command-Line Flag

```bash
ols-validate --order "spec,type,tests"
```

### Configuration File (Lowest Priority)

```toml
# .ols-config.toml
[validation]
order = ["type", "contract", "tests"]
stop_on_fail = true
```

---

## Validation Order Options

```
Default: proof > spec > type > contract > tests

Custom orders:
- Fast feedback: tests > type > contract > spec > proof
- Balanced: type > contract > tests > spec > proof
- Formal-first: proof > type > spec > contract > tests
```

---

## Stop-on-First-Fail Logic

### Default Mode (Stop on Fail)

```bash
for stage in $STAGES; do
    run_stage "$stage"
    [ $? -ne 0 ] && exit $?
done
```

### All-Errors Mode

```bash
FIRST_FAILURE=0
for stage in $STAGES; do
    run_stage "$stage"
    [ $? -ne 0 ] && [ $FIRST_FAILURE -eq 0 ] && FIRST_FAILURE=$?
done
exit $FIRST_FAILURE
```

---

## Integration Patterns

### Pre-Commit Hook

```bash
#!/bin/bash
ols-validate --order "type,contract" --stop-on-fail
```

### CI/CD Pipeline

```yaml
- name: Full Validation
  run: ols-validate --all-errors

- name: Fast Validation
  run: ols-validate --order "type,tests" --stop-on-fail
```

### Watch Mode

```bash
while inotifywait -r -e modify,create,delete .; do
    ols-validate --order "type,contract" --stop-on-fail
done
```

---

## Configuration Schema

```toml
# .ols-config.toml
[validation]
order = ["type", "contract", "tests"]
stop_on_fail = true
continue_on_error = false
log_level = "info"

[validation.timeouts]
proof = 300
spec = 180
type = 60
contract = 120
tests = 300
```

---

## Safety Guarantees

1. **Determinism**: Same inputs -> same outputs
2. **Idempotency**: Multiple runs safe
3. **Isolation**: Stages don't interfere
4. **Atomicity**: Each stage passes or fails completely
5. **No side effects**: Validation doesn't modify code

---

## Best Practices

1. Start with `--order "type,tests"` (minimal validation)
2. Add contracts incrementally: `--order "type,contract,tests"`
3. Use stop-on-fail in development (fast feedback)
4. Use all-errors in CI (comprehensive reports)
5. Document order overrides in `.ols-config.toml`
6. Monitor execution time, optimize slow stages
7. Version validation order with code

---

## Execution Flow Diagram

```nomnoml
[<start>Start] -> [Load Config]
[Load Config] -> [Parse Order]
[Parse Order] -> [Stage Loop]
[Stage Loop] -> [Detect Artifacts]
[Detect Artifacts] found -> [Execute Stage]
[Detect Artifacts] not found -> [Skip Stage]
[Execute Stage] pass -> [Next Stage?]
[Execute Stage] fail, stop-on-fail -> [Report Failure]
[Execute Stage] fail, all-errors -> [Log & Continue]
[Skip Stage] -> [Next Stage?]
[Next Stage?] yes -> [Stage Loop]
[Next Stage?] no -> [Report Summary]
[Report Failure] -> [<end>Exit Code]
[Report Summary] -> [<end>Exit Code]
```
