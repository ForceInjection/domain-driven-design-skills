---
name: implement-test-handler
description: Implements Z-Wave CTT (Certification Test Tool) test handlers for automating certification tests. Use when asked to create handlers for a given test, which includes automating CTT log parsing and prompt responses.
---

# CTT Test Handler Implementation

## Overview

CTT handlers automate Z-Wave certification tests by:
1. Parsing CTT log messages and executing corresponding Z-Wave commands
2. Responding to CTT prompts with Yes/No/Ok based on device state

## File Structure

```
dut/zwave-js/handlers/
├── tests/           # Test-specific handlers (CCR_*, CDR_*, RT_*, ...)
├── behaviors/       # Reusable handlers (capabilities, addMode, etc.)
├── utils.ts         # Utility functions
└── index.ts         # Auto-imports all handlers
```

## Handler Template

```typescript
import { <CCValues>, <CCEnums> } from "zwave-js";
import { registerHandler } from "../../prompt-handlers.ts";

// Map CTT names to zwave-js enum values
const nameToEnum: Record<string, EnumType> = {
  CTTName: EnumType["ZWave JS Name"],
};

registerHandler("CCR_<TestName>_Rev##", {
  async onLog(ctx) {
    const node = ctx.includedNodes.at(-1);
    if (!node) return;

    // Parse log and execute command
    const match = /<PATTERN>/i.exec(ctx.logText);
    if (match?.groups) {
      // Execute Z-Wave command
      return true; // Mark as handled
    }
  },

  async onPrompt(ctx) {
    const node = ctx.includedNodes.at(-1);
    if (!node) return;

    // Check condition and respond (prefer regex over .includes())
    if (/some pattern/i.test(ctx.promptText)) {
      const actual = node.getValue(CCValues.property.id);
      return actual === expected ? "Yes" : "No";
    }
  },
});
```

## Key Patterns

### Executing Commands

Prefer `setValue` for simple single-value commands. Use `commandClasses` methods for complex operations with multiple parameters.

**Simple value set (preferred):**
```typescript
node.setValue(DoorLockCCValues.targetMode.id, DoorLockMode.Secured);
```

**Command class method (for complex operations):**
```typescript
await node.commandClasses["Thermostat Setpoint"].set(type, value, scale);
await node.commandClasses["Door Lock"].setConfiguration(config);
```

### Reading Values

```typescript
const current = node.getValue(ThermostatModeCCValues.thermostatMode.id);
```

### State Management

Store values for later verification:
```typescript
// In onLog:
ctx.state.set("lastValue", value);

// In onPrompt:
const stored = ctx.state.get("lastValue") as number;
```

### Enum Mapping Conventions

CTT typically uses Z-Wave JS enum names without spaces:
- `FullPower` → `ThermostatSetpointType["Full Power"]`
- `AutoChangeover` → `ThermostatSetpointType["Auto Changeover"]`

For UPPER_CASE log formats (like `THERMOSTAT_MODE_SET`):
- `HEAT` → `ThermostatMode["Heat"]`
- `MANUFACTURER_SPECIFIC` → `ThermostatMode["Manufacturer specific"]`

### Pattern Matching

Prefer regex over `.includes()` due to case variations and potential typos in CTT output:

```typescript
// Good: case-insensitive, handles typos
if (/setpoint.+set succ?essfully/i.test(ctx.promptText)) { ... }

// Avoid: brittle, case-sensitive
if (ctx.promptText.includes("Setpoint been set successfully")) { ... }
```

## Common Log Patterns

```typescript
// Value with mode/type
/COMMAND_SET to mode = '(?<mode>\w+)'/i

// Value with numeric parameter
/COMMAND_SET.+value=(?<value>[\d.]+)/i

// Hex value in parentheses
/'(?<name>[^']+)' \((?<hex>0x[0-9a-fA-F]+)\)/i

// Multi-line configuration
if (/Set Configuration:/i.test(ctx.logText)) {
  const field1 = /Field 1:\s+'(\w+)'/i.exec(ctx.logText)?.[1];
}
```

## Common Prompt Patterns

```typescript
// Confirmation with expected value
/current mode is set to '(?<mode>\w+)'/i
/last known .+ is '(?<value>[^']+)' \((?<hex>0x[0-9a-fA-F]+)\)/i

// Simple yes/no capability questions → add to behaviors/capabilities.ts
{ pattern: /capable to do something/i, answer: "Yes" }
```

## Reference Files

- [prompt-handlers.ts](../../../dut/zwave-js/prompt-handlers.ts) - Handler registration
- [utils.ts](../../../dut/zwave-js/handlers/utils.ts) - Utilities like `parseDurationFromLog`
- [capabilities.ts](../../../dut/zwave-js/handlers/behaviors/capabilities.ts) - Capability prompts
- [zwave-js CC Documentation](https://zwave-js.github.io/zwave-js/#/api/CCs/index) - Official CC API docs

## Existing Handler Examples

- [CCR_DoorLockCC_Rev02.ts](../../../dut/zwave-js/handlers/tests/CCR_DoorLockCC_Rev02.ts) - Complex config
- [CCR_ThermostatModeCC_Rev02.ts](../../../dut/zwave-js/handlers/tests/CCR_ThermostatModeCC_Rev02.ts) - Mode with manufacturer data
- [CCR_ThermostatSetpointCC_Rev03.ts](../../../dut/zwave-js/handlers/tests/CCR_ThermostatSetpointCC_Rev03.ts) - State verification
- [CCR_WindowCoveringCC_Rev02.ts](../../../dut/zwave-js/handlers/tests/CCR_WindowCoveringCC_Rev02.ts) - Level change with setTimeout

## Workflow

1. **Identify the test name** (e.g., `CCR_DoorLockCC_Rev02`)
2. **Get log/prompt patterns** from user
3. **Find the CC API** at https://zwave-js.github.io/zwave-js/#/api/CCs/index - only if this leaves questions open, look in `node_modules/@zwave-js/cc/build/esm/cc/<CC>CC.d.ts`
4. **Find enum values** in `node_modules/@zwave-js/cc/build/esm/lib/_Types.d.ts`
5. **Create handler** in `dut/zwave-js/handlers/tests/CCR_<Name>.ts`
6. **Add capability questions** to `behaviors/capabilities.ts` if needed
