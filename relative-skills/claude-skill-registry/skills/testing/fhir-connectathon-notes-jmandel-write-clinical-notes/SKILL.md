---
name: fhir-connectathon-notes
description: Testing toolkit for the FHIR Writing Clinical Notes specification at connectathons. Use when the user needs to test FHIR DocumentReference write operations, validate conformance with the Writing Clinical Notes spec, or participate in a FHIR connectathon for clinical notes. Includes templates, OAuth helpers, and automated test scenarios for both provider-authored and patient-asserted notes.
---

# FHIR Connectathon Notes Testing Skill

Comprehensive toolkit for testing the FHIR Writing Clinical Notes specification at connectathons and in development environments.

## Quick Start

1. **Set up project structure** - Copy template files to project root
2. **Run the bun setup script** - Launch the interactive setup wizard
3. **⚠️ CRITICAL: Use `localize-document.ts` to generate test documents** - Do NOT write custom scripts
4. Execute test scenarios using the `request.ts` pattern
5. Validate responses against spec requirements

### Key Principles for Agents

**DO:**
- ✅ Use `localize-document.ts` CLI tool OR import `localizeDocumentReference()` function
- ✅ Use the `request.ts` pattern with `fhir-request.ts` library for all API calls
- ✅ Run scripts from project root: `bun path/to/script.ts`
- ✅ Import library functions when writing code that needs localization
- ✅ **Keep ALL work for each server in `debug/<server-name>/`** - summaries, notes, observations, temporary files
- ✅ Write `SUMMARY.md` and `observations.md` files in each server's debug directory

**DON'T:**
- ❌ Write custom localization scripts
- ❌ Try to parse template JSON files directly
- ❌ Use `fetch()` directly - always use the `fhir-request.ts` library
- ❌ Shell out to CLI tools when you can import library functions
- ❌ **Mix files from different servers** - each server gets its own `debug/<server-name>/` directory
- ❌ Create investigation notes outside the server's debug directory

## IMPORTANT: First Steps for the Agent

Before proceeding with any testing tasks, the agent MUST:

### 1. Set Up Project Structure

**Check if project structure already exists:**

```bash
# Check for existing setup
if [ -f ".gitignore" ] && [ -d ".fhir-configs" ]; then
  echo "✓ Project structure already exists"
else
  echo "Setting up project structure..."

  # Copy .gitignore to exclude sensitive configs and debug logs
  cp .claude/skills/write-clinical-notes/assets/project/.gitignore .

  # Create directory structure
  mkdir -p .fhir-configs debug localized

  # Copy fhir-request library to debug/
  cp .claude/skills/write-clinical-notes/assets/lib/fhir-request.ts debug/

  echo "✓ Project structure created"
fi
```

This creates:
- `.gitignore` - Excludes `.fhir-configs/`, `debug/`, and `localized/`
- `.fhir-configs/` - Will store server connection configs
- `debug/` - Will store request/response logs organized by server and timestamp
- `localized/` - Will store template-generated resources organized by server
- `FHIR-TESTING.md` - Documentation about the testing structure

**Note:** If files already exist (from previous testing), they will NOT be overwritten.

### 2. Understanding the Specification and Scenarios

The agent has access to the complete specification and test scenarios embedded below.

#### Writing Clinical Notes Specification

@references/spec.md --- read this in full

#### Connectathon Test Scenarios

@references/scenarios.md -- read this in full

### 3. Server-Specific Debug Directories

**CRITICAL: Keep ALL server-related work in server-specific debug directories**

When testing a server, create a dedicated directory under `debug/` for that server and keep EVERYTHING related to that server in its directory:

**What goes in the server's debug directory:**
- ✅ FHIR API request/response logs (timestamped subdirectories)
- ✅ Investigation notes and summaries
- ✅ Test results and validation findings
- ✅ Temporary analysis files
- ✅ Server-specific observations
- ✅ Error analysis and troubleshooting notes
- ✅ The shared `fhir-request.ts` library

**Why this matters:**
- Enables parallel testing of multiple servers without confusion
- Clear separation of findings per server
- Easy to review all work for a specific server
- No mixing of results from different servers
- Complete audit trail per server

**Setup (one time per server):**

```bash
# Example: Setting up for "epic" server
mkdir -p debug/epic
cp .claude/skills/write-clinical-notes/assets/lib/fhir-request.ts debug/epic/
```

**Example directory structure:**
```
debug/
├── epic/                                      # Epic server investigation
│   ├── fhir-request.ts                       # Shared library
│   ├── SUMMARY.md                            # Overall findings for Epic
│   ├── observations.md                       # Notes during testing
│   ├── 2025-11-06T10-15-00-scenario1-create/ # Test runs
│   │   ├── request.ts
│   │   ├── request-body.json
│   │   ├── response-metadata.json
│   │   └── response-body.json
│   └── 2025-11-06T10-20-00-scenario2-conditional/
│       ├── request.ts
│       ├── request-body.json
│       ├── response-metadata.json
│       └── response-body.json
└── smart-demo/                                # SMART server investigation
    ├── fhir-request.ts
    ├── SUMMARY.md
    ├── observations.md
    └── [timestamped test runs...]
```

**Writing summaries and notes:**

```bash
# Write investigation notes in the server's directory
cat > debug/epic/observations.md << 'EOF'
# Epic Server Testing Observations

## Authentication
- Using Epic-Client-ID header required
- OAuth flow successful with PKCE

## DocumentReference Support
- Accepts text/plain: ✅
- Accepts application/pdf: ✅
- Conditional create: Testing...
EOF

# Write final summary when testing complete
cat > debug/epic/SUMMARY.md << 'EOF'
# Epic Server Test Results

## Overview
Tested: 2025-11-06
Server: https://connectathon.epic.com/...

## Results
[Summary of all tests...]
EOF
```

**For each FHIR request:**

1. **Create debug directory** with timestamp and purpose:
   ```bash
   TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%S")
   DEBUG_DIR="debug/smart-demo-open/${TIMESTAMP}-scenario1-create"
   mkdir -p "$DEBUG_DIR"
   ```

2. **Write `request.ts`** in that directory:
   ```typescript
   import { execute } from '../fhir-request.ts';

   await execute({
     method: "POST",
     path: "/DocumentReference",
     bodyFile: "localized/smart-demo-open/consultation-note.json",
     headers: {
       // Optional: additional headers like "If-None-Exist": "identifier=system|value"
     },
     purpose: "Scenario 1: Basic document creation",
     configName: "smart-demo-open",  // REQUIRED if multiple configs exist
     callerDir: import.meta.dir  // CRITICAL: Tells library where to write output files
   });
   ```

   **Config Selection Behavior:**
   - If you have **only one** FHIR config: `configName` is optional (auto-selected)
   - If you have **multiple** FHIR configs: `configName` is **required** (explicit selection)
   - The config name matches the filename without `.json` (e.g., `smart-demo-open.json` → `"smart-demo-open"`)

3. **Run from PROJECT ROOT** (not from the debug directory):
   ```bash
   bun run debug/smart-demo-open/2025-11-03T18-17-25-scenario1-create/request.ts
   ```

   **Why from project root?**
   - The library needs to find `.fhir-configs/` (at project root)
   - The `bodyFile` path is relative to project root
   - The `import.meta.dir` in request.ts gives the library the debug directory to write to

4. **Output files are automatically created as siblings to request.ts:**
   - `response-metadata.json` - HTTP status, headers, timing
   - `response-body.json` (or `.txt`) - Response body

**CRITICAL PATH RULES:**

✅ **DO THIS:**
```bash
# Always run from project root
cd /path/to/project
bun run debug/server-name/timestamp-purpose/request.ts
```

❌ **DON'T DO THIS:**
```bash
# Don't cd into debug directory
cd debug/server-name/timestamp-purpose
bun request.ts  # Will fail to find .fhir-configs
```

**Key Points:**
- `fhir-request.ts` lives at `debug/{server-name}/fhir-request.ts` (one per server)
- `request.ts` files live at `debug/{server-name}/{timestamp}-{purpose}/request.ts`
- Always use `callerDir: import.meta.dir` in your execute() call
- Always run from project root: `bun run debug/path/to/request.ts`
- The library uses `callerDir` to write response files as siblings to `request.ts`

**Benefits:**
- Clean, readable request specification
- No path confusion - always run from project root
- Automatic config loading and auth handling
- Consistent logging every time
- Easy to replay/modify (just edit and re-run)
- Request is self-documenting

### 4. Note Configuration Storage Location

Server configurations are stored in `.fhir-configs/` in the project root (NOT in the skill directory). This makes them accessible across different skill invocations and preserves them between sessions.

---

## Setup: Authentication & Configuration

### Step 1: Launch the Interactive Setup (Bun Script)

The easiest way to get started is to use the bun setup script:

1. **IMPORTANT**: Run setup in the **foreground** (NOT as a background process) so you can immediately see when it completes:
   ```bash
   bun .claude/skills/write-clinical-notes/assets/config/setup.ts
   ```
2. The script will print a clickable link to http://localhost:3456
3. Open the link in your browser
4. Choose to create a new configuration or select an existing one
5. Follow the interactive wizard to configure your FHIR server connection
6. Watch for the output line: `📋 SELECTED_CONFIG: {name}`
7. Configuration will be automatically saved and the server will shut down

The setup script will:
- Start a local web server (prints link to CLI)
- Display existing configurations you can switch between
- Guide you through creating new FHIR server configurations
- Handle OAuth flows or manual token entry
- Save named configurations to `.fhir-configs/` directory in the project root
- Output the selected config name to stdout with `📋 SELECTED_CONFIG: {name}`
- Automatically exit when setup is complete

### Step 2: Configure Server Connection

The setup wizard supports four authentication modes:

**Mode 1: Manual Token** (fastest for testing)
- Paste an existing access token
- Enter FHIR base URL
- Optionally provide patient ID and encounter reference
- Click "Use This Configuration"

**Mode 2: Open Server** (no authentication)
- Enter FHIR base URL
- Optionally provide patient ID and encounter reference
- Click "Use Open Server"
- Useful for public test servers

**Mode 3: OAuth Public Client**
- Enter FHIR base URL
- Click "Auto-Discover Endpoints" (or manually enter auth/token endpoints)
- Enter client ID
- Click "Start OAuth Flow"
- Complete authentication in browser
- Authorization code is automatically captured and exchanged for token

**Mode 4: OAuth Confidential Client**
- Same as public client, but also requires client secret
- Token exchange happens server-side with credentials

### Step 3: Reading the Selected Configuration

After successful setup, the script outputs:
```
📋 SELECTED_CONFIG: {config-name}
```

The agent should:
1. Capture this config name from the setup script output
2. Read the configuration from `.fhir-configs/{config-name}.json`

Example configuration file structure:
```json
{
  "name": "SMART Open",
  "fhirBaseUrl": "https://fhir.example.org/r4",
  "accessToken": "eyJ...",
  "patientId": "patient-123",
  "encounterRef": "Encounter/enc-456",
  "mode": "public",
  "savedAt": "2025-11-03T10:00:00.000Z"
}
```

### Alternative: Manual Setup (Advanced)

If you prefer not to use the bun script, you can manually create a file in `.fhir-configs/` with the structure above.

## Using Saved Configuration

Once setup is complete, the agent should:

1. **Extract the config name from setup output and read the configuration file:**
   ```bash
   # Extract config name from setup script output
   CONFIG_NAME=$(grep "📋 SELECTED_CONFIG:" setup_output.txt | cut -d: -f2 | tr -d ' ')

   # Read the selected configuration
   cat ".fhir-configs/${CONFIG_NAME}.json"
   ```

2. **Make FHIR requests using the request.ts pattern:**

   For every FHIR API call, use the request.ts template approach (see Debug Logging section above).

   **Example workflow:**

   ```bash
   # 1. Determine server name from config
   SERVER_NAME=$(jq -r '.name' ".fhir-configs/SMART Demo Open.json" | tr '[:upper:] ' '[:lower:]-')
   # Result: "smart-demo-open"

   # 2. Create debug directory with timestamp
   TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%S")
   DEBUG_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario1-create"
   mkdir -p "$DEBUG_DIR"

   # 3. Write request.ts using the fhir-request library
   cat > "$DEBUG_DIR/request.ts" <<'EOF'
import { execute } from '../fhir-request.ts';

await execute({
  method: "POST",
  path: "/DocumentReference",
  bodyFile: "localized/smart-demo-open/consultation-note.json",
  purpose: "Scenario 1: Basic document creation",
  configName: "smart-demo-open",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir  // CRITICAL: pass the directory to write responses
});
EOF

   # 4. Run the request FROM PROJECT ROOT
   bun run "$DEBUG_DIR/request.ts"
   ```

   The script automatically:
   - Loads your FHIR config from `.fhir-configs/`
   - Makes the fetch request with proper auth
   - Writes `response-metadata.json` and `response-body.json` as siblings to `request.ts`
   - Prints summary with status, resource ID, location header

## Template Localization

**⚠️ CRITICAL: DO NOT write custom localization scripts! Use the provided `localize-document.ts` utility.**

Templates are located in `assets/templates/` with placeholder variables like `{{PATIENT_ID}}`, `{{BASE64_CONTENT}}`, etc. These templates are **NOT valid JSON** until placeholders are replaced.

### How to Localize Documents (REQUIRED APPROACH)

**ALWAYS use the provided localization utility:**

```bash
bun .claude/skills/write-clinical-notes/assets/lib/localize-document.ts \
  --type=<TYPE> \
  --patient-id=<PATIENT_ID> \
  --server=<SERVER_NAME> \
  [--patient-name="Patient Name"] \
  [--author-reference="Practitioner/id"] \
  [--author-display="Dr. Name"]
```

### Available Document Types

**Required by Spec:**
- `consultation` - Consultation note (text/plain; charset=utf-8)
- `progress` - Progress note (text/plain; charset=utf-8)
- `pdf` - Consultation note (application/pdf)

**Additional Formats:**
- `cda` - Discharge summary (application/cda+xml) - Proper C-CDA
- `xhtml` - Discharge summary (application/xhtml+xml) - XHTML rich text
- `html` - Progress note (text/html; charset=utf-8)
- `patient-asserted` - Patient-authored log with PATAST security tag
- `large` - Large file test (~5 MiB)

### Complete Examples

```bash
# Example 1: No encounter reference (encounter is optional!)
bun .claude/skills/write-clinical-notes/assets/lib/localize-document.ts \
  --type=pdf \
  --patient-id=eWhK7w46yHKVkBetDW2-Brg3 \
  --server=epic

# Example 2: With resolvable encounter reference
bun .claude/skills/write-clinical-notes/assets/lib/localize-document.ts \
  --type=pdf \
  --patient-id=eWhK7w46yHKVkBetDW2-Brg3 \
  --server=epic \
  --encounter-reference="Encounter/eR24JiO5hqr0yswk.k5BXlQ3" \
  --encounter-display="Office Visit - Jan 15"

# Example 3: With contained encounter (must provide both reference and contained JSON)
bun .claude/skills/write-clinical-notes/assets/lib/localize-document.ts \
  --type=pdf \
  --patient-id=eWhK7w46yHKVkBetDW2-Brg3 \
  --server=epic \
  --encounter-reference="#e1" \
  --encounter-contained='{"resourceType":"Encounter","id":"e1","status":"finished","class":{"system":"http://terminology.hl7.org/CodeSystem/v3-ActCode","code":"AMB"},"subject":{"reference":"Patient/eWhK7w46yHKVkBetDW2-Brg3"},"period":{"start":"2025-01-15T10:00:00Z","end":"2025-01-15T11:00:00Z"}}'

# Output in all cases: localized/epic/pdf-note.json (ready to POST)
```

### What the Script Does (Automatically)

1. **Selects the correct template** based on document type
2. **Generates or reads content** (e.g., generates PDF, reads text file)
3. **Replaces content placeholders** ({{PATIENT_NAME}}, {{CURRENT_DATE}}, etc.)
4. **Base64 encodes** the content
5. **Replaces all template placeholders** with your provided values
6. **Calculates content size** for the attachment
7. **Adds contained encounter** if using `#e1` reference
8. **Validates the final JSON** before saving
9. **Saves to** `localized/<server>/<type>-note.json`

### Command-Line Options

**Required:**
- `-t, --type <type>` - Document type (see list above)
- `-p, --patient-id <id>` - Patient resource ID
- `-s, --server <name>` - Server name for organizing output

**Optional:**
- `--patient-name <name>` - Default: "Test Patient"
- `--author-reference <ref>` - Default: "Practitioner/example"
- `--author-display <name>` - Default: "Dr. Example Provider"
- `--encounter-reference <ref>` - Encounter reference (optional - omit to exclude encounter entirely)
- `--encounter-display <text>` - Encounter display text (only used with --encounter-reference)
- `--encounter-contained <json>` - JSON string of contained Encounter resource (use with --encounter-reference="#id")
- `--identifier-system <system>` - Default: "https://example.com/fhir-test"
- `-o, --output-dir <dir>` - Default: `localized/<server>`

### Using as a Library (for agents writing code)

The localization functionality is also available as an importable library:

```typescript
import { localizeDocumentReference } from '.claude/skills/write-clinical-notes/assets/lib/localize-document.ts';
import { execute } from './fhir-request.ts';

// Generate and POST in memory
const docRef = await localizeDocumentReference({
  type: 'consultation',
  patientId: 'patient-123',
  server: 'smart',
  writeToFile: false
});

await execute({
  method: 'POST',
  path: '/DocumentReference',
  body: docRef,
  purpose: 'Create consultation note',
  callerDir: import.meta.dir
});

// With resolvable encounter
const docRef2 = await localizeDocumentReference({
  type: 'pdf',
  patientId: 'patient-123',
  server: 'epic',
  encounterReference: 'Encounter/visit-789',
  encounterDisplay: 'Office Visit',
  writeToFile: false
});

// With contained encounter
const docRef3 = await localizeDocumentReference({
  type: 'html',
  patientId: 'patient-123',
  server: 'smart',
  encounterReference: '#e1',
  encounterContained: {
    resourceType: 'Encounter',
    id: 'e1',
    status: 'finished',
    class: { system: 'http://terminology.hl7.org/CodeSystem/v3-ActCode', code: 'AMB' },
    subject: { reference: 'Patient/patient-123' },
    period: { start: '2025-01-15T10:00:00Z', end: '2025-01-15T11:00:00Z' }
  },
  writeToFile: false
});
```

**Key Points:**
- Returns DocumentReference object directly
- Set `writeToFile: false` for in-memory use (no file created)
- Pass `encounterContained` as object when using library (CLI requires JSON string)
- Use `body` parameter in `execute()` for in-memory DocumentReference objects

### Why You Must Use This Tool

❌ **DON'T:**
- Try to parse template JSON files directly (they contain unquoted placeholders)
- Write custom localization scripts
- Manually replace placeholders with string operations
- Try to read templates as JSON before placeholders are replaced

✅ **DO:**
- Use `localize-document.ts` command-line tool for simple cases
- Import and call `localizeDocumentReference()` when writing code
- Let the script handle content generation, encoding, and validation

### Understanding Template Placeholders

Templates contain placeholders that the script replaces:

**Patient/Subject:**
- `{{PATIENT_ID}}` - Patient resource ID
- `{{PATIENT_NAME}}` - Patient display name
- `{{PATIENT_GIVEN_NAME}}` - Given name (for CDA)
- `{{PATIENT_FAMILY_NAME}}` - Family name (for CDA)

**Author:**
- `{{AUTHOR_REFERENCE}}` - Practitioner reference
- `{{AUTHOR_DISPLAY}}` - Author display name
- `{{AUTHOR_NAME}}` - Full name in content
- `{{AUTHOR_GIVEN_NAME}}` - Given name (for CDA)
- `{{AUTHOR_FAMILY_NAME}}` - Family name (for CDA)
- `{{AUTHOR_TITLE}}` - Professional title (MD, etc.)

**Encounter:**
- `{{ENCOUNTER_REFERENCE}}` - Encounter reference (or `#e1`)
- `{{ENCOUNTER_DISPLAY}}` - Encounter display text
- `{{PERIOD_START}}` - Clinical period start
- `{{PERIOD_END}}` - Clinical period end

**Content:**
- `{{BASE64_CONTENT}}` - Base64-encoded note content
- `{{CONTENT_SIZE}}` - Size in bytes (as number, not string)
- `{{CONTENT_TYPE}}` - MIME type

**Metadata:**
- `{{IDENTIFIER_SYSTEM}}` - System for note identifier
- `{{IDENTIFIER_VALUE}}` - Unique identifier value
- `{{CURRENT_TIMESTAMP}}` - ISO 8601 timestamp
- `{{CURRENT_DATE}}` - Date (YYYY-MM-DD)
- `{{CURRENT_TIME}}` - Time (HH:MM)

### Manual Localization (NOT RECOMMENDED)

If you absolutely must localize manually:

1. **Determine server directory name** from config (e.g., "smart-launcher", "epic-sandbox")
2. **Create server-specific directory:**
   ```bash
   mkdir -p "localized/${SERVER_NAME}"
   ```
3. **Read template file** from `assets/templates/`
4. **Read sample content** from `assets/sample-content/` (if using text)
5. **Base64 encode content:**
   ```bash
   cat assets/sample-content/consultation-note.txt | base64 -w 0
   ```
6. **Check for missing context and ask user for guidance when needed:**

   **IMPORTANT:** If required context is missing or ambiguous, ASK THE USER how to proceed:

   - **No encounter ID in config?** Ask: "I don't see an encounter ID. Should I:
     - Omit encounter references entirely?
     - Create a contained encounter resource?
     - Use a placeholder encounter ID?"

   - **No author/practitioner reference?** Ask: "What should I use for the author reference?
     - A test practitioner ID you provide?
     - A placeholder reference?
     - Skip the author field (if testing allows)?"

   - **Patient name not specified?** Ask: "Should I fetch the patient name from the server, use a placeholder, or omit it?"

   - **Missing identifier system?** Ask: "What identifier system should I use for note identifiers? (e.g., your app's URL)"

   **Don't guess or make assumptions about clinical data.** User input ensures tests are meaningful and aligned with their testing goals.

7. **Replace all placeholders** with values from the configuration and user-provided context
8. **Save to server-specific directory:**
   ```bash
   # Save localized file
   echo "$localized_json" > "localized/${SERVER_NAME}/consultation-note.json"
   ```
9. **Validate JSON** before submission

This keeps each server's localized resources separate and organized.

### Sample Content Files

The skill includes generator scripts for different content types. Run these from the skill's `assets/sample-content/` directory:

**Text Files (pre-created):**
- `consultation-note.txt` - Plain text consultation note
- `progress-note.txt` - Plain text progress note
- `patient-log.txt` - Patient-authored health log

**Generated Content (run these scripts as needed):**
- `bun generate-pdf.ts` - Creates `consultation-note.pdf` (minimal valid PDF)
- `bun generate-cda-xml.ts` - Creates `discharge-summary.cda.xml` (proper HL7 C-CDA with structured body)
- `bun generate-xhtml.ts` - Creates `discharge-summary.xhtml` (XHTML rich text, NOT CDA)
- `bun generate-html.ts` - Creates `progress-note.html` (HTML with rich formatting)
- `bun generate-large-file.ts` - Creates `large-note.txt` (~5 MiB text file)

**Why generate programmatically?**
- Keeps repository size small
- Ensures fresh, customizable test content
- Easy to modify for specific testing needs
- Avoids committing large binary files

**Example usage:**
```bash
cd .claude/skills/write-clinical-notes/assets/sample-content
bun generate-pdf.ts
# Creates consultation-note.pdf in current directory
```

## Test Scenario Execution

Execute scenarios in order. Each builds on previous validations. The complete scenario details are embedded above in the "Connectathon Test Scenarios" section.

### Scenario 1: Basic Document Creation

**Objective:** Verify basic create and retrieval

```bash
# 1. Localize template for this server using the localization utility
SERVER_NAME="smart-launcher"  # from config
PATIENT_ID="patient-123"  # from config

bun .claude/skills/write-clinical-notes/assets/lib/localize-document.ts \
  --type=consultation \
  --patient-id="${PATIENT_ID}" \
  --server="${SERVER_NAME}"

# Output: localized/smart-launcher/consultation-note.json

# 2. POST to server using request.ts pattern
TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%S")
DEBUG_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario1-create"
mkdir -p "$DEBUG_DIR"
cp "debug/${SERVER_NAME}/fhir-request.ts" "$DEBUG_DIR/../" 2>/dev/null || cp .claude/skills/write-clinical-notes/assets/lib/fhir-request.ts "debug/${SERVER_NAME}/"

# Create request.ts for POST
cat > "$DEBUG_DIR/request.ts" << 'EOF'
import { execute } from '../fhir-request.ts';

await execute({
  method: "POST",
  path: "/DocumentReference",
  bodyFile: "localized/smart-launcher/consultation-note.json",
  purpose: "Scenario 1: Basic document creation",
  configName: "smart-launcher",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir
});
EOF

# Run the request (from project root)
bun run "$DEBUG_DIR/request.ts"

# 3. Response is automatically captured in:
# - response-metadata.json (status, headers, timing)
# - response-body.json (returned DocumentReference)
# Expect 201 Created or 202 Accepted

# 4. GET to verify (extract ID from response-body.json first)
DOC_ID=$(jq -r '.id' "$DEBUG_DIR/response-body.json")
GET_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario1-read"
mkdir -p "$GET_DIR"

cat > "$GET_DIR/request.ts" << EOF
import { execute } from '../fhir-request.ts';

await execute({
  method: "GET",
  path: "/DocumentReference/${DOC_ID}",
  purpose: "Scenario 1: Verify created document",
  configName: "${SERVER_NAME}",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir
});
EOF

bun run "$GET_DIR/request.ts"

# 5. Validate response (check response-body.json)
# - All Must Support elements present
# - Content matches original
# - Base64 decodes correctly
```

**Success criteria:**
- ✓ Server accepts note (201/202)
- ✓ All elements round-trip
- ✓ Content retrievable and accurate

### Scenario 2: Conditional Create (Idempotency)

**Objective:** Test duplicate prevention

```bash
# 1. Use same localized note from Scenario 1
# 2. POST with If-None-Exist header using request.ts
TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%S")
DEBUG_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario2-conditional"
mkdir -p "$DEBUG_DIR"

# Extract identifier from the localized note
IDENTIFIER_SYSTEM=$(jq -r '.identifier[0].system' "localized/${SERVER_NAME}/consultation-note.json")
IDENTIFIER_VALUE=$(jq -r '.identifier[0].value' "localized/${SERVER_NAME}/consultation-note.json")

cat > "$DEBUG_DIR/request.ts" << EOF
import { execute } from '../fhir-request.ts';

await execute({
  method: "POST",
  path: "/DocumentReference",
  bodyFile: "localized/${SERVER_NAME}/consultation-note.json",
  headers: {
    "If-None-Exist": "identifier=${IDENTIFIER_SYSTEM}|${IDENTIFIER_VALUE}"
  },
  purpose: "Scenario 2: Conditional create (idempotency test)",
  configName: "${SERVER_NAME}",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir
});
EOF

bun run "$DEBUG_DIR/request.ts"

# 3. Check response-metadata.json - Expect 200 OK or 304 Not Modified (not 201)

# 4. Search to confirm only one resource exists
SEARCH_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario2-search"
mkdir -p "$SEARCH_DIR"

cat > "$SEARCH_DIR/request.ts" << EOF
import { execute } from '../fhir-request.ts';

await execute({
  method: "GET",
  path: "/DocumentReference?identifier=${IDENTIFIER_SYSTEM}|${IDENTIFIER_VALUE}",
  purpose: "Scenario 2: Verify no duplicate created",
  configName: "${SERVER_NAME}",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir
});
EOF

bun run "$SEARCH_DIR/request.ts"
# Check response-body.json - should show Bundle with single entry
```

**Success criteria:**
- ✓ No duplicate created
- ✓ Existing resource returned
- ✓ Search shows single resource

### Scenario 3: Status Correction

**Objective:** Test entered-in-error workflow

```bash
# 1. Create a note (use Scenario 1)
# Assume DOC_ID is from Scenario 1's response

# 2. Submit partial update using request.ts
TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%S")
DEBUG_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario3-correction"
mkdir -p "$DEBUG_DIR"

# Create minimal update payload
PATIENT_ID=$(jq -r '.patientId' .fhir-configs/${SERVER_NAME}.json)

cat > "$DEBUG_DIR/update-payload.json" << EOF
{
  "resourceType": "DocumentReference",
  "id": "${DOC_ID}",
  "status": "entered-in-error",
  "subject": {"reference": "Patient/${PATIENT_ID}"}
}
EOF

cat > "$DEBUG_DIR/request.ts" << EOF
import { execute } from '../fhir-request.ts';

await execute({
  method: "PUT",
  path: "/DocumentReference/${DOC_ID}",
  bodyFile: "debug/${SERVER_NAME}/${TIMESTAMP}-scenario3-correction/update-payload.json",
  purpose: "Scenario 3: Mark document as entered-in-error",
  configName: "${SERVER_NAME}",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir
});
EOF

bun run "$DEBUG_DIR/request.ts"

# 3. GET to verify status change
GET_DIR="debug/${SERVER_NAME}/${TIMESTAMP}-scenario3-verify"
mkdir -p "$GET_DIR"

cat > "$GET_DIR/request.ts" << EOF
import { execute } from '../fhir-request.ts';

await execute({
  method: "GET",
  path: "/DocumentReference/${DOC_ID}",
  purpose: "Scenario 3: Verify status correction",
  configName: "${SERVER_NAME}",  // REQUIRED if multiple configs exist
  callerDir: import.meta.dir
});
EOF

bun run "$GET_DIR/request.ts"
# Check response-body.json - status should be "entered-in-error"

# 4. Test search behavior (may be excluded from results)
```

**Success criteria:**
- ✓ Partial update accepted
- ✓ Status changed to entered-in-error
- ✓ Still readable via direct ID

### Scenario 4: Document Replacement

**Objective:** Test supersession with relatesTo

```bash
# 1. Create initial DocumentReference
original_id = POST /DocumentReference -> capture ID

# 2. Create replacement with relatesTo
replacement = {
  ...original_template,
  "relatesTo": [{
    "code": "replaces",
    "target": {
      "reference": "DocumentReference/{{original_id}}"
    }
  }],
  "content": [{"attachment": {"data": "{{updated_content}}"}}]
}

# 3. POST replacement
POST /DocumentReference with replacement

# 4. Verify both exist
GET /DocumentReference/{{original_id}}
GET /DocumentReference/{{replacement_id}}

# 5. Confirm relatesTo preserved
```

**Success criteria:**
- ✓ Both documents exist
- ✓ relatesTo linkage preserved
- ✓ Both accessible via ID

## Common Issues & Solutions

### Issue: "Authorization failed"
- **Check:** Token is valid and not expired
- **Check:** Scopes include `DocumentReference.c` or `.u`
- **Solution:** Re-run auth helper to get fresh token

### Issue: "Patient not found"
- **Check:** Patient ID matches server's test data
- **Solution:** Use server's documented test patient IDs

### Issue: "Invalid reference"
- **For contained resources:** Use `#id` format
- **For resolvable references:** Ensure resource exists on server
- **Remember:** Servers SHALL NOT reject solely due to unresolvable references

### Issue: "Content too large"
- **Check:** Servers must support at least 5 MiB
- **Solution:** Reduce content size or check server's documented limits

### Issue: "Conditional create not working"
- **Check:** Using `If-None-Exist` header correctly
- **Check:** Identifier system and value match exactly
- **Solution:** Verify header format and identifier uniqueness

## Validation Checklist

Use this checklist to verify server conformance:

**Must Support Elements:**
- [ ] status (current)
- [ ] type (LOINC code)
- [ ] category (clinical-note)
- [ ] subject (Patient reference)
- [ ] content.attachment.contentType
- [ ] content.attachment.data or .url

**Additional Elements:**
- [ ] identifier (for idempotency)
- [ ] author (various reference types)
- [ ] context.encounter (resolvable or contained)
- [ ] context.period
- [ ] date (instant)
- [ ] content.format
- [ ] meta.security (PATAST for patient-asserted)

**Server Capabilities:**
- [ ] Accepts text/plain; charset=utf-8
- [ ] Accepts application/pdf
- [ ] Supports conditional create (If-None-Exist)
- [ ] Accepts ≥5 MiB inline content
- [ ] Returns OperationOutcome on errors
- [ ] Allows partial PUT for status correction
- [ ] Accepts and round-trips relatesTo

## References

The complete specification and test scenarios are embedded in this skill document:

**Writing Clinical Notes Specification:**
@references/spec.md

**Connectathon Test Scenarios:**
@references/scenarios.md

These provide all the details about Must Support elements, conformance requirements, and step-by-step testing instructions.

## Tips for Effective Testing

1. **Start simple:** Begin with Scenario 1 using text/plain content
2. **Test variations:** Try different note types (consultation, progress, discharge)
3. **Test edge cases:** Large files, special characters in content, missing optional fields
4. **Document findings:** Note any server-specific behaviors or limitations
5. **Iterate:** Use server feedback to refine your approach
6. **Coordinate:** Share results with other participants via Zulip/Confluence
