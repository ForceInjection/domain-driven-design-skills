---
name: skill-lifecycle-manager
description: Use when creating, testing, iterating, or managing Claude Code skills. Handles skill scaffolding, git versioning, symlink management, auto-discovery testing, and quality assurance. Triggered by requests to create new skills, improve existing skills, test skill loading, or manage skill infrastructure.
maturity: stable
version: 1.0.0
---

# Skill Lifecycle Manager

## Overview

Meta-skill for managing the complete lifecycle of Claude Code skills - from creation to deployment.

**When to use:**
- Creating a new skill from user workflow
- Iterating on existing skill based on usage
- Testing skill discovery and loading
- Managing git repo and symlinks
- Validating skill infrastructure

**Announce:** "I'm using the skill-lifecycle-manager to manage skill operations"

## Process

### Phase 1: Skill Creation

```bash
# Check if we're in git repo or ~/.claude
if [[ -d ~/Code/claude-skills ]]; then
    cd ~/Code/claude-skills
elif [[ -d ~/.claude/skills ]]; then
    cd ~/.claude/skills
else
    echo "Creating skills repository"
    mkdir -p ~/Code/claude-skills
    cd ~/Code/claude-skills
    git init
fi
```

### Phase 2: Capture Current Workflow

When user completes a task that should become a skill:

1. **Extract pattern from conversation**
   ```bash
   # Review current session for reusable patterns
   grep -E "(I'm using|Let me|I'll)" ~/.claude/session-env/*/messages.jsonl | tail -20
   ```

2. **Generate skill from workflow**
   ```bash
   ./skills-toolkit/generate-skill.sh "$SKILL_NAME" bundled
   ```

3. **Populate with captured process**
   - Copy successful commands to scripts/
   - Extract templates used to templates/
   - Document decision points in SKILL.md

### Phase 3: Test Skill Loading

**Verify Discovery:**
```bash
# Test 1: Check if skill is discoverable
ls -la ~/.claude/skills/ | grep "$SKILL_NAME"

# Test 2: Verify symlink if using git repo
readlink ~/.claude/skills/"$SKILL_NAME"

# Test 3: Check frontmatter validity
head -10 "$SKILL_NAME/SKILL.md" | grep -E "^(name|description):"
```

**Test Progressive Disclosure:**
```python
# Simulate Claude's loading pattern
import yaml
import os

def test_skill_loading(skill_path):
    # Phase 1: Metadata only (~100 tokens)
    with open(f"{skill_path}/SKILL.md", 'r') as f:
        content = f.read()
        frontmatter = content.split('---')[1]
        metadata = yaml.safe_load(frontmatter)
        print(f"Metadata tokens: ~{len(metadata['description'].split())}")

    # Phase 2: Full instructions (<5k tokens)
    instructions = content.split('---')[2]
    print(f"Instruction tokens: ~{len(instructions.split())}")

    # Phase 3: Resources (as needed)
    for subdir in ['scripts', 'templates', 'reference']:
        path = f"{skill_path}/{subdir}"
        if os.path.exists(path):
            size = sum(os.path.getsize(f"{path}/{f}") for f in os.listdir(path))
            print(f"{subdir}/ size: {size} bytes")
```

### Phase 4: Iteration Workflow

**Capture improvements during usage:**

1. **Monitor skill effectiveness**
   ```bash
   # Track when skill is invoked
   grep "using the $SKILL_NAME skill" ~/.claude/debug/latest | wc -l
   ```

2. **Update based on failures**
   - Add error handling for edge cases
   - Expand validation checklist
   - Improve trigger descriptions

3. **Version and commit**
   ```bash
   # Update version in frontmatter
   sed -i '' "s/version: .*/version: $NEW_VERSION/" SKILL.md

   # Update CHANGELOG
   echo "## [$NEW_VERSION] - $(date +%Y-%m-%d)" >> CHANGELOG.md
   echo "- $CHANGE_DESCRIPTION" >> CHANGELOG.md

   # Commit improvements
   git add -A
   git commit -m "feat($SKILL_NAME): $IMPROVEMENT"
   ```

### Phase 5: Infrastructure Validation

**Complete health check:**
```bash
#!/bin/bash
# skill-health-check.sh

echo "=== Skill Infrastructure Health Check ==="

# 1. Check repositories
echo -n "Git repo exists: "
[[ -d ~/Code/claude-skills/.git ]] && echo "✓" || echo "✗"

# 2. Check symlinks
echo -n "Symlinks valid: "
for link in ~/.claude/skills/*; do
    [[ -L "$link" ]] && [[ -e "$link" ]] || echo "✗ $link broken"
done
echo "✓"

# 3. Check frontmatter
echo -n "Frontmatter valid: "
for skill in ~/Code/claude-skills/*/SKILL.md; do
    grep -q "^name:" "$skill" || echo "✗ $skill missing name"
    grep -q "^description:" "$skill" || echo "✗ $skill missing description"
done
echo "✓"

# 4. Test discovery
echo -n "Skills discoverable: "
ls ~/.claude/skills/ | wc -l
echo " skills found"

# 5. Check for conflicts
echo -n "No naming conflicts: "
ls ~/.claude/skills/ | sort | uniq -d | wc -l | grep -q "0" && echo "✓" || echo "✗"
```

## Validation Checklist

- [ ] Skill has valid frontmatter (name, description)
- [ ] Description includes trigger keywords
- [ ] Symlink points to git repo (if applicable)
- [ ] Git repo has clean history
- [ ] CHANGELOG tracks iterations
- [ ] Resources in correct directories
- [ ] No naming conflicts
- [ ] Progressive disclosure works
- [ ] Auto-discovery successful

## Meta Patterns

### Pattern 1: Workflow to Skill
```
User completes task → Capture process → Generate skill → Test → Deploy
```

### Pattern 2: Skill Evolution
```
Usage → Identify improvement → Update skill → Version → Test → Commit
```

### Pattern 3: Infrastructure Maintenance
```
Health check → Fix issues → Validate → Document → Share
```

## Integration Points

**Works with:**
- `skills-toolkit/generate-skill.sh` - For scaffolding
- Git workflows - For versioning
- Claude's skill discovery - For validation
- Session history - For pattern extraction

## Common Issues

**Symlink broken after git pull:**
```bash
# Re-establish symlinks
for skill in ~/Code/claude-skills/*/; do
    name=$(basename "$skill")
    ln -sf "$skill" ~/.claude/skills/"$name"
done
```

**Skill not discovered:**
- Check frontmatter format
- Verify description has keywords
- Ensure SKILL.md exists
- Check file permissions

**Progressive disclosure not working:**
- Keep SKILL.md under 5k tokens
- Move large content to resources/
- Use references instead of inline code