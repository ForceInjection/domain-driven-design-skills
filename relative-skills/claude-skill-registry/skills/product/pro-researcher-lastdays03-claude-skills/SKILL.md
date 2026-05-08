---
name: pro-researcher
description: Standards for professional web research using Plan-and-Solve and Cross-Lingual strategies.
---

# Pro Researcher Standards

## Core Principles
**"Search Smarter, Not Harder"**
To provide high-quality, verified information by strictly following a Plan-and-Solve methodology.

1.  **Plan-and-Solve**: Never search blindly. Always define "What" and "Where" before executing.
2.  **Cross-Lingual Strategy 🌏**:
    - **Global Depth**: Use English inputs for global trends, tech docs, and academic papers.
    - **Local Context**: Use Korean inputs for domestic market reality, regulations, and implementation status.
    - **Synthesis**: Merge both perspectives into a unified insight.
3.  **Traceability & Verification**:
    - Every claim must have a citation.
    - Every tool usage (Query/URL) must be logged in the Appendix.

## Quality Standards
- **Synthesis**: Do not just list facts. Connect the dots to answer the "So What?".
- **Citation Format**: `[Title](URL)` must be appended to the relevant sentence.
- **Search Log**: The final report MUST include an **Appendix** listing all search queries and visited URLs.
- **Tool Hygiene**: Check tool availability (Phase 0) before promising results.

## Phase 0: Tool Verification (Pre-flight) 🛠️
Before starting research, verify the toolset:
1.  **Check `search_web`**:
    - If unavailable: Warn user "Internet access is strictly limited. Please configure an MCP server for Google/Brave Search." and proceed with limited capability if user insists.
2.  **Check `browser_subagent`**:
    - If unavailable: Route to `read_url_content` (Text-only mode). Note this in the plan.

## Phase 1: Research Design (Plan) 📝
- **Objective**: Clarify the user's intent (Actionable/Informational?).
- **Keyword Strategy**:
    - Define **English Keywords** for breadth (e.g., "Generative AI Market Size 2025").
    - Define **Korean Keywords** for nuance (e.g., "국내 생성형 AI 도입 페인포인트").
- **Source Targeting**:
    - Select trustworthy domains (e.g., Gartner, Official Docs) over generic SEO blobs.

## Phase 2: Information Gathering (Fetch Loop) 🕵️
- **Execution**:
    1.  **Search**: Execute `search_web` with planned keywords.
    2.  **Filter**: Select best 3-5 URLs per topic based on snippet relevance.
    3.  **Fetch**: Use `read_url_content` to get full text.
    4.  **Deep Dive**: If text is insufficient or requires interaction (e.g., dynamic JS), use `browser_subagent` (if available).
- **Evaluation**: "Do I have enough to answer the Key Question?"
    - **No**: Refine keywords and loop one more time (Max 3 iterations).
    - **Yes**: Proceed to synthesis.

## Phase 3: Analysis & Synthesis (Report) 📊
- **Structure**: Follow the `report-template.md`.
- **Logic**: Use Minto Pyramid (Conclusion First).
- **Transparency**:
    - **Inline Citation**: `...according to Gartner [1]...`
    - **Reference List**: `[1] Gartner Report (url)`
    - **Search Log Table**: `| Query | URL | Status |`

## Checklist
- [ ] **Phase 0**: Did I check tool availability?
- [ ] **Planning**: Did I generate BOTH English and Korean keywords?
- [ ] **Sourcing**: Did I fetch full content (not just snippets) for key authorities?
- [ ] **Transparency**: Is the Search Log included in the Appendix?
