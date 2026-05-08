---
name: google-docs
description: Manage Google Docs and Google Drive with full document operations and file management. Includes document reading, editing, formatting, and Drive operations (upload, download, share, search). Use for document content operations, Drive file management, and integration with other Google services.
category: productivity
version: 1.1.0
key_capabilities: read content, insert/append/replace text, format text, Drive upload/download/share/search
when_to_use: Document content operations, text insertion/replacement, formatting, Drive file management, sharing files
---

# Google Docs & Drive Management Skill

## Purpose

Manage Google Docs documents and Google Drive files with comprehensive operations:

**Google Docs:**
- Read document content and structure
- Insert and append text
- Find and replace text
- Basic text formatting (bold, italic, underline)
- Insert page breaks
- Create new documents
- Delete content ranges
- Get document structure (headings)
- Insert inline images from URLs

**Google Drive:**
- Upload files to Drive
- Download files from Drive
- Search and list files
- Share files with users or publicly
- Create folders
- Move, copy, and delete files
- Get file metadata

**Integration**: The drive_manager.rb script shares OAuth credentials with docs_manager.rb

**📚 Additional Resources**:
- See `references/integration-patterns.md` for complete workflow examples
- See `references/troubleshooting.md` for error handling and debugging
- See `references/cli-patterns.md` for CLI interface design rationale

## When to Use This Skill

Use this skill when:
- User requests to read or view a Google Doc
- User wants to create a new document
- User wants to edit document content
- User requests text formatting or modifications
- User asks about document structure or headings
- User wants to find and replace text
- Keywords: "Google Doc", "document", "edit doc", "format text", "insert text"

**📋 Discovering Your Documents**:
To list or search for documents, use drive_manager.rb:
```bash
# List recent documents
scripts/drive_manager.rb search \
  --query "mimeType='application/vnd.google-apps.document'" \
  --max-results 50

# Search by name
scripts/drive_manager.rb search \
  --query "name contains 'Report' and mimeType='application/vnd.google-apps.document'"
```

## Core Workflows

### 1. Read Document

**Read full document content**:
```bash
scripts/docs_manager.rb read <document_id>
```

**Get document structure (headings)**:
```bash
scripts/docs_manager.rb structure <document_id>
```

**Output**:
- Full text content with paragraphs
- Document metadata (title, revision ID)
- Heading structure with levels and positions

### 2. Create Documents

**Create new document**:
```bash
echo '{
  "title": "Project Proposal",
  "content": "# Project Proposal\n\nIntroduction text here..."
}' | scripts/docs_manager.rb create
```

**Create empty document**:
```bash
echo '{
  "title": "New Document"
}' | scripts/docs_manager.rb create
```

**Document ID**:
- Returned in response for future operations
- Use with drive_manager.rb for sharing/organizing

### 3. Insert and Append Text

**Insert text at specific position**:
```bash
echo '{
  "document_id": "abc123",
  "text": "This text will be inserted at the beginning.\n\n",
  "index": 1
}' | scripts/docs_manager.rb insert
```

**Append text to end of document**:
```bash
echo '{
  "document_id": "abc123",
  "text": "\n\nThis text will be appended to the end."
}' | scripts/docs_manager.rb append
```

**Index Positions**:
- Document starts at index 1
- Use `read` command to see current content
- Use `structure` command to find heading positions
- End of document: use `append` instead of calculating index

### 4. Find and Replace

**Simple find and replace**:
```bash
echo '{
  "document_id": "abc123",
  "find": "old text",
  "replace": "new text"
}' | scripts/docs_manager.rb replace
```

**Case-sensitive replacement**:
```bash
echo '{
  "document_id": "abc123",
  "find": "IMPORTANT",
  "replace": "CRITICAL",
  "match_case": true
}' | scripts/docs_manager.rb replace
```

**Replace all occurrences**:
- Automatically replaces all matches
- Returns count of replacements made
- Use for bulk text updates

### 5. Text Formatting

**Format text range (bold)**:
```bash
echo '{
  "document_id": "abc123",
  "start_index": 1,
  "end_index": 20,
  "bold": true
}' | scripts/docs_manager.rb format
```

**Multiple formatting options**:
```bash
echo '{
  "document_id": "abc123",
  "start_index": 50,
  "end_index": 100,
  "bold": true,
  "italic": true,
  "underline": true
}' | scripts/docs_manager.rb format
```

**Formatting Options**:
- `bold`: true/false
- `italic`: true/false
- `underline`: true/false
- All options are independent and can be combined

### 6. Page Breaks

**Insert page break**:
```bash
echo '{
  "document_id": "abc123",
  "index": 500
}' | scripts/docs_manager.rb page-break
```

**Use Cases**:
- Separate document sections
- Start new content on fresh page
- Organize long documents

### 7. Delete Content

**Delete text range**:
```bash
echo '{
  "document_id": "abc123",
  "start_index": 100,
  "end_index": 200
}' | scripts/docs_manager.rb delete
```

**Clear entire document**:
```bash
# Read document first to get end index
scripts/docs_manager.rb read abc123

# Then delete all content (start at 1, end at last index - 1)
echo '{
  "document_id": "abc123",
  "start_index": 1,
  "end_index": 500
}' | scripts/docs_manager.rb delete
```

### 8. Insert Images

**Insert image from URL**:
```bash
echo '{
  "document_id": "abc123",
  "image_url": "https://storage.googleapis.com/bucket/image.png"
}' | scripts/docs_manager.rb insert-image
```

**Insert image with specific size**:
```bash
echo '{
  "document_id": "abc123",
  "image_url": "https://storage.googleapis.com/bucket/image.png",
  "width": 400,
  "height": 300
}' | scripts/docs_manager.rb insert-image
```

**Insert image at specific position**:
```bash
echo '{
  "document_id": "abc123",
  "image_url": "https://storage.googleapis.com/bucket/image.png",
  "index": 100
}' | scripts/docs_manager.rb insert-image
```

**Image URL Requirements**:
- URL must be publicly accessible (Google Docs fetches the image)
- Supported formats: PNG, JPEG, GIF
- SVG is NOT supported - convert to PNG first
- For private images, upload to GCS and make public, or use signed URLs

**Sizing Tips**:
- To fit page width with default margins: use `width: 468` (points)
- Specifying only width will auto-scale height proportionally
- Specifying only height will auto-scale width proportionally
- 1 inch = 72 points

## Natural Language Examples

### User Says: "Read the content of this Google Doc: abc123"
```bash
scripts/docs_manager.rb read abc123
```

### User Says: "Create a new document called 'Meeting Notes' with the text 'Attendees: John, Sarah'"
```bash
echo '{
  "title": "Meeting Notes",
  "content": "Attendees: John, Sarah"
}' | scripts/docs_manager.rb create
```

### User Says: "Add 'Next Steps' section to the end of document abc123"
```bash
echo '{
  "document_id": "abc123",
  "text": "\n\n## Next Steps\n\n- Review proposals\n- Schedule follow-up"
}' | scripts/docs_manager.rb append
```

### User Says: "Replace all instances of 'Q3' with 'Q4' in document abc123"
```bash
echo '{
  "document_id": "abc123",
  "find": "Q3",
  "replace": "Q4"
}' | scripts/docs_manager.rb replace
```

### User Says: "Make the first 50 characters of document abc123 bold"
```bash
echo '{
  "document_id": "abc123",
  "start_index": 1,
  "end_index": 50,
  "bold": true
}' | scripts/docs_manager.rb format
```

## Understanding Document Index Positions

**Index System**:
- Documents use zero-based indexing with offset
- Index 1 = start of document (after title)
- Each character (including spaces and newlines) has an index
- Use `read` to see current content and plan insertions
- Use `structure` to find heading positions

**Finding Positions**:
1. Read document to see content
2. Count characters to desired position
3. Or use heading structure for section starts
4. Remember: index 1 = very beginning

**Example**:
```
"Hello World\n\nSecond paragraph"

Index 1: "H" (start)
Index 11: "\n" (first newline)
Index 13: "S" (start of "Second")
Index 29: end of document
```

## Google Drive Operations

The `drive_manager.rb` script provides comprehensive Google Drive file management.

### Upload Files

```bash
# Upload a file to Drive root
scripts/drive_manager.rb upload --file ./document.pdf

# Upload to specific folder
scripts/drive_manager.rb upload --file ./diagram.excalidraw --folder-id abc123

# Upload with custom name
scripts/drive_manager.rb upload --file ./local.txt --name "Remote Name.txt"
```

### Download Files

```bash
# Download a file
scripts/drive_manager.rb download --file-id abc123 --output ./local_copy.pdf

# Export Google Doc as PDF
scripts/drive_manager.rb download --file-id abc123 --output ./doc.pdf --export-as pdf

# Export Google Sheet as CSV
scripts/drive_manager.rb download --file-id abc123 --output ./data.csv --export-as csv
```

### Search and List Files

```bash
# List recent files
scripts/drive_manager.rb list --max-results 20

# Search by name
scripts/drive_manager.rb search --query "name contains 'Report'"

# Search by type
scripts/drive_manager.rb search --query "mimeType='application/vnd.google-apps.document'"

# Search in folder
scripts/drive_manager.rb search --query "'folder_id' in parents"

# Combine queries
scripts/drive_manager.rb search --query "name contains '.excalidraw' and modifiedTime > '2024-01-01'"
```

### Share Files

```bash
# Share with specific user (reader)
scripts/drive_manager.rb share --file-id abc123 --email user@example.com --role reader

# Share with write access
scripts/drive_manager.rb share --file-id abc123 --email user@example.com --role writer

# Make publicly accessible (anyone with link)
scripts/drive_manager.rb share --file-id abc123 --type anyone --role reader

# Share with entire domain
scripts/drive_manager.rb share --file-id abc123 --type domain --domain example.com --role reader
```

### Folder Management

```bash
# Create a folder
scripts/drive_manager.rb create-folder --name "Project Documents"

# Create folder inside another folder
scripts/drive_manager.rb create-folder --name "Diagrams" --parent-id abc123

# Move file to folder
scripts/drive_manager.rb move --file-id file123 --folder-id folder456
```

### Other Operations

```bash
# Get file metadata
scripts/drive_manager.rb get-metadata --file-id abc123

# Copy a file
scripts/drive_manager.rb copy --file-id abc123 --name "Copy of Document"

# Update file content (replace)
scripts/drive_manager.rb update --file-id abc123 --file ./new_content.pdf

# Delete file (moves to trash)
scripts/drive_manager.rb delete --file-id abc123
```

### Output Format

All commands return JSON with consistent structure:
```json
{
  "status": "success",
  "operation": "upload",
  "file": {
    "id": "1abc...",
    "name": "document.pdf",
    "mime_type": "application/pdf",
    "web_view_link": "https://drive.google.com/file/d/1abc.../view",
    "web_content_link": "https://drive.google.com/uc?id=1abc...",
    "created_time": "2024-01-15T10:30:00Z",
    "modified_time": "2024-01-15T10:30:00Z",
    "size": 12345
  }
}
```

---

## Integration Workflows

### Create and Organize Documents

```bash
# Step 1: Create document (returns document_id)
echo '{"title":"Report"}' | scripts/docs_manager.rb create
# Returns: {"document_id": "abc123"}

# Step 2: Add content
echo '{"document_id":"abc123","text":"# Report\n\nContent here"}' | scripts/docs_manager.rb insert

# Step 3: Organize in folder
scripts/drive_manager.rb move --file-id abc123 --folder-id [folder_id]

# Step 4: Share with team
scripts/drive_manager.rb share --file-id abc123 --email team@company.com --role writer
```

### Export Document to PDF

```bash
scripts/drive_manager.rb download --file-id abc123 --output ./report.pdf --export-as pdf
```

### Excalidraw Diagrams Workflow

For creating and managing Excalidraw diagrams, see the `excalidraw-diagrams` skill which integrates with drive_manager.rb for:
- Uploading .excalidraw files to Drive
- Getting shareable edit URLs for Excalidraw web
- Round-trip editing between AI and human

## Authentication Setup

**Shared with Other Google Skills**:
- Uses same OAuth credentials and token
- Located at: `~/.claude/.google/client_secret.json` and `~/.claude/.google/token.json`
- Shares token with email, calendar, contacts, drive, and sheets skills
- Requires Documents, Drive, Sheets, Calendar, Contacts, and Gmail API scopes

**First Time Setup**:
1. Run any docs operation
2. Script will prompt for authorization URL
3. Visit URL and authorize all Google services
4. Enter authorization code when prompted
5. Token stored for all Google skills

**Re-authorization**:
- Token automatically refreshes when expired
- If refresh fails, re-run authorization flow
- All Google skills will work after single re-auth

## Bundled Resources

### Scripts

**`scripts/docs_manager.rb`**
- Comprehensive Google Docs API wrapper
- All document operations: read, create, insert, append, replace, format, delete
- Document structure analysis (headings)
- Automatic token refresh
- Shared OAuth with other Google skills

**Operations**:
- `read`: View document content
- `structure`: Get document headings and structure
- `insert`: Insert text at specific index
- `append`: Append text to end
- `replace`: Find and replace text
- `format`: Apply text formatting (bold, italic, underline)
- `page-break`: Insert page break
- `create`: Create new document
- `delete`: Delete content range

**Output Format**:
- JSON with `status: 'success'` or `status: 'error'`
- Document operations return document_id and revision_id
- See script help: `scripts/docs_manager.rb --help`

### References

**`references/docs_operations.md`**
- Complete operation reference
- Parameter documentation
- Index position examples
- Common workflows

**`references/formatting_guide.md`**
- Text formatting options
- Style guidelines
- Document structure best practices
- Heading hierarchy

### Examples

**`examples/sample_operations.md`**
- Common document operations
- Workflow examples
- Index calculation examples
- Integration with drive_manager.rb for file operations

## Error Handling

**Authentication Error**:
```json
{
  "status": "error",
  "code": "AUTH_ERROR",
  "message": "Token refresh failed: ..."
}
```
**Action**: Guide user through re-authorization

**Document Not Found**:
```json
{
  "status": "error",
  "code": "API_ERROR",
  "message": "Document not found"
}
```
**Action**: Verify document ID, check permissions

**Invalid Index**:
```json
{
  "status": "error",
  "code": "API_ERROR",
  "message": "Invalid index position"
}
```
**Action**: Read document to verify current length, adjust index

**API Error**:
```json
{
  "status": "error",
  "code": "API_ERROR",
  "message": "Failed to update document: ..."
}
```
**Action**: Display error to user, suggest troubleshooting steps

## Best Practices

### Document Creation
1. Always provide meaningful title
2. Add initial content when creating for better context
3. Save returned document_id for future operations
4. Use drive_manager.rb to organize and share

### Text Insertion
1. Read document first to understand current structure
2. Use `structure` command to find heading positions
3. Index 1 = start of document
4. Use `append` for adding to end (simpler than calculating index)
5. Include newlines (\n) for proper formatting

### Find and Replace
1. Test pattern match first on small section
2. Use case-sensitive matching for precise replacements
3. Returns count of replacements made
4. Cannot undo - consider reading document first for backup

### Text Formatting
1. Calculate index positions carefully
2. Read document to verify text location
3. Can combine bold, italic, underline
4. Formatting applies to exact character range

### Document Structure
1. Use heading structure for navigation
2. Insert page breaks between major sections
3. Maintain consistent formatting throughout
4. Use `structure` command to validate hierarchy

## Quick Reference

**Read document**:
```bash
scripts/docs_manager.rb read <document_id>
```

**Create document**:
```bash
echo '{"title":"My Doc","content":"Initial text"}' | scripts/docs_manager.rb create
```

**Insert text at beginning**:
```bash
echo '{"document_id":"abc123","text":"New text","index":1}' | scripts/docs_manager.rb insert
```

**Append to end**:
```bash
echo '{"document_id":"abc123","text":"Appended text"}' | scripts/docs_manager.rb append
```

**Find and replace**:
```bash
echo '{"document_id":"abc123","find":"old","replace":"new"}' | scripts/docs_manager.rb replace
```

**Format text**:
```bash
echo '{"document_id":"abc123","start_index":1,"end_index":50,"bold":true}' | scripts/docs_manager.rb format
```

**Get document structure**:
```bash
scripts/docs_manager.rb structure <document_id>
```

**Insert image from URL**:
```bash
echo '{"document_id":"abc123","image_url":"https://example.com/image.png"}' | scripts/docs_manager.rb insert-image
```

**Insert image with size**:
```bash
echo '{"document_id":"abc123","image_url":"https://example.com/image.png","width":400,"height":300}' | scripts/docs_manager.rb insert-image
```

## Example Workflow: Creating and Editing a Report

1. **Create document**:
   ```bash
   echo '{"title":"Q4 Report"}' | scripts/docs_manager.rb create
   # Returns: {"document_id": "abc123"}
   ```

2. **Add initial content**:
   ```bash
   echo '{
     "document_id": "abc123",
     "text": "# Q4 Report\n\n## Executive Summary\n\nPlaceholder for summary.\n\n## Details\n\nPlaceholder for details."
   }' | scripts/docs_manager.rb insert
   ```

3. **Replace placeholders**:
   ```bash
   echo '{
     "document_id": "abc123",
     "find": "Placeholder for summary.",
     "replace": "Revenue increased 25% over Q3 targets."
   }' | scripts/docs_manager.rb replace
   ```

4. **Format heading**:
   ```bash
   echo '{
     "document_id": "abc123",
     "start_index": 1,
     "end_index": 12,
     "bold": true
   }' | scripts/docs_manager.rb format
   ```

5. **Share with team**:
   ```bash
   scripts/drive_manager.rb share --file-id abc123 --email team@company.com --role writer
   ```

## Version History

- **1.1.0** (2025-12-20) - Added Google Drive operations via drive_manager.rb: upload, download, search, list, share, move, copy, delete, folder management. Integrated with excalidraw-diagrams skill for diagram workflows.
- **1.0.0** (2025-11-10) - Initial Google Docs skill with full document operations: read, create, insert, append, replace, format, page breaks, structure analysis. Shared OAuth token with email, calendar, contacts, drive, and sheets skills.

---

**Dependencies**: Ruby with `google-apis-docs_v1`, `google-apis-drive_v3`, `googleauth` gems (shared with other Google skills)
