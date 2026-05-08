---
name: my-project-launcher
description: Automates the creation of standardized project folder structures on Canva and Notion. This skill should be used when the user requests to create, launch, or initialize a new project with phrases like "crea progetto X in Canva", "avvia progetto Y su Notion", or "setup project Z". The skill creates platform-specific folder hierarchies (Canva) or page/database structures (Notion) with proper naming conventions and always requests confirmation before executing. Note - Google Drive requires Zapier integration (not yet implemented).
---

# My Project Launcher

## Overview

This skill automates the creation of standardized project structures across cloud platforms (Canva and Notion). It ensures consistent organization by creating platform-specific folder hierarchies (Canva) or page/database structures (Notion) with predefined layouts, reducing manual setup time and maintaining organizational standards.

**Supported Platforms:**
- ✅ **Canva** - Creates folder hierarchies with subfolders
- ✅ **Notion** - Creates pages with databases for structured content
- ⚠️ **Google Drive** - Requires Zapier integration (see Advanced section)

## When to Use This Skill

Trigger this skill when the user requests project creation with phrases such as:
- "Crea progetto [nome] in Canva"
- "Avvia progetto [nome] su Notion"
- "Setup project [nome]"
- "Inizializza progetto [nome] su [piattaforma]"

**Note:** For Google Drive projects, inform the user that Drive integration requires Zapier setup (see Advanced Integration section).

## Project Structure Specifications

### Canva Structure
```
<project_name>/
├── slides/      # Presentation files
└── img/         # Images and visual assets
```

### Notion Structure
```
📄 <project_name> (Main Page)
├── 🗄️ Database "Slides"
│   └── Properties: Nome (title), Stato (select), Data (date)
├── 🗄️ Database "Images"
│   └── Properties: Nome (title), File (files), Usata in (text), Data Upload (date)
└── 📄 Page "Materiali"
    └── Content area for prompts and notes
```

### Google Drive Structure (Requires Zapier - see Advanced section)
```
<project_name>/
├── slides/      # Presentations (PPTX, Canva exports, PDF)
├── img/         # Images and visual assets
└── materiali/   # Webinar materials
    └── prompts.txt (empty file)
```

**Note:** Canva and Notion structures are fully automated. Google Drive requires additional Zapier integration.

## Workflow

### Step 1: Parse User Request

Identify the following from the user's request:
1. **Project name** - The name to use for the folder/page structure
2. **Target platform** - Which platform(s) to create on (Canva, Notion, or both)
3. **Location specification** (Canva only) - Whether the user specified a parent folder

**Examples:**
- "Crea progetto MyAwesomePrjHER in Canva" → name: "MyAwesomePrjHER", platform: "Canva", location: root
- "Avvia progetto MyAwesomeWebinar su Notion" → name: "MyAwesomeWebinar", platform: "Notion"
- "Setup project WebinarAI in Canva nella cartella Talks" → name: "WebinarAI", platform: "Canva", location: "Talks"

**If user requests Google Drive:**
- Inform user that Drive integration requires Zapier setup
- Offer to create on Canva or Notion instead
- Or refer to Advanced Integration section for Zapier setup instructions

### Step 2: Validate Project Name

Before proceeding, check if a project with the same name already exists on the target platform:

**For Canva:**
Use the `Canva:list-folder-items` tool to check if a folder with the project name exists at root level or specified location.

**For Notion:**
Use the `Notion:notion-search` tool with query_type "internal" to search for pages with the project name.

**If project exists:**
- Inform the user that a project with that name already exists
- Show the existing project location/URL
- Ask if they want to:
  - Use a different name
  - Proceed anyway (may create duplicate)
  - Cancel the operation
- STOP and wait for user response before proceeding

**If any anomaly or inconsistency is detected:**
- Describe the issue clearly
- Ask for clarification
- STOP and wait for user response

### Step 3: Request Confirmation

Before creating any folders, present a confirmation message to the user with the following information:

**Confirmation format:**
```
Vuoi creare il progetto '[project_name]' su [platform]?

Struttura che verrà creata:
[show the folder tree for the specific platform]

Posizione: [root/specified folder]

Confermi?
```

**Wait for explicit user confirmation** before proceeding. Accept responses like:
- "Sì", "Yes", "Ok", "Confermo", "Procedi", "Vai"

**If user declines or provides unclear response:**
- Ask if they want to modify anything
- STOP until receiving clear direction

### Step 4: Create Project Structure

Once confirmation is received, create the folder structure using the appropriate MCP tools.

#### For Canva:

1. **Create main project folder at root or specified location:**
   - Use `Canva:create-folder` tool
   - Set parent_folder_id to 'root' or specified folder ID
   - Name: project_name

2. **Create subfolders:**
   - Use `Canva:create-folder` tool for `slides/` with main project folder ID as parent
   - Use `Canva:create-folder` tool for `img/` with main project folder ID as parent

#### For Notion:

1. **Create main project page:**
   - Use `Notion:notion-create-pages` tool
   - Create a page with the project name as title
   - Add introductory content describing the project structure
   - No parent specified (creates at workspace root)

2. **Create "Slides" database:**
   - Use `Notion:notion-create-database` tool
   - Set parent to the main project page ID
   - Properties:
     - "Nome" (type: title) - Name of the slide/presentation
     - "Stato" (type: select) - Status with options: "Draft" (gray), "In Progress" (yellow), "Done" (green)
     - "Data" (type: date) - Date associated with the slide

3. **Create "Images" database:**
   - Use `Notion:notion-create-database` tool
   - Set parent to the main project page ID
   - Properties:
     - "Nome" (type: title) - Name/description of the image
     - "File" (type: files) - For attaching image files
     - "Usata in" (type: rich_text) - Notes about where the image is used
     - "Data Upload" (type: date) - Upload date

4. **Create "Materiali" page:**
   - Use `Notion:notion-create-pages` tool
   - Set parent to the main project page ID
   - Add content with heading "# Materiali" and section for prompts
   - Include placeholder text for prompts and notes

### Step 5: Confirm Completion

After successfully creating all folders/pages, provide a confirmation message with:
1. **Success statement** - "Progetto '[project_name]' creato con successo su [platform]!"
2. **Structure created** - Show the folder tree or page hierarchy that was created
3. **Access links** - Provide direct links to the main project folder/page on the platform
4. **Next steps suggestion** - Brief reminder of what the user can do next

**Example completion message for Canva:**
```
✅ Progetto 'MyAwesomePrj' creato con successo su Canva!

Struttura creata:
MyAwesomePrj/
├── slides/
└── img/

Link: [Canva folder URL]

Ora puoi importare immagini o iniziare a lavorare sulle slide.
```

**Example completion message for Notion:**
```
✅ Progetto 'WebinarAI' creato con successo su Notion!

Struttura creata:
📄 WebinarAI
├── 🗄️ Database "Slides"
├── 🗄️ Database "Images"
└── 📄 Pagina "Materiali"

Link: [Notion page URL]

Ora puoi aggiungere slide al database, caricare immagini e inserire i tuoi prompts nella pagina Materiali.
```

## Error Handling

Handle common errors gracefully:

**Project already exists:**
- Inform user of existing project
- Offer alternatives (rename, proceed anyway, cancel)
- Do not proceed without explicit confirmation

**Parent folder not found (Canva only):**
- Inform user that specified parent folder doesn't exist
- Ask whether to create at root or specify different folder
- Wait for user decision

**Permission errors:**
- Inform user of permission issue
- Suggest checking account access or platform connection
- Provide guidance on reconnecting MCP if needed

**Platform connectivity issues:**
- Inform user of connection problem
- Suggest checking MCP connection status in Claude settings
- Offer to retry after user confirms connection is restored

**Database creation errors (Notion only):**
- If database properties fail to create correctly, inform user
- Offer to retry with simplified structure
- Provide manual creation guidance if automated approach fails

**Any unexpected errors:**
- Describe the error clearly without technical jargon
- Ask user if they want to retry or take different action
- Never proceed silently when errors occur

## Important Principles

1. **Always request confirmation** before creating any folders
2. **Always validate** that project doesn't already exist
3. **Always provide clear feedback** at each step
4. **Always stop and ask** when encountering errors or ambiguity
5. **Better to ask one extra question** than to proceed incorrectly
6. **Never guess or assume** - when in doubt, ask the user
7. **Provide actionable next steps** after completion

## Examples

### Example 1: Simple Canva Project
**User:** "Crea progetto AIWorkshop in Canva"

**Claude:**
1. Checks if "AIWorkshop" exists in Canva root (not found)
2. Asks confirmation: "Vuoi creare il progetto 'AIWorkshop' su Canva?..."
3. User confirms
4. Creates folder structure on Canva
5. Provides completion message with link

### Example 2: Notion Project
**User:** "Avvia progetto MyAwesomePrjHER su Notion"

**Claude:**
1. Searches for "MyAwesomePrj" page on Notion (not found)
2. Asks confirmation showing the page/database structure
3. User confirms
4. Creates main page with Slides database, Images database, and Materiali page
5. Provides completion message with link

### Example 3: Project Already Exists
**User:** "Setup project TestSkillCanva in Canva"

**Claude:**
1. Checks if "TestSkillCanva" exists in Canva (found existing)
2. Informs user: "Esiste già un progetto chiamato 'TestSkillCanva' in Canva..."
3. Asks: "Vuoi usare un nome diverso o procedere comunque?"
4. Waits for user response before proceeding

### Example 4: User Requests Google Drive
**User:** "Crea progetto WebinarAI in Drive"

**Claude:**
1. Recognizes Drive is not currently supported
2. Informs user: "Google Drive richiede l'integrazione con Zapier che non è ancora configurata. Posso creare il progetto su Canva o Notion invece?"
3. Offers alternatives or refers to Advanced Integration section
4. Waits for user decision

### Example 5: User Changes Mind
**User:** "Crea progetto TestProject in Canva"

**Claude:** "Vuoi creare il progetto 'TestProject' su Canva?..."

**User:** "Aspetta, meglio chiamarlo TestProject2025"

**Claude:**
1. Acknowledges change
2. Validates new name "TestProject2025"
3. Asks new confirmation with updated name
4. Waits for confirmation before proceeding

## Advanced Integration

### Google Drive via Zapier (Future Implementation)

To enable Google Drive project creation, a Zapier integration is required:

**Setup Overview:**
1. Create a Zap with Webhook trigger that receives project parameters
2. Configure Google Drive actions to create folder structure
3. Add the Zap as an MCP tool using `Zapier:add_tools`
4. Update this skill to call the Zapier tool for Drive projects

**Required Zap Actions:**
- Create main project folder
- Create `slides/`, `img/`, and `materiali/` subfolders
- Create empty `prompts.txt` file in `materiali/`
- Return folder URL and confirmation

**Benefits:**
- Full automation of Drive project creation
- Consistent structure across all platforms
- Easy to modify folder structure via Zapier interface

**Status:** Not yet implemented. Currently, projects can be created on Canva and Notion only.
