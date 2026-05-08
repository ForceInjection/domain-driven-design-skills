---
name: security/threat-model
description: Threat Modeling security skill
---

# Threat Modeling

Identify attack surface, enumerate threats, prioritize mitigations before writing code.

## Process for Planned Work

**1. Identify assets:**
- What are we protecting? (API keys, conversation history, user data)
- What would attacker want? (credentials, code execution, data exfil)

**2. Enumerate entry points:**
- User input (terminal, config, environment)
- Network (LLM API responses)
- Filesystem (config files, database)

**3. Apply STRIDE per entry point:**
- **S**poofing: Can attacker impersonate?
- **T**ampering: Can attacker modify data?
- **R**epudiation: Can actions be denied?
- **I**nformation disclosure: Can secrets leak?
- **D**enial of service: Can availability be impacted?
- **E**levation of privilege: Can attacker gain capabilities?

**4. Prioritize:**
- Likelihood × Impact = Risk
- Address high-risk items first
- Document accepted risks

**For new features ask:**
- What new entry points does this create?
- What can go wrong if input is malicious?
- What's the blast radius if this component is compromised?
