---
name: person-profiler
description: Perform preliminary internet research on a person and generate a structured report. Use when the user asks to research, profile, or get information about a specific person by name.
---

# Person Profiler

This skill performs preliminary internet research on individuals and generates a structured markdown report to enable comprehensive follow-up research.

## When to Use

Invoke this skill when the user:
- Says "research [person name]"
- Asks "who is [person name]"
- Requests a profile or background on someone
- Wants preliminary information about an individual

## Research Process

1. **Initial Web Search**: Search for the person's name to gather basic information
2. **Follow-up Searches**: Based on initial findings, search for:
   - Professional affiliations (companies, organizations)
   - Content they've created (blogs, podcasts, YouTube channels)
   - Media appearances (interviews, articles, podcasts)
   - Recent news or updates

3. **Create Directory**: Create a directory using the person's name in lowercase with underscores (e.g., "John Doe" → `john_doe/`)

4. **Generate Files**: Create two files in the person's directory:
   - `profile.md` - The research report with four sections
   - `search.sh` - Bash script with all search queries

## Report Structure

The report MUST contain exactly these four sections:

### 1. Summary
- Who the person is (profession, role, title)
- Background (education, career history, notable achievements)
- Current affiliations (company, organization, institution)
- Areas of expertise or focus
- Notable accomplishments or contributions

### 2. Related Search Terms
A bulleted list of entities and terms associated with this person that could yield additional information:
- Company names they founded/work for
- Podcasts they host or co-host
- Blogs or substacks they write
- Books they've authored
- Projects or initiatives they lead
- Brands or products they're associated with
- Organizations they're affiliated with

### 3. Media Presence
Document the types of media where this person appears or creates content:
- **Podcasts**: List any podcasts they host, co-host, or frequently appear on
- **YouTube**: Channels they own or videos they appear in
- **Written Content**: Blogs, substacks, Medium, personal websites
- **Social Media**: Active platforms (Twitter/X, LinkedIn, etc.)
- **News Coverage**: Types of publications that cover them
- **Speaking**: Conferences, talks, interviews they give

### 4. Google Search Terms for Deep Research
A comprehensive bulleted list of specific Google search queries designed to find news, updates, and content about this person. Include:

- Basic searches: `"[person name]"`
- Site-specific searches for major publications:
  - `"[person name]" site:nytimes.com`
  - `"[person name]" site:wsj.com`
  - `"[person name]" site:techcrunch.com`
  - `"[person name]" site:substack.com`
  - etc.
- Company/project searches:
  - `"[company name]" site:nytimes.com`
  - `"[company name]" news`
- Content-specific searches:
  - `"[person name]" podcast`
  - `"[person name]" interview`
  - `"[person name]" youtube`
- Time-bound searches:
  - `"[person name]" after:2024-01-01`
  - `"[company name]" after:2024-01-01`
- Quote and exact match searches for disambiguation

## Output Format

1. **Create a directory**: Make a directory named `{person_name}/` (using underscores, lowercase) in the current working directory
2. **Save the profile**: Save the report as `{person_name}/profile.md`
3. **Generate search script**: Create `{person_name}/search.sh` containing all search queries from Section 4
4. **Make script executable**: Run `chmod +x {person_name}/search.sh`
5. **Execute the script**: Change into the directory and run the script: `cd {person_name} && ./search.sh`

Example: If researching "Vaden Masrani", create directory `vaden_masrani/` with:
- `vaden_masrani/profile.md` - The research profile
- `vaden_masrani/search.sh` - Executable bash script with search queries
- `vaden_masrani/results.db` - SQLite database with search results (created when script runs)

The script must be executed from within the person's directory so that results.db is created there.

### Search Script Format

The search script should:
- Be a zsh script with proper shebang (`#!/usr/bin/env zsh`)
- Use `gum` for pretty output
- Call `ddgs "[query]" --db results.db` for each search term from Section 4
- Be executable (chmod +x)

Example search.sh structure:
```bash
#!/usr/bin/env zsh

gum style --border rounded --padding "1 2" --bold "Running Google searches for [Person Name]"

echo ""
gum style --bold "Basic searches"
ddgs "[person name]" --db results.db
ddgs "[person name] latest news" --db results.db
ddgs "[person name] 2024" --db results.db

echo ""
gum style --bold "Site-specific searches"
ddgs "[person name] site:nytimes.com" --db results.db
ddgs "[person name] site:wsj.com" --db results.db
ddgs "[person name] site:techcrunch.com" --db results.db
ddgs "[company name] site:nytimes.com" --db results.db

echo ""
gum style --bold "Content-type searches"
ddgs "[person name] podcast interview" --db results.db
ddgs "[person name] youtube" --db results.db
ddgs "[person name] blog post" --db results.db

echo ""
gum style --bold "Time-bound searches"
ddgs "[person name] after:2024-01-01" --db results.db
ddgs "[company name] after:2024-01-01" --db results.db

echo ""
gum style --foreground 2 "✓ All searches complete! Results saved to results.db"
```

## Example Report Template

```markdown
# [Person Name] - Preliminary Research Profile

## 1. Summary

[2-4 paragraph overview covering who they are, background, affiliations, and expertise]

## 2. Related Search Terms

- [Company name]
- [Podcast name]
- [Blog/Substack name]
- [Project or initiative]
- [Organization name]

## 3. Media Presence

**Podcasts**
- [Podcast they host or appear on]

**YouTube**
- [Channel or notable videos]

**Written Content**
- [Blog, Substack, or website]

**Social Media**
- [Active platforms]

**News Coverage**
- [Types of publications that cover them]

**Speaking/Conferences**
- [Notable talks or events]

## 4. Google Search Terms for Deep Research

Basic searches:
- "[person name]"
- "[person name]" latest news
- "[person name]" 2024
- "[person name]" 2025

Site-specific searches:
- "[person name]" site:nytimes.com
- "[person name]" site:wsj.com
- "[person name]" site:techcrunch.com
- "[person name]" site:substack.com
- "[person name]" site:medium.com
- "[company name]" site:nytimes.com
- "[podcast name]" site:spotify.com

Content-type searches:
- "[person name]" podcast interview
- "[person name]" youtube
- "[person name]" blog post
- "[person name]" conference talk

Time-bound searches:
- "[person name]" after:2024-01-01
- "[company name]" after:2024-01-01
- "[person name]" before:2024-01-01 after:2023-01-01

Combined searches:
- "[person name]" AND "[topic]"
- "[company name]" AND "funding"
- "[person name]" AND "controversy"
```

## Best Practices

1. **Use multiple search queries**: Don't rely on a single search. Try variations of the person's name and related terms.

2. **Verify information**: Cross-reference facts from multiple sources when possible.

3. **Note the date**: Include when the profile was generated, as information may become outdated.

4. **Be thorough with search terms**: Think creatively about what sites might have information (industry-specific publications, academic databases, social media platforms).

5. **Consider disambiguation**: If the name is common, add context to search terms (e.g., "[person name]" AND "[company]" OR "[field]").

6. **Respect privacy**: Focus on publicly available information. Don't speculate about private matters.

7. **Generate comprehensive search script**: Include ALL search queries from Section 4 in the search.sh script. Each query should be a separate `ddgs` call. Group related queries with gum style headers for better organization.

8. **Automatically execute searches**: After creating and making the script executable, change into the person's directory and run it immediately to gather all search results into `results.db` within that directory.

## Notes

- This is a preliminary research tool. The report is designed to enable deeper, more focused research in a second pass.
- The search script is automatically executed after creation, saving all results to a SQLite database (`{person_name}/results.db`) for easy querying and analysis.
- You can re-run the search script later by executing: `cd {person_name} && ./search.sh`
- All search results are stored in `{person_name}/results.db` which can be queried using sqlite3 or other database tools.
- Adapt the depth of research based on how prominent the person is (public figures will have more information available).
