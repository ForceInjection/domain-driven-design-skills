---
name: framework-detection
description: Detects Solidity development framework (Foundry, Hardhat, or Hybrid) and adapts workflows accordingly. Use at the start of any Solidity development task to determine which tools and commands to use.
---

# Framework Detection Skill

This skill enables automatic detection of the Solidity development framework being used in a project and adapts workflows accordingly.

## When to Use

Use this skill **at the beginning of any Solidity development workflow** to:
- Detect which framework is configured (Foundry, Hardhat, or Hybrid)
- Determine which commands to use for compilation, testing, deployment
- Adapt agent behavior to framework-specific patterns
- Handle hybrid setups where both frameworks coexist

## Detection Logic

### 1. Foundry Detection

Check for **foundry.toml** in the project root:

```bash
# Foundry indicator
if [ -f "foundry.toml" ]; then
    echo "Foundry detected"
fi
```

**Foundry-specific files:**
- `foundry.toml` - Main configuration file
- `lib/` directory - Dependencies (via git submodules)
- `test/` directory with `.t.sol` files
- `script/` directory for deployment scripts

**Commands:**
- Compile: `forge build`
- Test: `forge test`
- Deploy: `forge script`
- Coverage: `forge coverage`

### 2. Hardhat Detection

Check for **hardhat.config.js** or **hardhat.config.ts** in the project root:

```bash
# Hardhat indicator
if [ -f "hardhat.config.js" ] || [ -f "hardhat.config.ts" ]; then
    echo "Hardhat detected"
fi
```

**Hardhat-specific files:**
- `hardhat.config.js` or `hardhat.config.ts` - Main configuration
- `package.json` with hardhat dependencies
- `node_modules/` directory
- `test/` directory with `.js` or `.ts` files
- `scripts/` directory for deployment

**Commands:**
- Compile: `npx hardhat compile`
- Test: `npx hardhat test`
- Deploy: `npx hardhat run scripts/deploy.js`
- Coverage: `npx hardhat coverage`

### 3. Hybrid Setup Detection

Both frameworks can coexist in the same project:

```bash
# Hybrid indicator
if [ -f "foundry.toml" ] && ([ -f "hardhat.config.js" ] || [ -f "hardhat.config.ts" ]); then
    echo "Hybrid setup detected"
fi
```

**Hybrid workflow strategy:**
- **Primary:** Use Foundry for compilation and testing (faster)
- **Secondary:** Use Hardhat for deployment and verification (better tooling)
- **Flexibility:** Allow agents to choose based on task requirements

## Framework-Specific Workflow Adaptation

### Compilation

```bash
# Foundry
forge build

# Hardhat
npx hardhat compile

# Hybrid (prefer Foundry)
forge build
```

### Testing

```bash
# Foundry
forge test
forge test -vvv              # Verbose
forge test --match-test testName

# Hardhat
npx hardhat test
npx hardhat test --grep "pattern"

# Hybrid
forge test                    # Fast unit tests
npx hardhat test             # Integration tests with JS tooling
```

### Deployment

```bash
# Foundry
forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --broadcast

# Hardhat
npx hardhat run scripts/deploy.js --network mainnet

# Hybrid (prefer Hardhat for deployment)
npx hardhat run scripts/deploy.js --network mainnet
```

### Gas Reporting

```bash
# Foundry
forge test --gas-report

# Hardhat
REPORT_GAS=true npx hardhat test

# Hybrid
forge test --gas-report      # More detailed
```

### Coverage

```bash
# Foundry
forge coverage
forge coverage --report lcov

# Hardhat
npx hardhat coverage

# Hybrid (prefer Foundry)
forge coverage --report lcov
```

## Agent Integration

All agents should **call this skill first** before executing any framework-specific commands:

```markdown
**Framework Detection Process:**

1. Check for foundry.toml → Foundry detected
2. Check for hardhat.config.js/ts → Hardhat detected
3. Both present → Hybrid detected
4. Neither present → Prompt user or initialize
```

### Example Agent Workflow

```markdown
**Step 1: Detect Framework**

I'll first check which framework is configured in this project.

[Uses Bash tool to check for foundry.toml and hardhat.config.*]

**Framework detected:** Foundry

**Step 2: Adapt Commands**

Based on Foundry detection, I'll use:
- Compilation: `forge build`
- Testing: `forge test`
- Coverage: `forge coverage`

[Proceeds with Foundry-specific workflow...]
```

## Hybrid Setup Recommendations

When both frameworks are detected, follow these guidelines:

### Foundry Strengths
- **Fast compilation** (Rust-based)
- **Fast testing** (no JS overhead)
- **Fuzz testing** (built-in)
- **Gas optimization** (detailed reports)
- **Formal verification** (via Forge)

**Use Foundry for:**
- Unit testing
- Gas optimization
- Fuzz testing
- Development iteration (compile/test cycles)

### Hardhat Strengths
- **JavaScript ecosystem** integration
- **Better deployment tooling** (scripts, tasks)
- **Contract verification** (Etherscan, etc.)
- **Mature plugin ecosystem**
- **TypeScript support**

**Use Hardhat for:**
- Deployment scripts
- Contract verification
- Integration with frontend
- Complex deployment workflows
- Network forking

## Error Handling

### No Framework Detected

If neither framework is detected:

```markdown
⚠️ **No Solidity framework detected**

I couldn't find foundry.toml or hardhat.config.js/ts in this project.

Would you like to:
1. Initialize Foundry (`forge init`)
2. Initialize Hardhat (`npx hardhat init`)
3. Skip framework setup (manual configuration)
```

### Framework Mismatch

If commands fail due to wrong framework assumptions:

```markdown
⚠️ **Framework mismatch detected**

The command failed. Let me re-check the framework configuration and adapt.

[Re-runs framework detection]

Switching to [detected framework] workflow...
```

## Best Practices

1. **Always detect first** - Never assume framework without checking
2. **Adapt commands** - Use framework-specific commands based on detection
3. **Prefer Foundry for speed** - In hybrid setups, use Foundry for dev tasks
4. **Prefer Hardhat for deployment** - Use Hardhat for production deployment
5. **Be explicit** - Tell the user which framework is being used
6. **Handle errors gracefully** - Re-detect if commands fail

## Integration with Other Skills

This skill is **foundational** and should be referenced by:
- `foundry-setup` skill
- `hardhat-setup` skill
- All development agents (developer, tester, gas-optimizer, etc.)
- All testing workflows
- All deployment workflows

## Quick Reference

| Task | Foundry | Hardhat | Hybrid Strategy |
|------|---------|---------|----------------|
| Compile | `forge build` | `npx hardhat compile` | Use Foundry |
| Test | `forge test` | `npx hardhat test` | Use Foundry |
| Coverage | `forge coverage` | `npx hardhat coverage` | Use Foundry |
| Deploy | `forge script` | `npx hardhat run` | Use Hardhat |
| Verify | `forge verify-contract` | `npx hardhat verify` | Use Hardhat |
| Gas Report | `forge test --gas-report` | `REPORT_GAS=true npx hardhat test` | Use Foundry |

---

**Remember:** Framework detection is the **first step** in any Solidity workflow. Always detect before executing commands.
