---
name: security/terminal
description: Terminal Security security skill
---

# Terminal Security

Terminal emulators interpret escape sequences that can be weaponized. LLM responses are untrusted.

## ikigai Application

**ANSI escape injection:**
- LLM responses may contain malicious escape sequences
- Attackers can: change terminal title, redefine keys, write to arbitrary screen positions
- Some terminals vulnerable to escape sequences that execute commands

**Sanitization strategy:**
- Strip or escape control characters (0x00-0x1F, 0x7F) except safe ones
- Allowlist: `\n`, `\r`, `\t` for formatting
- Escape or strip: `\x1b` (ESC), `\x9b` (CSI)
- Consider: pass through only after validation

**Safe display patterns:**
```c
// Filter control chars before display
for (size_t i = 0; i < len; i++) {
    if (data[i] < 0x20 && data[i] != '\n' && data[i] != '\t') {
        continue;  // Skip control char
    }
    output_char(data[i]);
}
```

**Raw mode considerations:**
- Restore terminal state on exit (even on crash)
- Handle SIGINT/SIGTERM to cleanup
- Don't leak raw mode to child processes

**Review red flags:** Unsanitized LLM output to terminal, missing escape filtering, no terminal cleanup on error paths.
