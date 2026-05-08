---
name: Procedural Memory System
description: This skill should be used when the user asks to "reflect on patterns", "generate rules from sessions", "consolidate memory", "analyze session patterns", "learn procedures and workflows", "create procedural knowledge", or mentions memory consolidation, process learning, or long-term knowledge retention. Provides systematic extraction of procedures, processes, and workflows from conversational history with automatic rule generation.
version: 1.0.0
---

# Procedural Memory System (PMS)

> **"Shame on you."** - Because Claude learns from your corrections.

## Overview

Procedural Memory System implements a three-tier memory architecture that transforms episodic conversational history into actionable procedural knowledge. The system automatically captures session transcripts, extracts recurring patterns in procedures and workflows, and synthesizes context-aware rules that persist across sessions.

**Complementary Focus**: PMS learns both **rigid procedures** (technical steps, coding patterns) and **flexible processes** (workflows, decision-making patterns, team practices), ensuring comprehensive behavioral learning.

**Three-tier architecture:**
1. **Episodic Memory**: Raw session transcripts with metadata
2. **Semantic Memory**: Extracted patterns, preferences, and anti-patterns
3. **Procedural Memory**: Generated rules injected into Claude's context

## When to Use

Invoke PMS workflows when:
- Completing work sessions and consolidating learnings
- Reaching session boundaries (context compaction, session end)
- Detecting recurring user preferences or code patterns
- Generating persistent rules from accumulated knowledge
- Analyzing patterns across multiple work sessions

PMS activates automatically via hooks but can be triggered manually via commands.

## Core Workflow

### 1. Episodic Encoding

Capture session transcripts into episodic records during natural boundaries.

**Automatic triggers:**
- PreCompact hook: Before context compaction
- SessionEnd hook: When session ends
- Stop hook: When work completes (optional)

**Manual trigger:**
```
/pms:encode
```

**What happens:**
- Transcript read from `.claude/projects/[project]/transcripts/`
- Metadata extracted (tool usage, file operations, key decisions)
- Episodic record saved to `.claude/pms/episodic/sessions-YYYY-MM.json`
- Privacy redaction applied (API keys, passwords, tokens)

**Encoding strategies:**
- **Context-first**: Uses conversation context when available (preferred)
- **JSONL fallback**: Parses JSONL transcript files when context unavailable

### 2. Semantic Extraction

Extract recurring patterns from accumulated episodic records.

**Trigger threshold:** Default 10 sessions minimum (configurable)

**Manual trigger:**
```
/pms:extract
```

**Pattern detection:**
- **User Preferences**: "Always run tests before commits", "Use TDD workflow"
- **Code Patterns**: "Repository pattern", "Middleware architecture"
- **Anti-Patterns**: "Avoid god objects", "No global state"

**Strength categorization:**
- **Emerging**: 2-4 occurrences
- **Strong**: 3-7 occurrences
- **Critical**: 5+ occurrences

**Output:**
- `.claude/pms/semantic/patterns.json` - All detected patterns
- `.claude/pms/semantic/preferences.json` - User preferences only
- `.claude/pms/semantic/code-patterns.json` - Code patterns only
- `.claude/pms/semantic/anti-patterns.json` - Anti-patterns only

### 3. Procedural Synthesis

Generate context-aware rules from semantic patterns.

**Trigger threshold:** Patterns must meet strength requirements

**Manual trigger:**
```
/pms:synthesize
```

**Rule generation:**
- Critical patterns → Immediate rule generation
- Strong patterns → Rule generation with approval
- Emerging patterns → Tracked but not synthesized

**Rule injection:**
- Generated rules saved to `.claude/rules/pms/`
- Rules automatically loaded into Claude's context
- Rules persist across sessions and projects

**Rule format:**
```markdown
---
pattern_id: pref_1234567890
category: preference
strength: strong
occurrences: 5
---

# [Pattern Title]

**Detected Pattern**: [Description]

**Apply this guidance**: [Actionable rule]

**Evidence**: Sessions [list]
```

## Commands

### `/pms:encode`
Manually trigger episodic encoding for current session.

**Use when:**
- Completing significant work
- Before context clearing
- At logical session boundaries

### `/pms:extract`
Trigger semantic pattern extraction from episodic records.

**Use when:**
- Accumulated sufficient sessions (10+ recommended)
- Want to review detected patterns
- Before rule synthesis

### `/pms:synthesize`
Generate procedural rules from semantic patterns.

**Use when:**
- Patterns reach actionable strength
- Ready to persist knowledge as rules
- After reviewing extracted patterns

### `/pms:reflect`
Comprehensive workflow: encode → extract → synthesize.

**Use when:**
- End of significant work session
- Regular reflection intervals
- Memory consolidation needed

### `/pms:status`
Display current memory system state.

**Shows:**
- Episodic record count
- Detected pattern count
- Generated rule count
- Last update timestamps

## Configuration

Configure PMS via `.claude/pms.local.md` with YAML frontmatter.

**Key settings:**

**Triggers** (enable/disable automatic hooks):
```yaml
triggers:
  precompact: true
  session_end: true
  stop: false
```

**Thresholds** (pattern detection sensitivity):
```yaml
thresholds:
  min_sessions: 10
  emerging_pattern: 2
  strong_pattern: 3
  critical_pattern: 5
```

**Privacy** (redaction configuration):
```yaml
privacy:
  redact_sensitive: true
  custom_redaction_patterns: []
```

**Processing** (automation behavior):
```yaml
processing:
  continuous_mode: false
  auto_extract: false
  auto_synthesize: false
```

## Privacy and Security

**Automatic redaction** of sensitive data:
- API keys and tokens
- Passwords and secrets
- Bearer tokens and credentials
- Custom patterns (configurable)

**Redaction strategy:**
- Over-redact rather than under-redact
- Pattern-based detection with regex
- Recursive traversal of nested structures

**What gets redacted:**
```
api_key=sk-xxxx... → api_key=[REDACTED]
password="secret" → password="[REDACTED]"
Bearer xxxxx... → Bearer [REDACTED]
```

## Error Handling and Recovery

**Corruption recovery:**
```
/pms:validate
```
Validates JSON schema integrity and backs up corrupted files.

**Manual reset:**
```
/pms:reset
```
Clears semantic and procedural memory while preserving episodic records (optional).

**Rebuild semantic knowledge:**
```
/pms:rebuild
```
Regenerates semantic patterns from episodic records after corruption or reset.

## Best Practices

**Regular reflection intervals:**
- End of each work session
- Before context clearing
- At project milestones
- After significant learning experiences

**Pattern review:**
- Review extracted patterns before synthesis
- Validate pattern accuracy and relevance
- Adjust thresholds if patterns too noisy or sparse

**Privacy maintenance:**
- Review redaction patterns periodically
- Add custom patterns for domain-specific secrets
- Verify no sensitive data in generated rules

**Performance optimization:**
- Keep continuous_mode disabled unless needed
- Use manual triggers for selective extraction
- Archive old episodic records periodically

## Integration with Workflow

**Typical session workflow:**
1. Work on features, solve problems, make decisions
2. Reach natural boundary (context compaction, session end)
3. PMS encodes session automatically via hooks
4. Continue working until threshold reached (10+ sessions)
5. PMS extracts patterns automatically or via `/pms:extract`
6. Review patterns, approve rule generation
7. PMS synthesizes rules via `/pms:synthesize`
8. Rules persist and apply to future sessions

**Manual workflow:**
```
[Work session]
/pms:encode          # Capture current session
[More work sessions]
/pms:extract         # Review patterns
/pms:synthesize      # Generate rules
/pms:status          # Verify state
```

**Emergency workflow:**
```
/pms:validate        # Check for corruption
/pms:backup          # Backup current state
/pms:reset --keep-episodic  # Clear semantic/procedural
/pms:rebuild         # Regenerate from episodic
```

## Verification

**After encoding:**
- Check `.claude/pms/episodic/sessions-YYYY-MM.json` exists
- Verify session count increased
- Confirm no sensitive data in episodic records

**After extraction:**
- Review `.claude/pms/semantic/patterns.json`
- Verify pattern descriptions are accurate
- Check strength categorization makes sense

**After synthesis:**
- Read generated rules in `.claude/rules/pms/`
- Verify rule guidance is actionable
- Test rules apply in new sessions

## Additional Resources

For detailed technical documentation:
- **`ARCHITECTURE.md`**: Deep technical design, data flow, component architecture
- **`README.md`**: User guide, quick start, troubleshooting
- **`.claude/pms.local.md`**: Configuration template with examples

For testing and validation:
- **`tests/unit/`**: Unit tests for individual components
- **`tests/integration/`**: Full pipeline integration tests
- **`scripts/`**: Core engine implementations (encode, extract, synthesize)
