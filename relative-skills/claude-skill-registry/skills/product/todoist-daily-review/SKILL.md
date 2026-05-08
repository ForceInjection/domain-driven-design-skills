---
name: todoist-daily-review
description: Reviews today's Todoist tasks for tools/articles to investigate. Researches each item via web search, generates structured markdown summaries, appends to Obsidian daily notes, and marks tasks complete. Use when user asks to review Todoist items, do daily review, or process investigation tasks.
---

# Todoist Daily Review Skill

This Skill automates the workflow for reviewing and documenting Todoist investigation tasks (tools, articles, resources) by researching them, creating summaries, and updating your daily notes.

## Workflow Overview

When activated, you should:
1. Fetch today's Todoist tasks
2. Identify investigation items (tools, articles, resources)
3. For each item: research, summarize, document, and mark complete
4. Report summary of what was processed

## Step-by-Step Instructions

### Step 1: Fetch Today's Todoist Tasks

Run the following command to get today's tasks:

```bash
todoist list --filter "today"
```

Parse the output to extract:
- Task IDs (first column)
- Task titles/descriptions

**Error Handling:**
- If `todoist` command not found, inform user to install it: `brew install sachaos/todoist/todoist` or visit https://github.com/sachaos/todoist
- If no tasks found, inform user and exit gracefully

### Step 2: Identify Investigation Items

Filter tasks to find investigation items. Look for patterns like:

**Include items that are:**
- GitHub links/repos (e.g., "github.com/user/repo")
- Article titles or blog post names
- Tool/library/framework names
- Tasks with keywords: "Read", "Investigate", "Check out", "Review", "Research"
- URLs or domain names
- Technology/concept names to learn about

**Exclude action items like:**
- "Register [domain]"
- "Buy/Sell/Purchase"
- "Configure/Setup/Install [thing]" (unless it's to learn about the tool)
- "Check in with [person]"
- "Schedule/Book/Call"
- Tasks with specific deadlines that are action-oriented

**Ask the user for confirmation** if unsure whether a task is an investigation item. Present the list of identified items and let them confirm or adjust.

### Step 3: Process Each Investigation Item

For each identified item, follow these sub-steps:

#### 3a. Research the Topic

Use the `WebSearch` tool to gather information about the tool/article/topic:

- Search for: official website, GitHub repo, documentation
- Focus on: what it is, key features, why it's useful, use cases
- Look for: primary links, related resources

**Tips:**
- For GitHub repos: include the repo name in search
- For articles: search by title and author if available
- For tools: search for "what is [tool]" and "[tool] features"

#### 3b. Generate Structured Summary

Create a markdown summary using this template:

```markdown
### [Tool/Topic Name]
**Link:** [primary URL]
**Additional Resources:** [optional secondary links]

**What it is:** [Brief 1-2 sentence description]

**Key Features:**
- [Feature 1]
- [Feature 2]
- [Feature 3]
- [etc.]

**Why it's interesting:** [Relevance, benefits, what problems it solves]

**Use case:** [When/how to use it, practical applications]

**Next steps:** [Optional: what to explore further, try out, or configure]
```

**Quality Guidelines:**
- Be concise but informative
- Focus on practical value and use cases
- Include specific features, not just general descriptions
- Add personal relevance when possible (why this matters to the user)

#### 3c. Append to Obsidian Daily Note

**Locate the Obsidian vault:**
1. First try: `obsidian-cli print-default` to get default vault path
2. If that fails, use known path: `/Users/steve/Documents/Main`
3. If unsure, ask user for vault location

**Construct daily note path:**
- Format: `{vault_path}/Daily/{YYYY-MM-DD}.md`
- Example: `/Users/steve/Documents/Main/Daily/2025-10-18.md`
- Use today's date in YYYY-MM-DD format

**Update the file:**
1. Read the existing daily note (use `Read` tool)
2. If file doesn't exist, create it with a simple header:
   ```markdown
   # [Date]

   ## Todoist Review

   ```
3. Append the summary to the file under a "## Todoist Review" section
   - If section exists, append to it
   - If not, create the section before appending
4. Use the `Edit` or `Write` tool to update the file
5. **Important:** Use direct file editing, NOT the obsidian-cli, to avoid shell escaping issues with special characters

**Error Handling:**
- If vault not found, ask user for correct path
- If file permissions error, inform user
- If obsidian-cli not installed, fall back to manual path construction

#### 3d. Mark Task Complete in Todoist

After successfully documenting the item, mark it complete:

```bash
todoist close <task-id>
```

**Error Handling:**
- If close fails, inform user but continue with next item
- Log which tasks were completed vs. which failed

### Step 4: Report Summary

After processing all items, provide a summary:

```
Todoist Daily Review Complete!

Processed [N] items:
- [Topic 1]
- [Topic 2]
- [Topic 3]

All summaries added to: [path to daily note]

Tasks marked complete: [N/N successful]
```

## Error Handling & Edge Cases

**Missing Dependencies:**
- Todoist CLI not installed → Provide installation instructions
- Obsidian vault not found → Ask user for vault path
- Web search fails → Note in summary and continue with next item

**No Investigation Items Found:**
- Inform user that no investigation items were found in today's tasks
- Optionally ask if they want to process a different date or filter

**Daily Note Issues:**
- If daily note doesn't exist, create it
- If section structure is different, append at end with clear heading
- Always verify content was written by reading the file after editing

**Partial Failures:**
- If some items fail to process, continue with others
- Report which succeeded and which failed
- Don't mark tasks complete if their research/documentation failed

## Customization & Flexibility

**User Preferences:**
- Ask about vault location if auto-detection fails
- Allow user to specify which specific items to process (skip auto-filtering)
- Support custom date ranges if requested (not just "today")

**Alternative Workflows:**
- If user has different daily note structure, adapt the section heading
- If user wants to review without marking complete, make that optional
- Support different summary templates if user requests

## Testing Checklist

When testing this Skill, verify:
- [ ] Todoist tasks fetch successfully
- [ ] Investigation items correctly identified
- [ ] Web search returns useful information
- [ ] Summaries follow the template format
- [ ] Daily note is updated correctly
- [ ] Tasks marked complete in Todoist
- [ ] Error handling works for missing tools/files
- [ ] Final summary is accurate and helpful

## Example Interaction

**User:** "Do my daily Todoist review"

**Expected Flow:**
1. Fetch today's tasks
2. Identify 3 investigation items
3. Research each via web search
4. Generate 3 markdown summaries
5. Append all to today's Obsidian daily note
6. Mark 3 tasks complete
7. Report: "Processed 3 items: [list]. All summaries added to /Users/steve/Documents/Main/Daily/2025-10-18.md"

## Technical Notes

**Tools Available:**
- `WebSearch` - for researching topics
- `Bash` - for running todoist and obsidian-cli commands
- `Read`, `Write`, `Edit` - for file operations
- `Glob`, `Grep` - for finding files if needed

**File Operations Best Practices:**
- Always use direct file editing, not echo/cat redirection
- Read files before editing to verify content
- Handle special characters (URLs, &, quotes) carefully
- Use absolute paths for all file operations

**Performance:**
- Process items sequentially (research → document → complete)
- Use parallel tool calls where possible (e.g., reading files)
- Don't batch completions - mark each complete immediately after processing

## References

- Todoist CLI: https://github.com/sachaos/todoist
- Obsidian CLI: https://github.com/Yakitrak/obsidian-cli
- Claude Skills Documentation: https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview
