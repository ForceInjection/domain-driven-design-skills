---
name: run-underwriter
description: Run the mortgage underwriter CLI to analyze loan documents. Use when testing document analysis, debugging underwriter output, or processing loan files. Covers setup, execution, and result interpretation.
allowed-tools:
  - Bash
  - Read
---

# Run Underwriter CLI

## Purpose
Execute and debug the mortgage underwriter tool for document analysis.

## Prerequisites

### 1. Set API Key
```bash
export GEMINI_API_KEY="your-gemini-api-key"
```

### 2. Build the Binary
```bash
make build
```

### 3. Fetch Guidelines (if needed)
```bash
make fetch-guidelines
```

## Usage

### Analyze a Directory of Documents
```bash
./bin/underwriter -docs /path/to/documents
```

### Analyze Specific Files
```bash
./bin/underwriter -files w2.pdf,paystub.pdf,bank_statement.pdf
```

### JSON Output (for programmatic use)
```bash
./bin/underwriter -docs /path/to/documents -json
```

### Custom Guidelines Path
```bash
./bin/underwriter -docs /path/to/documents -guidelines /custom/path
```

### All CLI Flags
```
-docs string       Directory containing documents to analyze
-files string      Comma-separated list of document files
-guidelines string Path to Fannie Mae guidelines (default "configs/guidelines")
-app-id string     Application ID (default "test-001")
-json              Output results as JSON
```

## Test with Sample Documents
```bash
# Generate test documents first (if needed)
cd test_loan_files && python3 generate_loan_docs.py && cd ..

# Run on test loan file
./bin/underwriter -docs test_loan_files/loan_file_1_LN-2024-001847
```

## Understanding Output

### Analysis Result Structure
- **status**: `approved` | `conditional` | `denied` | `needs_review` | `incomplete`
- **confidence**: 0.0 to 1.0 score
- **findings**: Observations with category, description, evidence, document ID
- **risks**: Identified risks with severity (low/medium/high/critical) and mitigation
- **missing_documents**: Required documents not provided
- **summary**: Brief description of analysis

### Status Meanings
| Status | Meaning |
|--------|---------|
| approved | Meets all guidelines |
| conditional | Approved with conditions |
| denied | Does not meet guidelines |
| needs_review | Manual review required |
| incomplete | Missing required documents |

## Troubleshooting

### "GEMINI_API_KEY not set"
```bash
export GEMINI_API_KEY="your-key"
```

### "No documents found"
- Check file paths exist
- Supported extensions: .pdf, .png, .jpg, .jpeg

### Document Type Misdetection
Files are typed by filename patterns:
- `*w2*` or `*w-2*` -> W2
- `*paystub*` or `*pay*` -> Paystub
- `*bank*` -> Bank Statement
- `*tax*` or `*1040*` -> Tax Return
- `*1099*` -> 1099

### Guidelines Not Loading
```bash
make fetch-guidelines
ls configs/guidelines/
```

## Related Files
- `cmd/underwriter/main.go` - CLI implementation
- `internal/agent/income/income.go` - Income agent logic
- `internal/model/analysis.go` - Result structures
