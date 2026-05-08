---
name: taxonomy-resolver
description: Resolves ambiguous organism names to precise NCBI taxonomy IDs and scientific names, then searches for genomic data in ENA (European Nucleotide Archive). Use this skill when users provide common names (like "malaria parasite", "E. coli", "mouse"), abbreviated names, or when you need to convert any organism reference to an exact scientific name for API queries. This skill handles disambiguation through conversation and validates taxonomy IDs via NCBI Taxonomy API.
---

# Taxonomy Resolver Skill

## Purpose

This skill enables Claude to convert ambiguous organism names, common names, or taxonomy references into precise, API-ready scientific names and NCBI taxonomy IDs. It also helps users find relevant genomic data (FASTQ files, assemblies, BioProjects) from ENA. **The core principle: let external APIs do the work - Claude's role is orchestration, disambiguation, and validation - NOT inventing taxonomy data.**

## When to Use This Skill

Use this skill when:
- User mentions organisms by common name ("malaria parasite", "mosquito", "house mouse")
- User provides ambiguous scientific names ("E. coli", "SARS-CoV-2 isolate")
- User asks to search for genomic data (FASTQ, assemblies, etc.) for an organism
- You need to validate or look up taxonomy IDs
- User provides a taxonomy ID that needs verification
- Converting organism names for NCBI, ENA, or other database queries

## Core Workflow

### 1. Extract User Intent (Critical)

**Before calling any APIs, understand what the user wants.** Extract:
- **Organism**: What species/taxa are they interested in?
- **Data type**: FASTQ reads, assemblies, studies, samples, etc.
- **Filters** (optional): Library strategy (RNA-Seq, WGS, ChIP-Seq, etc.)

**Examples of intent extraction:**
- "Find FASTQ files for Plasmodium falciparum" → Organism: P. falciparum, Data: FASTQ reads
- "Search for E. coli genome assemblies" → Organism: E. coli (needs disambiguation), Data: assemblies
- "Get RNA-seq data for mouse" → Organism: Mus musculus, Data: FASTQ with RNA-Seq filter

### 2. Disambiguation (Critical)

**NEVER pass ambiguous names to APIs.** Always disambiguate to species-level or specific taxa first.

If the user's input is NOT an explicit species-level scientific name:
1. Identify the ambiguity
2. Ask a clarifying question OR show a small disambiguation list
3. Wait for user confirmation before proceeding

**Examples of ambiguous inputs that require clarification:**
- "malaria parasite" → Ask: "Which malaria parasite? (Plasmodium falciparum, P. vivax, P. malariae, P. ovale, P. knowlesi)"
- "E. coli" → Ask: "Which E. coli strain? (K-12, O157:H7, other specific strain)"
- "mouse" → Ask: "Did you mean house mouse (Mus musculus) or a different species?"
- "SARS-CoV-2 isolate" → Ask: "Please provide the specific isolate or strain name"
- "bacteria" → Too broad, ask for specific genus/species

### 3. Taxonomy Resolution

Once you have a specific name, use the `resolve_taxonomy.py` script to:
- Query NCBI Taxonomy API
- Get the official taxonomy ID
- Retrieve the scientific name
- Get taxonomic lineage
- Validate the organism exists in NCBI

### 4. ENA Search (Optional)

If the user needs FASTQ files or genomic data, use the `search_ena.py` script with **intent-based filtering**:
- **Use the extracted intent to add filters to your query**
- For RNA-seq: Add `library_strategy="RNA-Seq"` to the query
- For WGS: Add `library_strategy="WGS"` to the query
- For ChIP-seq: Add `library_strategy="ChIP-Seq"` to the query
- Search ENA's database with these filters
- **Automatically group results by BioProject**
- **Present technical details for each BioProject**:
  - Sequencing platform (Illumina, PacBio, Oxford Nanopore, etc.)
  - Library layout (SINGLE or PAIRED)
  - Read length and insert size (if available)
  - Number of runs/samples
  - Library strategy (RNA-Seq, WGS, etc.)

**Example intent-based queries:**
- User wants RNA-seq data → `python search_ena.py 'scientific_name="Plasmodium falciparum" AND library_strategy="RNA-Seq"'`
- User wants WGS data → `python search_ena.py 'scientific_name="Mus musculus" AND library_strategy="WGS"'`
- User just wants any data → `python search_ena.py "Plasmodium falciparum"`

### 5. BioProject Details (Optional)

After getting ENA search results, you can fetch detailed descriptions for BioProjects using `get_bioproject_details.py`:
- Query ENA for BioProject metadata
- Get study title and description
- Retrieve organism information and submission details
- Provide context about what each BioProject contains

## Important Principles

1. **Extract intent first**: Before calling APIs, understand what the user wants (organism, data type, filters)

2. **Use intent to filter API calls**:
   - Add `library_strategy` filters to ENA searches based on data type
   - This gives more relevant results and saves the user time

3. **Let the API handle validation**: Don't try to validate taxonomy yourself. Call the API and report what it returns.

4. **Be conversational about disambiguation**: Don't lecture, just ask naturally:
   - ✅ "Which malaria parasite are you interested in? Plasmodium falciparum or P. vivax?"
   - ❌ "I cannot proceed without a species-level designation. Please provide taxonomic clarification."

5. **Don't hallucinate taxonomy IDs**: If you're not certain, use the API. Never make up taxonomy IDs.

6. **Species-level is usually the target**: Most database queries work best with species-level names, but subspecies and strains are fine if specified.

7. **Common names are okay as starting points**: Use them to begin disambiguation, but always convert to scientific names for APIs.

## Available Scripts

### resolve_taxonomy.py

**Usage:**
```bash
python resolve_taxonomy.py "Plasmodium falciparum"
python resolve_taxonomy.py --tax-id 5833
```

**Purpose:** Queries NCBI Taxonomy API to resolve organism names to taxonomy IDs and vice versa.

**Returns:** JSON with taxonomy ID, scientific name, common name, and lineage.

### search_ena.py

**Usage:**
```bash
# Basic search
python search_ena.py "Plasmodium falciparum" --data-type fastq

# Intent-based search with library_strategy filter (RECOMMENDED)
python search_ena.py 'scientific_name="Plasmodium falciparum" AND library_strategy="RNA-Seq"'
python search_ena.py 'scientific_name="Mus musculus" AND library_strategy="WGS"'
python search_ena.py 'scientific_name="SARS-CoV-2" AND library_strategy="AMPLICON"'

# Other options
python search_ena.py "Mus musculus" --limit 10
```

**Purpose:** Searches ENA (European Nucleotide Archive) for genomic data.

**Intent-based filtering:** Use ENA query syntax to add filters based on user intent:
- `library_strategy="RNA-Seq"` - For RNA-seq/transcriptomics
- `library_strategy="WGS"` - For whole genome sequencing
- `library_strategy="WXS"` - For whole exome sequencing
- `library_strategy="ChIP-Seq"` - For ChIP-seq/epigenetics
- `library_strategy="AMPLICON"` - For amplicon sequencing
- `library_strategy="Bisulfite-Seq"` - For methylation studies

**Returns:** JSON with accession numbers, study information, and metadata. **For read_run searches, results are automatically grouped by BioProject** with:
- BioProject accession
- Number of reads associated with each BioProject
- Study title (if available)
- Sample run details
- Library strategy (experiment type)

### get_bioproject_details.py

**Usage:**
```bash
python get_bioproject_details.py PRJEB1234
python get_bioproject_details.py PRJNA123456 --format json
python get_bioproject_details.py PRJEB1234 PRJNA456789
```

**Purpose:** Fetches detailed information about BioProjects from ENA.

**Returns:** JSON with study title, description, organism, center name, and dates.

## Example Interactions

### Example 1: Simple Resolution
**User:** "What's the taxonomy ID for house mouse?"

**Claude's Process:**
1. User said "house mouse" - this is clear enough (Mus musculus is unambiguous)
2. Run: `python resolve_taxonomy.py "Mus musculus"`
3. Return the taxonomy ID to user

### Example 2: Disambiguation Required with BioProject Details
**User:** "Find FASTQ files for malaria parasite"

**Claude's Process:**
1. "Malaria parasite" is ambiguous
2. Ask: "Which malaria parasite? The main ones are:
   - Plasmodium falciparum (most common, causes severe malaria)
   - Plasmodium vivax (widespread, relapses common)
   - Plasmodium malariae
   - Plasmodium ovale"
3. Wait for user response
4. Once user specifies (e.g., "P. falciparum"), then:
   - Run: `python resolve_taxonomy.py "Plasmodium falciparum"`
   - Run: `python search_ena.py "Plasmodium falciparum" --data-type fastq`
   - Results will be grouped by BioProject automatically
5. **Present BioProject results with technical details**:
   - Platform (e.g., "Illumina HiSeq 2500")
   - Layout ("SINGLE" or "PAIRED")
   - Read length (e.g., "150 bp")
   - Number of runs
6. (Optional) If user wants more context about specific BioProjects:
   - Run: `python get_bioproject_details.py PRJEB1234 PRJEB5678`
7. Present results with BioProject grouping, descriptions, and technical specifications

### Example 3: Strain-Level Detail
**User:** "Search for E. coli K-12 data"

**Claude's Process:**
1. "E. coli K-12" is specific enough
2. Run: `python resolve_taxonomy.py "Escherichia coli K-12"`
3. Run: `python search_ena.py "Escherichia coli K-12"`
4. Present results

### Example 4: Taxonomy ID Lookup
**User:** "What organism is taxonomy ID 9606?"

**Claude's Process:**
1. Run: `python resolve_taxonomy.py --tax-id 9606`
2. Report the result (Homo sapiens)

### Example 5: Intent-Based Data Search
**User:** "I need Plasmodium falciparum RNA-seq data"

**Claude's Process:**
1. **Extract intent**: Organism = P. falciparum, Data = RNA-seq/FASTQ, Filter = RNA-Seq
2. Organism is specific enough (P. falciparum)
3. Run: `python resolve_taxonomy.py "Plasmodium falciparum"`
4. **Run with intent-based filter**: `python search_ena.py 'scientific_name="Plasmodium falciparum" AND library_strategy="RNA-Seq"' --limit 10`
5. **Present BioProject groupings with technical details**:
   - Example: "PRJEB1234: 12 runs, Illumina HiSeq 2500, PAIRED-end, 150bp reads, RNA-Seq"
6. Provide BioProject accessions and details

## Error Handling

**If NCBI API returns no results:**
- Don't assume the organism doesn't exist
- Suggest alternative spellings or ask if they meant something similar
- Example: "I couldn't find 'Homo sapian' in NCBI. Did you mean 'Homo sapiens'?"

**If ENA search returns no results:**
- Report this clearly
- Suggest broadening the search or trying different terms
- Example: "No FASTQ files found for this specific search. You might try searching for the genus or checking NCBI SRA instead."

**If network errors occur:**
- Report the error clearly
- Suggest the user check their network settings
- Note which domains need to be allowlisted (api.ncbi.nlm.nih.gov, www.ebi.ac.uk)

**If API rate limits are hit:**
- **Retry strategy**: Wait 1-2 seconds and retry the API call
- **Maximum retries**: Try up to 3 times total before reporting failure
- **Exponential backoff**: Consider increasing wait time with each retry (1s, 2s, 4s)
- After 3 failed attempts, report to the user:
  - "The API is currently rate-limited. Please wait a moment and try again."

## Network Requirements

⚠️ **Important**: This skill requires network access to:
- `api.ncbi.nlm.nih.gov` (NCBI Taxonomy API)
- `www.ebi.ac.uk` (ENA API)

If you encounter network errors, the user needs to add these domains to their network allowlist.

## Best Practices

1. **Extract user intent FIRST** - Understand what they want before calling any APIs
2. **Use intent to filter API calls** - Add appropriate filters to get more relevant results (library_strategy for ENA)
3. **Always disambiguate before calling APIs**
4. **Use the actual API responses, don't invent taxonomy data**
5. **Be conversational and helpful with disambiguation**
6. **Report API errors clearly and suggest solutions**
7. **Remember: let the APIs do the heavy lifting, Claude just orchestrates**
8. **Handle API rate limits gracefully**: If you hit rate limits, wait 1-2 seconds and retry up to 3 times before reporting failure
9. **Present BioProject groupings**: When searching ENA for reads, always present results grouped by BioProject with technical details

## Common Library Strategies for ENA Filtering

When users mention specific data types, use these `library_strategy` values:
- **RNA-seq, transcriptomics, gene expression** → `RNA-Seq`
- **Whole genome sequencing, WGS** → `WGS`
- **Whole exome sequencing, WXS, exome** → `WXS`
- **ChIP-seq, chromatin, histone** → `ChIP-Seq`
- **Amplicon sequencing, targeted sequencing** → `AMPLICON`
- **Methylation, bisulfite sequencing** → `Bisulfite-Seq`
- **ATAC-seq, chromatin accessibility** → `ATAC-seq`
- **Hi-C, chromosome conformation** → `Hi-C`
- **Metagenomics** → `METAGENOMIC`
- **Small RNA, miRNA** → `miRNA-Seq`

## Testing the Skill

To verify the skill is working:
```bash
# Test taxonomy resolution
python resolve_taxonomy.py "Homo sapiens"

# Test with taxonomy ID
python resolve_taxonomy.py --tax-id 9606

# Test ENA search (will show BioProject grouping)
python search_ena.py "Saccharomyces cerevisiae" --data-type fastq --limit 5

# Test BioProject details
python get_bioproject_details.py PRJDB7788
```

## Notes for Developers

This skill follows the principle: **"Let the APIs do the work, Claude just orchestrates."**

The skill doesn't try to make Claude an expert in taxonomy or bioinformatics. It just provides:
1. Clear guidance on when to disambiguate
2. Tools to call the right APIs
3. Instructions on how to handle responses
4. Guidance on filtering searches based on intent

All validation is the API's problem. If results seem wrong or missing, that's ENA/NCBI's issue to address, not ours.
