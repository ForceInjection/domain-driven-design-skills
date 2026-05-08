---
name: auto-save-tips
description: Automatically save session tips when user provides important feedback or corrections
---

# Auto-Save Tips Skill

This skill detects when the user provides valuable feedback and automatically saves it to `.claude/TIPS.md`.

## Trigger Conditions

Activate this skill when the user provides:

1. **Corrections or Preferences**:
   - "いや" / じゃなくて" / "ではなく" / "No" / "instead" / "actually"
   - "次から" / "今後は" / "remember"
   - "気をつけて" / "注意" / "忘れずに"
   - "prefer" / "should be" / "should not"

2. **Important Decisions**:
   - Explicit choices between multiple approaches
   - Architectural or design decisions
   - Pattern or convention establishment

3. **Explicit Instructions**:
   - "always do X" / "never do Y"
   - "from now on" / "going forward"
   - Statements about future behavior

## Workflow

When triggered:

1. **Acknowledge the feedback**:
   - Confirm understanding of the user's point
   - Briefly explain what you'll change

2. **Invoke `/tips:save`**:
   - Use the Skill tool to execute `/tips:save`
   - This will capture the feedback and organize TIPS.md

3. **Continue the conversation**:
   - Apply the feedback immediately
   - Proceed with the original task

## Examples

### Example 1: User Correction

```
User: じゃなくて、スラッシュコマンドにしたほうがいいか

Claude: なるほど！フックではなくスラッシュコマンドの方が良いということですね。
        [Uses Skill tool to invoke /tips:save]
        承知しました。それではスラッシュコマンド方式で実装します...
```

### Example 2: User Preference

```
User: I prefer LLM-generated summaries over pattern matching

Claude: Understood! You prefer having the LLM review and write summaries
        rather than mechanical pattern matching.
        [Uses Skill tool to invoke /tips:save]
        I'll implement it that way...
```

## Important Notes

- **Do NOT over-trigger**: Only activate for genuinely valuable feedback
- **Do NOT interrupt flow**: Save tips smoothly without disrupting the conversation
- **Be selective**: Not every user comment needs to be saved
- Common responses like "ok" or "thanks" should NOT trigger this skill

