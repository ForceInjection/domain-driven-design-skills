---
name: notion-reader
description: Read specific Notion pages by ID
---

# Notion Reader Skill

Reads the content of a specific Notion page.

## When to Use

Use this skill when you need to:
- Read a specific Notion page by ID
- Extract content from OKR pages
- Get page properties and blocks

## How to Use

```bash
$CLAUDE_CONFIG_DIR/skills/notion-reader/scripts/read-page.sh "PAGE_ID"
```

### Arguments
- `PAGE_ID` (required): The Notion page ID (from the URL)

### Getting the Page ID

The page ID is the 32-character string in the Notion URL:
```
https://www.notion.so/OKR-2b70e96f0134807d8450c8793839c659
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                          This is the page ID
```

Remove hyphens if needed: `2b70e96f0134807d8450c8793839c659`

### Prerequisites
- `NOTION_API_KEY` environment variable must be set
- The Notion integration must have access to the page

## Output

Results are saved to `/tmp/data/notion_page_[timestamp].json`:

```json
{
  "id": "2b70e96f-0134-807d-8450-c8793839c659",
  "title": "OKR",
  "url": "https://notion.so/...",
  "created_time": "2024-01-01T00:00:00Z",
  "last_edited_time": "2024-12-15T10:00:00Z",
  "properties": {...},
  "content": [
    {
      "type": "heading_1",
      "text": "Q4 Objectives"
    },
    {
      "type": "paragraph",
      "text": "Our main goals for Q4..."
    },
    {
      "type": "bulleted_list_item",
      "text": "Key Result 1: ..."
    }
  ]
}
```

Console output:
```
Page: OKR
Last edited: 2024-12-15T10:00:00Z

Content Preview:
# Q4 Objectives
Our main goals for Q4...
- Key Result 1: ...
```

## Error Handling

- **401 Unauthorized**: Check that NOTION_API_KEY is set correctly
- **404 Not Found**: The page ID may be incorrect or the integration doesn't have access
- **400 Bad Request**: The page ID format is invalid
