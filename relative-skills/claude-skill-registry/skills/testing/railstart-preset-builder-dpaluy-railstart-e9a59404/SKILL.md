---
name: railstart-preset-builder
description: Guide for creating railstart preset configuration files. Use when building new presets, customizing Rails 8 app generation, creating team-specific configurations, or defining opinionated Rails stacks. Covers YAML structure, ID-based merging, post-action configuration, and testing presets for the railstart gem.
---

# Railstart Preset Builder

## Purpose

This skill guides you through creating preset configuration files for the railstart gem. Presets enable quick Rails 8 application generation with predefined choices for database, CSS, JavaScript, test framework, and post-generation actions.

## When to Use This Skill

Use this skill when:
- Creating new railstart presets for specific tech stacks
- Defining team or organization default configurations
- Building quick-start templates for common Rails patterns
- Customizing Rails app generation workflows
- Setting up opinionated Rails configurations

## Preset System Overview

### Three-Layer Configuration

Railstart uses a three-layer configuration merge system:

1. **Base Config** (`config/rails8_defaults.yaml`) - Defines all available questions and post-actions
2. **User Config** (`~/.config/railstart/config.yaml`) - User's personal overrides (optional)
3. **Preset Config** (`config/presets/*.yaml`) - Named preset that overrides defaults

**Merge Order:** Base → User → Preset (later layers win)

### ID-Based Merging

Questions and post-actions merge by unique `id` field:
- Questions with matching IDs have their `choices` array replaced entirely
- Individual choice `default` flags override base configuration
- Post-actions with matching IDs have their `enabled` state overridden

### multi_select Defaults

For `multi_select` questions (like `skip_features`), always use choice **values** (stable IDs), not display names:

```yaml
# ✅ CORRECT - Uses stable value identifiers
- id: skip_features
  default:
    - action_mailer      # Stable internal ID
    - action_text        # Won't break if display text changes
    - hotwire

# ❌ WRONG - Uses display names (fragile)
- id: skip_features
  default:
    - Action Mailer                # Breaks if wording changes
    - Hotwire (Turbo + Stimulus)   # Fragile, avoid
```

**Why values are better:**
- **Stability**: Display text can change for UX improvements without breaking presets
- **Consistency**: Values are used throughout the system (CommandBuilder, answers storage)
- **Correctness**: Generator automatically transforms values → names for TTY::Prompt display

## Available Questions

From `config/rails8_defaults.yaml`:

### Database (select)
- **ID:** `database`
- **Choices:** `sqlite3`, `postgresql`, `mysql`
- **Default:** `sqlite3`
- **Flag:** `--database=%{value}`

### CSS Framework (select)
- **ID:** `css`
- **Choices:** `tailwind`, `bootstrap`, `bulma`, `postcss`, `sass`, `none`
- **Default:** `tailwind`
- **Flag:** `--css=%{value}`

### JavaScript Approach (select)
- **ID:** `javascript`
- **Choices:** `importmap`, `bun`, `esbuild`, `rollup`, `webpack`, `vite`, `none`
- **Default:** `importmap`
- **Flags:** Choice-level flags (e.g., `--javascript=bun` or `--skip-javascript`)

### Test Framework (select)
- **ID:** `test_framework`
- **Choices:** `minitest`, `rspec`
- **Default:** `minitest`
- **Flag:** RSpec uses `--skip-test`

### Skip Features (multi_select)
- **ID:** `skip_features`
- **Values:** `action_mailer`, `action_mailbox`, `action_text`, `active_record`, `active_job`, `active_storage`, `action_cable`, `hotwire`
- **Default:** `[]` (none skipped)
- **Flags:** Individual choice flags (e.g., `--skip-action-mailer`)
- **Note:** Use values in `default` array, not display names (see multi_select Defaults section above)

### Boolean Options (yes_no)
- **IDs:** `api_only`, `skip_git`, `skip_docker`, `skip_bundle`
- **Flags:** Various (e.g., `--api`, `--skip-git`)

## Available Post-Actions

### init_git
- **Default:** Enabled if `skip_git` = false
- **Command:** `git init && git add . && git commit -m 'Initial commit'`
- **Purpose:** Initialize git repository

### bundle_install
- **Default:** Disabled
- **Condition:** Only if `skip_bundle` = true
- **Command:** `bundle install`
- **Purpose:** Manual gem installation

### setup_rspec
- **Default:** Enabled
- **Condition:** Only if `test_framework` = `rspec`
- **Command:** `bundle add rspec-rails --group development,test && bundle exec rails generate rspec:install`
- **Purpose:** Automatic RSpec setup

### setup_vite
- **Default:** Enabled
- **Condition:** Only if `javascript` = `vite`
- **Command:** `bundle add vite_rails && bundle install && bundle exec vite install`
- **Purpose:** Automatic Vite Rails setup

### setup_bundlebun
- **Default:** Disabled
- **Condition:** Only if `javascript` = `bun`
- **Command:** `bundle add bundlebun && bundle install && bundle exec rake bun:install`
- **Purpose:** Optional Bundlebun (Bun as a gem) setup

## Preset Creation Workflow

### Step 1: Define Requirements

Answer these questions:
- What stack does this preset target? (e.g., "API-only", "Modern SPA", "Traditional Rails")
- Which database? (PostgreSQL for production, SQLite for quick prototypes)
- Which CSS framework? (Tailwind for utility-first, none for APIs)
- Which JavaScript approach? (Vite for SPAs, importmap for traditional, none for APIs)
- Which test framework? (Minitest default, RSpec for BDD)
- Which features to skip? (Action Mailer, Hotwire, etc. for APIs)
- Which post-actions to enable? (Vite setup, Bundlebun, RSpec)

### Step 2: Create Preset File

**Location:** `config/presets/{preset-name}.yaml`

**Naming Convention:**
- Lowercase with hyphens
- Descriptive of stack (e.g., `vite-bun`, `api-only`, `default`)
- Short and memorable

**Basic Structure:**
```yaml
---
# Preset Name - Brief Description
# Explain what this preset configures and when to use it

questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

  - id: css
    choices:
      - name: Tailwind
        value: tailwind
        default: true

  - id: javascript
    choices:
      - name: Importmap (default)
        value: importmap
        default: true

  - id: test_framework
    choices:
      - name: Minitest (default)
        value: minitest
        default: true

  - id: skip_features
    default: []

  - id: api_only
    default: false

  - id: skip_git
    default: false

  - id: skip_docker
    default: false

  - id: skip_bundle
    default: false

post_actions:
  - id: init_git
    name: "Initialize git repository"
    enabled: true
    command: "git init && git add . && git commit -m 'Initial commit'"

  - id: setup_rspec
    name: "Setup RSpec"
    enabled: false
    command: "bundle add rspec-rails --group development,test && bundle exec rails generate rspec:install"

  - id: setup_vite
    name: "Setup Vite Rails"
    enabled: false
    command: "bundle add vite_rails && bundle install && bundle exec vite install"

  - id: setup_bundlebun
    name: "Setup Bundlebun (Bun packaged as a gem)"
    enabled: false
    command: "bundle add bundlebun && bundle install && bundle exec rake bun:install"
```

### Step 3: Override Defaults

Only include questions you want to override. Minimal example:

```yaml
---
# API-Only Preset - Minimal Rails for JSON APIs

questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

  - id: css
    choices:
      - name: None
        value: none
        default: true

  - id: skip_features
    default:
      - action_mailer
      - action_text
      - hotwire

  - id: api_only
    default: true

post_actions:
  - id: init_git
    name: "Initialize git repository"
    enabled: true
    command: "git init && git add . && git commit -m 'Initial commit'"
```

### Step 4: Enable Post-Actions

Enable relevant post-actions based on your choices. **IMPORTANT:** Always include complete post-action definitions with `name` and `command`:

```yaml
post_actions:
  - id: setup_vite
    name: "Setup Vite Rails"
    enabled: true
    command: "bundle add vite_rails && bundle install && bundle exec vite install"

  - id: setup_bundlebun
    name: "Setup Bundlebun (Bun packaged as a gem)"
    enabled: true
    command: "bundle add bundlebun && bundle install && bundle exec rake bun:install"

  - id: setup_rspec
    name: "Setup RSpec"
    enabled: true
    command: "bundle add rspec-rails --group development,test && bundle exec rails generate rspec:install"
```

### Step 5: Test Preset

**Manual Testing:**
```bash
# Test preset loading
ruby -ryaml -e "puts YAML.load_file('config/presets/your-preset.yaml').inspect"

# Test with railstart (if installed locally)
bundle exec exe/railstart new testapp --preset your-preset --default

# Verify generated app
cd testapp
cat Gemfile  # Check for expected gems
ls -la       # Verify structure
```

**Automated Testing:**
```bash
# Run test suite
bundle exec rake test

# Run linter
bundle exec rubocop
```

## Real-World Examples

### Example 1: Modern SPA Stack (vite-bun.yaml)

```yaml
---
# Vite + Bundlebun Preset - Modern frontend with Vite and Bun packaged as a gem

questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

  - id: css
    choices:
      - name: Tailwind
        value: tailwind
        default: true

  - id: javascript
    choices:
      - name: Vite (via vite_rails gem)
        value: vite
        default: true

  - id: test_framework
    choices:
      - name: Minitest (default)
        value: minitest
        default: true

  - id: skip_features
    default: []

  - id: api_only
    default: false

  - id: skip_git
    default: false

  - id: skip_docker
    default: false

  - id: skip_bundle
    default: false

post_actions:
  - id: init_git
    name: "Initialize git repository"
    enabled: true
    command: "git init && git add . && git commit -m 'Initial commit'"

  - id: setup_vite
    name: "Setup Vite Rails"
    enabled: true
    command: "bundle add vite_rails && bundle install && bundle exec vite install"

  - id: setup_bundlebun
    name: "Setup Bundlebun (Bun packaged as a gem)"
    enabled: true
    command: "bundle add bundlebun && bundle install && bundle exec rake bun:install"
```

**Use Case:** Building modern SPAs with fast HMR (Vite) and unified JavaScript runtime (Bundlebun)

**Usage:**
```bash
railstart new myapp --preset vite-bun
```

### Example 2: API-Only Stack (api-only.yaml)

```yaml
---
# API-Only Preset - Minimal Rails app for JSON APIs

questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

  - id: css
    choices:
      - name: None
        value: none
        default: true

  - id: javascript
    choices:
      - name: Importmap (default)
        value: importmap
        default: true

  - id: skip_features
    default:
      - action_mailer
      - action_text
      - hotwire

  - id: api_only
    default: true

  - id: skip_git
    default: false

  - id: skip_docker
    default: false

  - id: skip_bundle
    default: false

post_actions:
  - id: init_git
    name: "Initialize git repository"
    enabled: true
    command: "git init && git add . && git commit -m 'Initial commit'"
```

**Use Case:** Building JSON APIs without views or frontend assets

**Usage:**
```bash
railstart new api --preset api-only
```

### Example 3: RSpec + PostgreSQL Stack

```yaml
---
# RSpec Preset - BDD workflow with RSpec and PostgreSQL

questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

  - id: test_framework
    choices:
      - name: RSpec
        value: rspec
        default: true

  - id: skip_git
    default: false

post_actions:
  - id: init_git
    name: "Initialize git repository"
    enabled: true
    command: "git init && git add . && git commit -m 'Initial commit'"

  - id: setup_rspec
    name: "Setup RSpec"
    enabled: true
    command: "bundle add rspec-rails --group development,test && bundle exec rails generate rspec:install"
```

**Use Case:** Teams preferring RSpec over Minitest for BDD-style testing

**Usage:**
```bash
railstart new myapp --preset rspec
```

## Best Practices

### Naming

✅ **DO:**
- Use descriptive hyphenated names (`vite-bun`, `api-only`)
- Keep names short and memorable
- Use stack technology names when relevant

❌ **DON'T:**
- Use underscores or spaces
- Use overly generic names (`preset1`, `test`)
- Use version numbers unless necessary

### Documentation

✅ **DO:**
- Add clear comments explaining the preset's purpose
- Document when to use this preset
- Explain non-obvious choices

❌ **DON'T:**
- Leave presets undocumented
- Assume users know why choices were made

### Scope

✅ **DO:**
- Override only what's necessary for the stack
- Leave unrelated options at defaults
- Enable relevant post-actions

❌ **DON'T:**
- Override every single option
- Enable unrelated post-actions
- Create overly complex presets

### Testing

✅ **DO:**
- Test YAML syntax before committing
- Generate test apps with the preset
- Verify all post-actions execute correctly
- Check generated Gemfile and config files

❌ **DON'T:**
- Commit untested presets
- Assume merging works without verification
- Skip validation of post-action commands

## Common Patterns

### Pattern 1: PostgreSQL + Tailwind (Production Default)

Most production apps benefit from:
```yaml
questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

  - id: css
    choices:
      - name: Tailwind
        value: tailwind
        default: true
```

### Pattern 2: Skip All Frontend (Pure API)

API-only apps should skip frontend tooling:
```yaml
questions:
  - id: css
    choices:
      - name: None (skip CSS setup)
        value: none
        default: true

  - id: javascript
    choices:
      - name: None (skip JavaScript)
        value: none
        default: true

  - id: skip_features
    default:
      - action_mailer
      - action_text
      - hotwire

  - id: api_only
    default: true
```

### Pattern 3: Modern Frontend Stack

SPAs and modern frontends typically use:
```yaml
questions:
  - id: javascript
    choices:
      - name: Vite (via vite_rails gem)
        value: vite
        default: true

post_actions:
  - id: setup_vite
    enabled: true
```

## Troubleshooting

### Preset Not Loading

**Symptom:** Preset file ignored, defaults used

**Solutions:**
1. Verify file location: `config/presets/{name}.yaml`
2. Check YAML syntax: `ruby -ryaml -e "YAML.load_file('config/presets/name.yaml')"`
3. Ensure preset name matches filename (without .yaml)
4. Check for typos in `--preset` flag

### Wrong Defaults Selected

**Symptom:** Different choice selected than expected

**Solutions:**
1. Verify `default: true` is on the correct choice
2. Check for multiple `default: true` in same question (last wins)
3. Ensure question `id` matches exactly
4. Test ID-based merging manually

### Post-Action Not Running

**Symptom:** Expected post-action skipped

**Solutions:**
1. Check `enabled: true` in preset
2. Verify conditional logic (`if` field) matches selected answers
3. Ensure post-action `id` matches exactly
4. Check command syntax for errors

### YAML Syntax Error

**Symptom:** Parse error or invalid YAML

**Solutions:**
1. Validate YAML: `yq . config/presets/name.yaml`
2. Check indentation (2 spaces, no tabs)
3. Ensure proper array syntax (`- item`)
4. Verify all strings are properly quoted if containing special chars

## Quick Reference

### Minimal Preset Template

```yaml
---
# Preset Name - Description

questions:
  - id: database
    choices:
      - name: PostgreSQL
        value: postgresql
        default: true

post_actions:
  - id: init_git
    enabled: true
```

### Usage Commands

```bash
# List available presets
ls config/presets/

# Use preset with interactive mode
railstart new myapp --preset name

# Use preset with default mode (no prompts)
railstart new myapp --preset name --default

# Validate YAML syntax
ruby -ryaml -e "puts YAML.load_file('config/presets/name.yaml').inspect"
```

### Testing Checklist

- [ ] YAML syntax valid (no parse errors)
- [ ] All question IDs match base config
- [ ] Only one `default: true` per select question
- [ ] Post-action IDs match base config
- [ ] Post-action conditionals match question choices
- [ ] Test app generates successfully
- [ ] All post-actions execute correctly
- [ ] Gemfile contains expected gems
- [ ] Generated config files are correct

---

**Status:** Complete - Ready for use ✅
**Version:** 1.0.0
**Last Updated:** 2025-11-22
