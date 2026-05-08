---
name: test-skill-multifile
description: Test skill demonstrating progressive file loading with multiple resources
---

# Test Skill: Progressive File Loading

This skill demonstrates the progressive loading feature where additional files can be loaded from the skill directory as needed.

## Available Resources

This skill includes the following additional files:

- `helper.py` - A Python helper script for processing
- `references/guide.md` - Detailed reference documentation
- `examples/sample.txt` - Example data file

## Usage

1. This SKILL.md file is loaded automatically when the skill is invoked
2. Use `Skill(skill="test-skill-multifile", file="helper.py")` to load the Python script
3. Use `Skill(skill="test-skill-multifile", file="references/guide.md")` to load the reference guide
4. Execute scripts using Bash tool with the base path provided in context

## Example Workflow

```
1. Invoke the skill
2. Review available resources
3. Load specific files as needed
4. Use the loaded content to complete the task
5. Clear the skill when done
```

All loaded files remain in the skill context until the skill is cleared.
