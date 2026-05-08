---
name: security-design
description: Design security controls and threat mitigations. Use for features involving auth, data, or external exposure.
---

# Security Design

Identify threats and design appropriate security controls for a feature.

## Process

1. Identify assets to protect
2. Model potential threats
3. Define required controls
4. Specify data handling rules
5. Note compliance requirements

## Output

Create `security-requirements.md` using the template in `templates/security-requirements.md`.

## Tips

- Consider OWASP Top 10 threats
- Define what data is sensitive
- Specify authentication/authorization needs
- Document logging requirements (without sensitive data)
- Consider rate limiting and abuse prevention
