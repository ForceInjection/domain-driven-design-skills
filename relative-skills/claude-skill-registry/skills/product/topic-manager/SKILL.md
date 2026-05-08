---
name: topic-manager
description: Expert in managing professional topics stored as structured Google Drive folders and Google Docs. **Use this skill whenever the user mentions "topic", "topics", "update topic", "create topic", "open topic", "one 2 one", "list topics", "describe topics", "summarize topics", "1-2-1", or asks to process meetings, records, or presentations related to topics.**
---

# Topic Manager Skill

Expert in managing professional topics stored as structured Google Drive folders and Google Docs. **Use this skill whenever the user mentions "topic", "topics", "update topic", "create topic", "one 2 one", "1-2-1", or asks to process meetings, records, or presentations related to topics.**

## Topic Structure

Topics are organized in Google Drive folder `Notes` (ID: `16VBlrwK2FAmIfzqN1g9h-sCkQ4YuHz8x`).

Each topic follows this structure:
```
Topics/
└── Topic_Name/
    ├── Topic_Name           # Google Doc (structured document)
    ├── Minutes/             # Meeting recordings, transcripts, notes (audio/video files)
    ├── Prez/                # Presentations, slides, schemas, diagrams (PPT, PDF, SVG, PNG)
    ├── Documents/           # Supporting documents, PDFs, one-pagers, executive summaries
    └── Emails/              # Email files (.eml files)
```

**File Type to Folder Mapping**:
- Audio/Video recordings → `Minutes/`
- Meeting notes/transcripts → `Minutes/`
- PowerPoint/PDF presentations → `Prez/`
- Mermaid diagrams (.mmd, .svg) → `Prez/`
- Schemas, architecture images → `Prez/`
- Emails (.eml files) → `Emails/`
- PDF documents, contracts, specifications, one-pagers, executive summaries → `Documents/`

## Topic Document Organization

The Topic_Name Google Doc MUST follow this exact structure described in markdown, between bracket you will find the style to use. I will put between parenthesis with `NB` to describe specific instruction for a section.

Remember that words between `**` must be `bold` in the google docs and words between `_` must be underlined. Don't used bold or underline outside this explicit mention in the below description. Remember for the bullet point to use native google docs bullet point.

```
# Topic Name [Title]

## Table of content [Heading 1]

## Presentation

**Owner**: Name of the Owner
**Application Services:** Name of application Service 1 (SNSVC<7_digits>), ... (NB: can have many)
**Executive summary:** 10 to 30 words describing the purpose of this topic.
**Objectives:** (NB: use native google docs bullet point)
- Objective 1 description
- Objective 2 description
...

## Actions [Heading 1]

### Action Name 1 [Heading 2]

#### Description [Heading 3]

**_Owner:_** Name of the owner
**_Status:_ {Not started,Framing,In progress,Done,Blocked,Canceled}** (NB only use this word, and set a text color: Not started is #000000, Framing and In progress are #bf9000, Done is #38761d, Blocked and Canceled are #990000)
**_ETA:_ {YYYY-Q1|YYYY-Q2|YYYY-Q3|YYYY-Q4|YYYY-MM}** (NB: use either quarterly format like "2025-Q2" or monthly format like "2025-03")

Text to describe the action precisely. Try to be concise as much as possible, but it must be clear.

#### Risks [Heading 3]

(NB: we can have several risks, leave the section empty of no risk have been identified)

##### Risk Name 1 [Heading 4]

###### Description [Heading 5]

**_Probability:_ {High,Medium,Low}** (NB: describe the risk probability with one of this 3 words and use text color: High is #990000, Medium is (#bf9000), Low is #38761d)
**_Impact:_ {High,Medium,Low}** (NB: describe the risk impact with one of this 3 words and use text color: High is #990000, Medium is (#bf9000), Low is #38761d)

Describe the risk

###### Mitigations [heading 5]

(NB: use native google docs bullet point)

- Mitigation action 1
- Mitigation action 2
...

## Minutes [Heading 1]

(NB: Always but the last meeting first, they must be classified in chronological order)

### Meeting/Summary title [Heading 2]

#### Attendees [Heading 3]

(NB: use native bullet point)
- Attendee 1
- Attendee 2
...

#### Summary [Heading 3]

(NB: use native bullet point)
- Key takeaway 1
- Key takeaway 2
...

#### Decision/Actions

(NB: use native bullet point)
- Action 1 (People in charge Name between parenthesis)
- Action 2 (People in charge Name between parenthesis)
...

#### Minutes

(NB: full transcription for audio records, or link to email/document)
- **Attendee 1:** what he said
- **Attendee 2:** what he said
- **Attendee 1:** what he said
...
```

## One-to-One Topics (Special Case)

One-to-One topics follow the rule below but have a simplified structure, here is the description:

```
# One 2 One <name of the people> [Title]

## Table of content [Heading 1]

## Next topics [Heading 1]

(NB: use bullet point for the next topics)
- topic 1
- topic 2
...

## Minutes [Heading 1]

### Attendees [Heading 2]

(NB: use native bullet point, normally one 2 one have just me and someone, but it can happen I want to store some meetings with more people here because they are related to decisions taken with this person, specifically for the top managers)
- Attendee 1
- Attendee 2
...

#### Summary [Heading 2]

(NB: use native bullet point)
- Key takeaway 1
- Key takeaway 2
...

#### Decision/Actions

(NB: use native bullet point)
- Action 1 (People in charge Name between parenthesis)
- Action 2 (People in charge Name between parenthesis)
...

#### Minutes

(NB: full transcription for audio records, or link to email/document)
- **Attendee 1:** what he said
- **Attendee 2:** what he said
- **Attendee 1:** what he said
...
```

When updating a One-to-One topic, minutes may reference or impact other topics - identify these cross-references and ask for confirmation if uncertain.

## Core Operations

### List Topics

When the user ask to list topics, you list all the folder in google drive folder `Notes` (ID: `16VBlrwK2FAmIfzqN1g9h-sCkQ4YuHz8x`).

If you find topics with duplicated names or similar names, you notify the user if an appropriate action should be done (merging).

### Create New Topic

**Trigger**: User asks to "create a new topic" or "create topic [name]"

**Process**:
1. List existing topic in `Notes` (ID: `16VBlrwK2FAmIfzqN1g9h-sCkQ4YuHz8x`) folder using `google-drive-manager` skill
2. If exists or similar, inform user and ask for confirmation to proceed
3. If not exists or confirmed:
   - Create topic folder in Notes
   - Create subfolders: Minutes, Prez, Documents, Emails
   - Create Google Doc from "Template v2" google doc (ID: `1lcUWzmqtj-h0OMdM_NcvDN_qa4EyAfwCgE-IZUAlLPc`) using `google-docs-manager` skill
   - The template provides only a basic heading skeleton - you must build the complete topic structure
   - Initialize the document following the Topic Document Organization structure (lines 36-122):
     - Replace "Title" heading with actual topic name
     - Build complete Presentation section with Owner, Application Services, Executive summary, Objectives
     - Create empty Actions, Risks, and Minutes sections with proper headings
     - Apply all formatting rules (bold, underline, colors) as specified in the template

**Ask user**: If topic exists, confirm overwrite/merge strategy

### Update Topic

**Trigger**: User asks to "update topic [name]" with various inputs (records, presentations, emails, documents, or plain text)

**8-Step Process Overview**:
1. Gather and identify materials
2. Upload documents to appropriate subfolders WITHIN topic folder
3. Extract information from each source
4. Analyze and synthesize information
5. Propose changes to user
6. Update Google Doc (structure preservation critical)
7. **Cleanup local files** (CRITICAL for privacy/disk space)
8. Confirm completion

**Input Types to Handle**:
- **Audio/Video records** (mp3, ogg, mp4, etc.): Use `speech-to-text` skill to transcribe
  - If video: extract audio first, ignore visual content
  - **Meeting date source**: Recording date from filename. If missing ask to the user to provide it.
- **Presentations** (PowerPoint, PDF): Use `pdf-extractor` skill after converting to PDF if needed
- **Images**: Apply OCR using `pdf-extractor` skill
- **Emails** (.eml): Use `email-extractor` skill to extract content, parse threads, and extract attachments
  - **Meeting date source**: Email Date header
  - **Treatment**: Each email = ONE minute entry, THEN extract info to update Actions/Risks/Presentation sections
- **Plain text**: Meeting notes provided directly by user
- **Mixed inputs**: Process each according to type

**Email Processing Rules** (⚠️ Two-Phase Processing):
1. **Phase 1 - Create Minute Entry**: Each `.eml` file creates **ONE minute entry** in the Minutes section (treat it like a meeting record)
   - **Date source**: Email's Date header (NOT filename, NOT received date)
   - **Attendees**: From To/Cc fields
   - **Meeting title**: Email subject line
2. **Phase 2 - Extract Information**: After creating the minute entry, analyze the email content to:
   - Create/update Actions section
   - Create/update Risks section
   - Update Presentation/Description section
   - Update existing action logs if referenced
3. **Upload location**: Upload the `.eml` file to `{Topic_Name}/Emails/` folder
4. **Link reference**: Link the `.eml` file in the minute entry's d) Minutes subsection

**Common Email Processing Mistakes**:
- ❌ Creating multiple minute entries for one email
- ❌ Using filename date instead of email Date header
- ❌ Skipping Phase 2 (only creating minute without extracting actions/risks)

**Detailed Process**:

**Step 1: Gather and Identify Materials**
- Identify topic name (ask if unclear)
- Identify all provided materials (records, presentations, emails, images, text)
- Locate topic folder using `google-drive-manager` skill

**Step 2: Upload Documents to Appropriate Subfolders WITHIN the Topic Folder**
⚠️ **CRITICAL**: All files MUST be uploaded to subfolders INSIDE the topic's folder, NOT at root level
NB: If a subfolder is missing, create it.
- Use `google-drive-manager` skill to upload to the correct subfolder path:
  - Audio/Video recordings → `{Topic_Name}/Minutes/` folder
  - Meeting notes/transcripts → `{Topic_Name}/Minutes/` folder
  - PowerPoint/PDF presentations → `{Topic_Name}/Prez/` folder
  - Mermaid diagrams (.mmd, .svg) → `{Topic_Name}/Prez/` folder
  - Schemas, architecture images → `{Topic_Name}/Prez/` folder
  - Emails (.eml files) → `{Topic_Name}/Emails/` folder
  - PDF documents, contracts, specifications → `{Topic_Name}/Documents/` folder
  - One-pagers, executive summaries, briefings → `{Topic_Name}/Documents/` folder
- **Create the subfolder if it doesn't exist** (Minutes, Prez, Documents, Emails)
- Track all uploaded file IDs and URLs for linking

**Step 3: Extract Information from Each Source**
- **For video files**:
  - Use `video-creator` skill to extract audio first (ignore visual content)
  - Then use `speech-to-text` skill to transcribe audio
  - **Meeting date**: Extract from the recording date in the filename
- **For audio files** (mp3, ogg, etc.):
  - Use `speech-to-text` skill directly to transcribe
  - **Meeting date**: Extract from the recording date in the filename
  - Analyze for attendees, summary, decisions, actions
- **For presentations** (PowerPoint):
  - Convert to PDF if needed
  - Use `pdf-extractor` skill to extract full content
- **For PDFs**:
  - Use `pdf-extractor` skill to extract text and structure
- **For images**:
  - Use `pdf-extractor` skill with OCR to extract text
- **For emails** (.eml):
  - Use `email-extractor` skill to parse thread structure
  - **Meeting date**: Extract from email's Date header
  - Extract all attachments
  - Upload attachments to appropriate folders
  - Understand email context and relationships
  - ⚠️ **CRITICAL**: Each email becomes ONE minute entry (treat like a meeting)
  - Then extract information from that email to update other sections (actions, description, risks, etc.)
- **For text input**:
  - Parse user-provided notes/minutes directly

**Step 4: Analyze and Synthesize Information**
- Read current topic Google Doc using `google-docs-manager`
- Identify from all extracted content:
  - Meeting date and title (from filename for audio/video, from Date header for emails)
  - List of attendees (from transcription or email To/Cc fields)
  - Summary of key points
  - Decisions made
  - New action items (with owners, descriptions, risks)
  - Updates to existing actions
  - New or updated risks (with mitigation strategies)
  - Application references (SNSVCxxxxxxx codes)
  - Any updates to description/presentation

**Step 5: Propose Changes to User**
- Present comprehensive summary:
  - "Found meeting from [date] with [X] attendees"
  - "Identified [N] new actions: [list titles]"
  - "Identified [N] risks: [list titles]"
  - "Updates to [N] existing actions: [list]"
  - "Proposed updates to Presentation: [summary]"
- Show proposed minute entry structure
- **Ask for confirmation** before applying changes (especially if >3 changes)

**Step 6: Update Google Doc (Structure Preservation Critical)**
⚠️ **CRITICAL**: Structure preservation is paramount - NEVER break document structure
- Use `google-docs-manager` skill to update document
- Follow these rules precisely:
  - **Minutes**: Insert at BEGINNING of Minutes section (after H1 "Minutes")
    - Most recent minute always appears first
    - Use H2 for date/title, H3 for a), b), c), d)
    - Include links to uploaded files in Minutes/Prez/Documents folders
  - **Actions**: Insert at END of Actions section (before next H1)
    - New actions added after all existing actions
    - Use H2 for action title, H3 for Description/Risks/Logs sections
    - **Action structure details**:
      - H2: Action Name
      - H3: Description (section heading)
        - Content describing the action
        - **_Owner:_**, **_Status:_**, **_ETA:_** (formatted text within Description)
      - H3: Risks (section heading, may be empty initially)
        - H4: Risk Name (if risks exist)
          - H5: Description, H5: Mitigations
      - H3: Logs (section heading, may be empty initially)
        - H4: Date entries (added as logs accumulate)
  - **Update existing action logs**: Find specific action, add H4 under Logs section
    - Add date as H4, then content
    - Reference the meeting/source
  - **Risks**: Insert at END of Risks section (before next H1)
    - Use H2 for risk title, H3 for Description/Mitigation
  - **Presentation**: Update inline within existing Presentation section
    - Add application codes if found
    - Add links to key documents from Prez/Documents folders

**Step 7: Cleanup Local Files**
⚠️ **CRITICAL**: Privacy and disk space management
- After successful Google Doc update, remove all local source files that were uploaded
- **CRITICAL**: Only delete files after verifying:
  - Upload to Google Drive was successful
  - File IDs and URLs were captured
  - Google Doc update completed successfully
- Files to clean up:
  - Audio/video files uploaded to Minutes/
  - Presentation files uploaded to Prez/
  - **Email files (.eml) uploaded to Emails/** ← PRIORITY for privacy
  - PDF/image files uploaded to Documents/ or Prez/
  - Any temporary files created during processing
- **Extracted content should be uploaded to appropriate folders**:
  - Email extractions (email.md, email_content.txt) → `{Topic_Name}/Emails/` folder
  - PDF extractions (extracted_text.md, content.txt) → `{Topic_Name}/Documents/` folder alongside the original PDF
  - Transcriptions (transcript.md, transcript.txt) → `{Topic_Name}/Minutes/` folder alongside the recording
  - Presentation extractions (slides_content.md) → `{Topic_Name}/Prez/` folder alongside the presentation
  - Image OCR extractions (ocr_text.md) → Same folder as the original image (Prez/ or Documents/)
- After uploading extracted content to Google Drive:
  - Use `rm` command to remove both source files AND extracted content from local disk
  - Only keep files locally if user explicitly requested local copies

**Step 8: Confirm Completion**
- Provide summary of all changes made
- Include links to:
  - Updated Google Doc
  - All uploaded files
  - Specific sections updated
- Confirm local files have been cleaned up

### Open Topic

**Trigger**: User asks to "open {topic_name} topic" or "open topic {topic_name}"

**Process**:
1. List existing topic in `Notes` (ID: `16VBlrwK2FAmIfzqN1g9h-sCkQ4YuHz8x`) folder using `google-drive-manager` skill
2. Find the Google Doc and its url in the topic folder
3. Run for the user: `open <url_google_doc_file>`

### Summarize/Describing Topic

**Trigger**: User asks to "summarize topic [name]" or "get info on topic [name]" or "describe me topic [name]"

**Process**:
1. Locate topic folder and Google Doc using `google-drive-manager`
2. Read full Google Doc using `google-docs-manager`
3. Provide structured summary:
   - Topic name, owner and description
   - Related applications (SNSVCxxxxxxx codes)
   - Active actions (count and brief list, with major risks)
   - Recent meetings (last 2-3 with dates)
4. **Enable drill-down**: User can ask for more details on specific sections

### Add/Update Actions

**Trigger**: User asks to "add/update action [name] in topic [topic]" or "log action update for [name]"

**Process**:
1. Read topic Google Doc
2. Understand the existing actions to ensure if it's an update or and addition. Ask if unsure if you think one action is similar.
3a. In case of creation: create the new action according to the template described. If some information are missing (ETA, Status, Risks), ask for default value.
3b. In case of update: propose the modification in all the sections according to the user information. If the new ETA, Status, or Risks are not mentioned in the description of the update, ask if there are new things in these sections after summarizing the current ETA, Status and Risks
4. Update Google Doc using `google-docs-manager`, preserving structure and style

### Validate Topic Content

**Trigger**: Automatic validation before applying updates, or user asks to "validate topic [name]"

**Process**:
1. Read topic Google Doc
2. Check for common issues:
   - **Duplicate actions**: Same or similar action names in Actions section
   - **Conflicting statuses**: Action marked both "Done" and "Blocked" in logs
   - **Missing required fields**: Actions without Owner, Status, or ETA
   - **Invalid status values**: Status not in {Not started, Framing, In progress, Done, Blocked, Canceled}
   - **Invalid ETA format**: ETA not matching {YYYY-Q1|YYYY-Q2|YYYY-Q3|YYYY-Q4, YYYY-MM}
   - **Orphaned risks**: Risks not linked to any action
   - **Broken structure**: Missing heading sections or incorrect hierarchy
3. Report findings to user
4. For critical issues (duplicates, invalid formats): Ask for resolution before proceeding
5. For warnings (missing fields): Suggest defaults or ask user to provide

**Validation Rules**:

| Rule | Requirement | Valid Values |
|------|-------------|--------------|
| **Action Names** | Must be unique within topic | No duplicates |
| **Required Fields** | Each action MUST have | Owner, Status, ETA, Description |
| **Status Values** | MUST be one of | Not started, Framing, In progress, Done, Blocked, Canceled |
| **Status Colors** | Apply text color | Not started: #000000, Framing/In progress: #bf9000, Done: #38761d, Blocked/Canceled: #990000 |
| **ETA Format** | MUST match | YYYY-Q1, YYYY-Q2, YYYY-Q3, YYYY-Q4, or YYYY-MM |
| **Risk Probability/Impact** | MUST be one of | High (#990000), Medium (#bf9000), Low (#38761d) |
| **Risk Linkage** | SHOULD reference actions | Recommended but not mandatory |

## Critical Structure Preservation Rules

When updating Google Docs, ALWAYS:

1. **Read the entire document first** to understand current structure
2. **Identify exact insertion points** using heading levels
3. **Preserve heading hierarchy**: Never mix levels or break sections
4. **Insert content at correct location**:
   - Minutes: TOP of Minutes section
   - Actions: END of Actions section
   - Risks: END of Risks section
   - Action logs: END of specific action's Logs section
5. **Maintain formatting**: Use proper heading styles as described
6. **Link Policy**:
   - DO link to uploaded files in Prez/Documents/Minutes/Emails folders within the Google Doc
   - DO reference specific actions/sections within the topic
   - DON'T link to external systems or websites in the Risks section
   - DON'T link to files outside the topic's folder structure
7. **Never remove existing content** unless explicitly requested

## Example Update Flow

**User**: "Update topic 'Data Platform Roadmap' with this meeting record"

**Assistant Process**:
1. Invoke `google-drive-manager` to find topic folder
2. If audio/video: Invoke `speech-to-text` to transcribe
3. If presentation attached: Invoke `pdf-extractor` to extract content
4. Analyze transcription for:
   - Date, attendees
   - Key points, decisions
   - Action items mentioned
   - Risks discussed
5. Upload record file to Records folder
6. Upload presentation to Prez folder
7. Read current Google Doc
8. Propose:
   - New minute entry with date, attendees, summary, decisions, full transcription
   - 2 new actions identified
   - 1 risk identified
   - Update to existing action "Q2 Delivery" with log entry
9. **Ask user**: "I've identified 2 new actions, 1 risk, and an update to 'Q2 Delivery'. Should I proceed with these updates?"
10. On confirmation: Update Google Doc with all changes, preserving structure
11. Cleanup local files: Remove uploaded audio/presentation files from local disk
12. Confirm completion with summary and confirmation of cleanup

**Example with Email**:

**User**: "Update topic 'Q2 Release Planning' using the email information from the planning meeting"

**Assistant Process**:
1. Search for .eml file in ~/Downloads (or ask user for location)
2. Invoke `email-extractor` skill to extract email content and attachments
3. Invoke `google-drive-manager` to find topic folder and locate Documents subfolder
4. Upload .eml file to `Q2 Release Planning/Emails/` folder
5. Upload attachments to appropriate subfolders:
   - Presentations → `Q2 Release Planning/Prez/`
   - Audio/video → `Q2 Release Planning/Minutes/`
   - PDFs/documents → `Q2 Release Planning/Documents/`
6. If email has PDF attachments: Invoke `pdf-extractor` to extract content
7. Read current Google Doc
8. Analyze extracted email.md for:
   - **Date**: From email Date header (e.g., "2024-03-15")
   - **Attendees**: From To/Cc fields
   - **Subject**: Use as meeting title
   - **Key decisions**: In email body
   - **Action items**: Mentioned in email
   - **Risks**: Mentioned in email
9. Propose updates:
   - **ONE new minute entry**: "2024-03-15 - Q2 Release Planning Discussion"
     - a) Attendees: [from To/Cc]
     - b) Summary: [key points from email]
     - c) Decisions/Actions: [what was decided]
     - d) Minutes: Link to .eml file in Emails/ folder
   - **New/updated Actions**: Based on action items in email
   - **New/updated Risks**: Based on risks mentioned in email
10. **Ask user**: "I've found 1 email creating 1 minute entry, 2 new actions, and 1 risk. Should I proceed?"
11. On confirmation: Update Google Doc with:
    - ONE minute at top of Minutes section
    - Actions at end of Actions section
    - Risks at end of Risks section
12. Cleanup local files: Remove .eml file and all extracted attachments from local disk
13. Confirm completion with summary, links, and confirmation of cleanup

## Integration with Other Skills

This skill orchestrates multiple specialized skills to handle different aspects of topic management:

- **google-drive-manager**: Search folders, create folders/subfolders, upload files, manage folder structure, get file links
- **google-docs-manager**: Create docs from Template v2, read docs, update docs with markdown, preserve heading structure and formatting
- **speech-to-text**: Transcribe audio/video records, identify speakers, extract attendees, generate meeting minutes with analysis
- **video-creator**: Extract audio from video files (mp4, mov, etc.) for transcription, ignore visual content
- **pdf-extractor**: Extract text from PDFs and images (OCR), convert presentations to text, maintain structure
- **email-extractor**: Parse .eml files, extract attachments, understand email threads, convert to structured markdown
- **image-manipulator**: Process images if needed for OCR or optimization

Always invoke the appropriate specialized skill for each content type.

## Template v2 Reference

When creating new topics, use "Template v2" (ID: `1lcUWzmqtj-h0OMdM_NcvDN_qa4EyAfwCgE-IZUAlLPc`) and the`google-docs-manager` skill. This template provides the base structure with all required heading sections. The template must be empty after copying.

## Error Handling

- **Topic not found**: Offer to create new topic
- **Malformed document**: Warn user and suggest restructuring
- **Missing sections**: Add missing sections in correct order
- **Duplicate content**: Ask before adding potential duplicates
- **Large updates**: Always summarize and ask for confirmation before applying

## Best Practices

1. **Always confirm major updates** (>3 changes or new minute)
2. **Provide clear summaries** of proposed changes
3. **Preserve chronological order**: Minutes newest first, logs newest last
4. **Link documents**: Reference uploaded files in doc with proper links
5. **Extract maximum value**: Transcribe fully, OCR images, parse emails completely
6. **Cross-reference**: Identify when One-to-One minutes affect other topics. If so, apply the Update topic workflow after ensuring with the user the Topic to update.
   - **Detection**: Look for mentions of topic names, SNSVCxxxxxxx codes, or action items referencing other topics
   - **Confirmation**: Ask user: "This mentions [Topic X, Topic Y]. Should I also update those topics with cross-references?"
   - **Update strategy**:
     - Add action log to referenced topic linking back to the one-to-one minute
     - Add note in one-to-one referencing the other topic's action
     - Avoid circular updates: Only update each topic once per cross-reference chain
   - **Multiple cross-references**: Process sequentially, confirming each before proceeding
7. **Application tracking**: Always identify and link SNSVCxxxxxxx references
8. **Be precise with structure**: Never approximate heading levels
9. **Always cleanup local files**: After successful upload and Google Doc update, remove all local source files to free disk space and protect sensitive data (especially .eml files)

## Notes Folder Location

Base folder: `Notes` (Google Drive ID: `16VBlrwK2FAmIfzqN1g9h-sCkQ4YuHz8x`)

All topics MUST be created and managed within this folder.
