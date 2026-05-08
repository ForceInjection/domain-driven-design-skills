---
name: Initializing Project
description: Intelligent project analysis with auto-framework detection and adaptive setup. Use when user wants to initialize Quaestor, setup a new project, or analyze existing project structure.
allowed-tools: [Read, Bash, Glob, Grep, Edit, Write, Task, TodoWrite]
---

# Initializing Project

I help you intelligently initialize Quaestor in your project with automatic framework detection, architecture analysis, and customized documentation generation.

## When to Use Me

- User says "initialize project", "setup quaestor", "analyze my project structure"
- Starting Quaestor in a new or existing project
- Migrating existing project to Quaestor
- Need intelligent project analysis and setup
- User asks "how do I set up quaestor?"

## Supporting Files

This skill uses several supporting files for detailed workflows:

- **@DETECTION.md** - Language and framework detection patterns, agent orchestration
- **@TEMPLATES.md** - Document templates, variable mappings, skills installation
- **@VALIDATION.md** - Mandatory user validation workflow
- **@EXAMPLES.md** - Full initialization examples for different project types

## My Process

I follow a 4-phase workflow to intelligently initialize your project:

### Phase 1: Project Analysis 🔍

I coordinate specialized agents (researcher, architect, security) to analyze your project in parallel. They examine:
- Framework and dependencies
- Architecture patterns and design
- Security posture and vulnerabilities
- Project complexity and phase

**See @DETECTION.md for detailed agent orchestration and detection patterns**

### Phase 2: Document Generation ⚡

I detect your project's language, load language-specific configurations, and generate customized documentation:
- AGENT.md (AI behavioral rules)
- ARCHITECTURE.md (with your language's quality standards)
- CLAUDE.md (main entry point)

**See @TEMPLATES.md for document templates and variable mappings**

### Phase 3: User Validation ✅ **[MANDATORY]**

I present my analysis and **MUST** get your approval before proceeding. You'll see:
- Detected framework and architecture
- Quality standards and tools
- Options to proceed, modify, customize, or use minimal setup

**See @VALIDATION.md for the complete validation workflow**

### Phase 4: Setup Completion 🚀

After your approval, I create the directory structure, generate all documentation, install skills, and provide next steps.

## Error Handling

I handle failures gracefully:
- **Agent failures**: Fall back to basic detection, continue with available data
- **Time limits**: 30s total, 10s per agent
- **Missing data**: Use sensible defaults and flag for manual review

**See @DETECTION.md for detailed error handling strategies**

## Next Steps After Initialization

After successful initialization:

### 1. Review and Customize Documentation
- `.quaestor/AGENT.md` - AI behavioral rules
- `.quaestor/ARCHITECTURE.md` - Architecture and quality standards (edit Section 3 to customize commands)

### 2. Start Development
- Create specifications: "Create a spec for [feature]" or use spec-writing skill
- Check progress: "What's the current project status?"
- Implement: "Implement spec-feature-001" or use `/impl` command
- Review: "Review my changes and create a PR" or use `/review` command

### 3. Available Skills
All Quaestor skills are available via the plugin or CLI installation. Skills are loaded from the plugin/package and accessed directly by Claude Code.

**See @TEMPLATES.md for customization details and @EXAMPLES.md for complete workflows**

## Success Criteria

- ✅ Framework and architecture accurately detected
- ✅ USER VALIDATION COMPLETED (mandatory)
- ✅ ARCHITECTURE.md generated with language-specific quality standards
- ✅ Directory structure created
- ✅ Project ready for specification-driven development

**See @EXAMPLES.md for complete initialization walkthroughs**

---

*I provide intelligent project initialization with automatic framework detection, architecture analysis, and customized documentation generation. Just tell me to initialize your project, and I'll handle the rest!*
