---
name: notes
description: Note-taking workflow using denote format and org-mode. USE WHEN user wants to create notes, organize knowledge, document learnings, or work with denote/org-mode files.
---

# Note Writing Workflow

## Purpose
Assist with creating and organizing notes in denote format using org-mode.

### Context Detection

**This skill activates when:**
- User asks to create a note, write a note, or document something
- User mentions denote, org-mode, or note-taking
- Working directory is `/home/vincent/desktop/org/notes`
- User references `.org` files with denote naming pattern
- User asks about organizing knowledge or documentation

## Note Location
**Notes directory**: `/home/vincent/desktop/org/notes`

## Denote Format

Denote is an Emacs package for simple note management with a consistent naming scheme.

### File Naming Pattern

**Standard format**:
```
YYYYMMDDTHHMMSS--title__tag1_tag2_tag3.org
```

**With signature (for automated/system-generated notes)**:
```
YYYYMMDDTHHMMSS==signature--title__tag1_tag2_tag3.org
```

**Components**:
- **Timestamp**: `YYYYMMDDTHHMMSS` - Unique identifier and creation time
- **Signature** (optional): `==signature` - Identifies note origin/type (e.g., `==pkai` for automated history notes)
- **Separator**: `--` - Separates timestamp/signature from title
- **Title**: Descriptive, lowercase with hyphens
- **Tag separator**: `__` - Separates title from tags
- **Tags**: Underscore-separated, descriptive keywords

**Examples**:
```
# Regular note
20251203T151822--personal-ai-infrastructure-implementation-plan__ai_claude_infrastructure_nixos_plan.org

# Automated history note (with pkai signature)
20251203T155616==pkai--claude-skills-implementation-session__history_session_ai_claude.org
```

**Signature Usage**:
- `==pkai` - Personal Knowledge Automated Infrastructure (history-generated notes)
- Use signatures to identify system-generated or automated notes
- Makes it easy to filter: `ls *==pkai*.org` shows all automated notes

### File Structure

Every denote note follows this org-mode structure:

```org
#+title:      Note Title Here
#+date:       [YYYY-MM-DD Day HH:MM]
#+filetags:   :tag1:tag2:tag3:
#+identifier: YYYYMMDDTHHMMSS
#+category: category_name

* First Section
Content goes here...

** Subsection
More content...

* Second Section
Additional content...
```

**Key Elements**:
- `#+title:` - Human-readable title (can have spaces, capitalization)
- `#+date:` - Creation date in org-mode date format
- `#+filetags:` - Tags surrounded by colons (`:tag1:tag2:`)
- `#+identifier:` - Same as filename timestamp
- `#+category:` - Optional category for organization

## Common Tags

### Technical Topics
- `:ai:` - AI, LLMs, Claude Code
- `:nixos:` - NixOS configuration and packages
- `:golang:` - Go programming language
- `:homelab:` - Infrastructure, servers, self-hosting
- `:keyboards:` - Keyboard firmware (QMK, ZMK, Kanata)
- `:emacs:` - Emacs editor and configuration
- `:linux:` - Linux operating system
- `:programming:` - General programming topics

### Work and Projects
- `:work:` - Work-related notes
- `:redhat:` - Red Hat specific
- `:openshift:` - OpenShift/Kubernetes
- `:tekton:` - Tekton CI/CD
- `:project:` - Project-specific notes

### Personal
- `:life:` - Personal life and experiences
- `:books:` - Book notes and highlights
- `:ideas:` - Ideas and brainstorming
- `:plan:` - Planning and roadmaps
- `:learning:` - Learning notes

### Content Type
- `:howto:` - How-to guides
- `:reference:` - Reference material
- `:tutorial:` - Tutorials and walkthroughs

### History Integration
- `:history:` - All history-related notes (required for integration)
- `:history:session:` - Work session summaries
- `:history:learning:` - Problem-solving insights and learnings
- `:history:research:` - Deep technical investigations
- `:history:decision:` - Architecture and design decisions
- `:history:execution:` - Command execution logs

**Note**: History-tagged notes are interconnected with `~/.config/claude/history/` entries. See the history-system skill for details.

## Creating Notes

### Using org-manager (Recommended)

The `org-manager` tool provides batch mode denote integration for creating notes programmatically:

```bash
# Create a simple note
org-manager denote-create "Note Title" "tag1,tag2,tag3" \
  --category=homelab --directory=~/desktop/org/notes

# Create with signature (for automated notes)
org-manager denote-create "Session Summary" "history,session" \
  --signature=pkai --category=history

# Create with initial content from file
echo "* Custom Content" > /tmp/content.org
org-manager denote-create "My Note" "nixos,config" \
  --content=/tmp/content.org
```

**Output**: Returns JSON with created file path:
```json
{
  "success": true,
  "filepath": "/path/to/20251205T140049--note-title__tag1_tag2_tag3.org",
  "timestamp": "20251205T140049",
  "message": "Created note: ..."
}
```

### Manual Creation

If creating notes manually without org-manager:

#### Generate Timestamp
```bash
# Get current timestamp for identifier
date +"%Y%m%dT%H%M%S"
```

#### Generate Full Date
```bash
# Get org-mode formatted date
date +"[%Y-%m-%d %a %H:%M]"
```

### Example: Creating a New Note

**Filename**: `20251203T154500--setting-up-wireguard-vpn__homelab_networking_vpn.org`

**Content**:
```org
#+title:      Setting up Wireguard VPN
#+date:       [2025-12-03 Wed 15:45]
#+filetags:   :homelab:networking:vpn:
#+identifier: 20251203T154500
#+category: homelab

* Overview
Setting up Wireguard VPN for secure remote access to homelab.

* Configuration
** Server Setup
Configuration in ~/src/home/modules/wireguard-server

** Client Setup
Configuration in ~/src/home/modules/wireguard-client

* Testing
Verify connection with ping...
```

## Best Practices

### Title Guidelines
- Use descriptive, specific titles
- Keep titles concise (3-7 words ideal)
- Use lowercase in filename, normal case in `#+title:`
- Examples:
  - Good: "implementing-oauth2-authentication"
  - Bad: "notes" or "stuff-about-things"

### Tagging Strategy
- Use 2-5 tags per note
- Start general, then specific: `:programming:golang:testing:`
- Create tags consistently (don't use both `:ai:` and `:artificial-intelligence:`)
- Tags are for finding, not categorizing everything

### Content Organization
- Use org-mode headings (`*`, `**`, `***`)
- Include a brief overview/summary at the top
- Use TODO items for actionable content
- Link related notes with org-mode links

### Org-Mode Features

#### Headings
```org
* Level 1
** Level 2
*** Level 3
```

#### Links
```org
# Link to other notes
[[file:~/desktop/org/notes/20251203T151822--personal-ai-infrastructure__ai.org][PAI Implementation Plan]]

# External links
[[https://example.com][Example Website]]

# Link with description
[[https://github.com/user/repo][GitHub Repository]]
```

#### Code Blocks
```org
#+begin_src bash
# Shell commands
make switch
#+end_src

#+begin_src nix
# Nix configuration
services.nginx.enable = true;
#+end_src

#+begin_src go
// Go code
func main() {
    fmt.Println("Hello")
}
#+end_src
```

#### Lists
```org
# Unordered
- Item 1
- Item 2
  - Subitem

# Ordered
1. First
2. Second
3. Third

# TODO lists
- [ ] Uncompleted task
- [X] Completed task
```

#### TODO Items
```org
* TODO Implement feature X
SCHEDULED: <2025-12-04 Thu>

* DONE Fixed bug in handler
CLOSED: [2025-12-03 Wed 14:23]

* IN-PROGRESS Working on refactor
```

#### Tables
```org
| Name    | Value | Status |
|---------+-------+--------|
| Item 1  |   100 | Done   |
| Item 2  |   200 | Pending|
```

## Finding and Organizing Notes

### Using the Org Skill

This skill integrates with the **Org skill** for programmatic org-mode operations on note files.

**Tool location:** `~/.config/claude/skills/Org/tools/org-manager`

**Create notes (denote integration):**
```bash
# Create new note with proper denote formatting
org-manager denote-create "My Note Title" "tag1,tag2" \
  --category=category --directory=~/desktop/org/notes

# Create automated note with signature
org-manager denote-create "Session Log" "history,session" \
  --signature=pkai --category=history

# Read note metadata
org-manager denote-metadata ~/desktop/org/notes/20251205T*.org

# Update note frontmatter
org-manager denote-update ~/desktop/org/notes/20251205T*.org \
  --title="New Title" --tags="new,tags"

# Append content to existing note
echo "* New Section" > /tmp/content.org
org-manager denote-append ~/desktop/org/notes/20251205T*.org /tmp/content.org
```

**Search and query notes:**
```bash
# Search for term across all notes
org-manager search ~/desktop/org/notes/*.org "wireguard"

# Count TODOs in notes
org-manager count ~/desktop/org/notes/20251203T151822--project__ai.org

# List sections in a note
org-manager sections ~/desktop/org/notes/20251203T151822--project__ai.org
```

### By Tags
Notes with `:nixos:` tag can be found by searching filenames with `_nixos`

```bash
# Find notes with specific tag
ls ~/desktop/org/notes/*__*homelab*.org
ls ~/desktop/org/notes/*__*nixos*.org
```

### By Date
Files are naturally sorted by timestamp, most recent first when reverse sorted

```bash
# Most recent notes
ls -t ~/desktop/org/notes/*.org | head -10

# Notes from specific month
ls ~/desktop/org/notes/202512*.org
```

### By Title
Search for keywords in the title portion between `--` and `__`

```bash
# Find notes with "wireguard" in title
ls ~/desktop/org/notes/*--*wireguard*.org
```

### Using grep (fallback)
```bash
# Find notes about a topic
grep -l "wireguard" ~/desktop/org/notes/*.org

# Search content
grep -r "NixOS configuration" ~/desktop/org/notes/

# Find notes with specific tag in frontmatter
rg "#+filetags:.*:nixos:" ~/desktop/org/notes/
```

## Special Note Types

### Readwise Notes
Notes imported from Readwise follow a special format:
- Filename: `TIMESTAMP==readwise=TYPE--title.org`
- Include `#+property: READWISE_URL:`
- Organized by highlights

Don't create these manually; they're imported automatically.

### Meeting Notes
```org
#+title:      Team Meeting 2025-12-03
#+date:       [2025-12-03 Wed 10:00]
#+filetags:   :work:meetings:
#+identifier: 20251203T100000
#+category: work

* Attendees
- Alice
- Bob
- Charlie

* Agenda
** Topic 1
** Topic 2

* Action Items
- [ ] Alice: Follow up on X
- [ ] Bob: Complete Y by Friday
```

### Learning Notes
```org
#+title:      Learning Rust Ownership
#+date:       [2025-12-03 Wed 16:00]
#+filetags:   :learning:rust:programming:
#+identifier: 20251203T160000
#+category: learning

* Key Concepts
** Ownership Rules
1. Each value has an owner
2. Only one owner at a time
3. Value dropped when owner goes out of scope

* Examples
#+begin_src rust
fn main() {
    let s = String::from("hello");
}
#+end_src

* Resources
- [[https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html][Rust Book: Ownership]]
```

### Project Notes
```org
#+title:      Claude AI Infrastructure Project
#+date:       [2025-12-03 Wed 15:18]
#+filetags:   :project:ai:infrastructure:
#+identifier: 20251203T151800
#+category: project

* Project Goals
- [ ] Goal 1
- [ ] Goal 2

* Timeline
** Phase 1: Setup
SCHEDULED: <2025-12-05 Fri>

** Phase 2: Implementation
SCHEDULED: <2025-12-10 Wed>

* Resources
- [[file:other-note.org][Related Note]]
```

## Integration with Tools

### Emacs Denote
If using Emacs denote package:
- `denote` - Create new note
- `denote-link` - Link to existing note
- `denote-org-extras-link-to-heading` - Link to specific heading
- `denote-rename-file` - Rename note (updates title/tags)

### Ripgrep Searches
```bash
# Find notes mentioning "wireguard"
rg -i "wireguard" ~/desktop/org/notes/

# Find notes with specific tag pattern
rg -i "#+filetags:.*:nixos:" ~/desktop/org/notes/
```

## History Integration

### When to Create History-Linked Notes

Create notes with `:history:` tags when:
- Documenting significant work sessions
- Capturing important learnings from debugging
- Recording research findings worth referencing
- Noting architecture decisions

### History Note Format

**Filename with pkai signature**:
```
YYYYMMDDTHHMMSS==pkai--description__history_category_tags.org
```

**Content**:
```org
#+title:      <Title>
#+date:       [YYYY-MM-DD Day HH:MM]
#+filetags:   :history:category:topic1:topic2:
#+identifier: YYYYMMDDTHHMMSS
#+category: history

* Context
What this documents

* Details
Main content

* Related History Entries
- [[file:~/.config/claude/history/sessions/2025-12/...][Session Entry]]
- [[file:~/.config/claude/history/learnings/2025-12/...][Learning Entry]]

* Related Notes
- [[file:~/desktop/org/notes/...][Other Note]]
```

**Note**: The `==pkai` signature marks this as a history-system generated note.

### Finding History Notes

```bash
# All history notes (by tag)
ls ~/desktop/org/notes/*__history*.org

# All automated history notes (by signature)
ls ~/desktop/org/notes/*==pkai*.org

# Specific category
ls ~/desktop/org/notes/*__history_session*.org
ls ~/desktop/org/notes/*==pkai*__history_learning*.org

# Search content
rg "topic" ~/desktop/org/notes/*__history*.org
rg "topic" ~/desktop/org/notes/*==pkai*.org
```

### Cross-Referencing

**From Notes to History**:
```org
* Related History
- [[file:~/.config/claude/history/sessions/2025-12/2025-12-03-150000_SESSION_implementation.md][Implementation Session]]
```

**From History to Notes**:
```markdown
## Related Notes
- [[file:~/desktop/org/notes/20251203T151822--topic__history_session.org][Topic Note]]
```

See the `history-system` skill for complete integration details.

## Tips

1. **Timestamps are unique**: Use current time for new notes
2. **Tags are lowercase**: Keep them simple and consistent
3. **Link liberally**: Connect related notes and history entries
4. **Use TODO items**: Make notes actionable
5. **Include examples**: Code, commands, configurations
6. **Reference sources**: Link to documentation, articles
7. **Review regularly**: Update and refine over time
8. **History tag**: Add `:history:` for integration with history system

## Example Workflow

1. Identify topic to document
2. Generate timestamp: `date +"%Y%m%dT%H%M%S"`
3. Choose 2-4 relevant tags
4. Create filename: `TIMESTAMP--topic-description__tag1_tag2.org`
5. Add org-mode frontmatter
6. Write content with headings, links, code blocks
7. Add TODO items for follow-up
8. Link related notes

Remember: Notes are living documents. It's okay to update, refine, and reorganize as understanding deepens.

## Examples

**Example 1: Creating a new note**
```
User: "Create a note about NixOS flakes best practices"
→ Generates timestamp identifier
→ Creates denote-formatted filename with tags
→ Adds org-mode frontmatter (title, date, filetags)
→ Structures content with headings
→ Saves to ~/desktop/org/notes/
→ Result: Well-organized note ready for future reference
```

**Example 2: Finding related notes**
```
User: "Show me notes about Tekton"
→ Searches denote notes by tag: :tekton:
→ Also searches by title and content
→ Returns list of matching notes with timestamps
→ Shows snippets of relevant content
→ Result: Quick access to all Tekton-related knowledge
```

**Example 3: Linking notes together**
```
User: "Link this note to my CI/CD planning note"
→ Finds target note by search
→ Adds denote link using org-mode format
→ Creates bidirectional reference
→ Updates related notes section
→ Result: Knowledge graph connections established
```
