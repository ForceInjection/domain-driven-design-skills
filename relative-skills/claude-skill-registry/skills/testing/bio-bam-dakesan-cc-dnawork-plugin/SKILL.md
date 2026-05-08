---
name: bio-bam
description: "This skill should be used when the user asks to analyze BAM/SAM/CRAM alignment files from WGS/WES sequencing. Triggers include requests to extract reads from specific regions, identify insertions and deletions, calculate coverage statistics, or export read data as JSON for downstream analysis."
user_invocable: true
---

# BAM Toolkit

Toolkit for BAM/SAM/CRAM alignment file analysis: extract reads, identify indels, and calculate coverage. Designed for WGS/WES sequencing result inspection and quality control.

## Quick Start

### Install

```bash
uv pip install pysam typer
```

### Basic Usage

```bash
# 1. 特定領域のリードを抽出
python scripts/extract_reads.py --bam alignment.bam --region chr1:1000-2000 --output reads.json --format json

# 2. Indel を抽出
python scripts/extract_indels.py --bam alignment.bam --region chr1:1000-2000 --output indels.json

# 3. カバレッジ統計を計算
python scripts/calculate_coverage.py --bam alignment.bam --region chr1:1000-2000 --output coverage.json
```

## Scripts

### extract_reads.py - Read Extraction

Extract reads from BAM/SAM/CRAM files for specific genomic regions and export as BAM or JSON format.

#### Required Arguments

- `--bam PATH` - Input BAM/SAM/CRAM file path
- `--region TEXT` - Genomic region (e.g., `chr1:1000-2000`)

#### Optional Arguments

**Output:**
- `--output PATH` - Output file path (BAM or JSON based on extension)
- `--format TEXT` - Output format: `bam` or `json` (default: `bam`)

**Filters:**
- `--min-mapq INT` - Minimum mapping quality (default: 0)
- `--proper-pairs` - Only properly paired reads
- `--no-duplicates` - Exclude duplicate reads

#### Output Format (JSON)

```json
{
  "region": "chr1:1000-2000",
  "total_reads": 150,
  "filtered_from": 200,
  "filters": {
    "min_mapq": 30,
    "proper_pairs_only": true,
    "no_duplicates": true
  },
  "reads": [
    {
      "query_name": "read1",
      "reference_start": 1050,
      "reference_end": 1150,
      "sequence": "ATCG...",
      "quality": "IIII...",
      "mapping_quality": 60,
      "is_reverse": false,
      "cigar": "100M",
      "is_proper_pair": true,
      "is_duplicate": false,
      "is_paired": true,
      "mate_is_reverse": true,
      "mate_reference_name": "chr1",
      "mate_reference_start": 1200,
      "template_length": 250
    }
  ]
}
```

#### Output Format (BAM)

When `--format bam` is specified, outputs a filtered BAM file containing only reads that pass the specified filters.

#### Usage Examples

```bash
# Extract reads as JSON
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --output reads.json \
  --format json

# Extract reads as BAM
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --output reads.bam

# Extract high-quality properly-paired reads
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --proper-pairs \
  --no-duplicates \
  --output filtered.bam
```

### extract_indels.py - Insertion/Deletion Extraction

Extract insertions and deletions from reads in specified genomic regions by parsing CIGAR strings.

#### Required Arguments

- `--bam PATH` - Input BAM/SAM/CRAM file path
- `--region TEXT` - Genomic region (e.g., `chr1:1000-2000`)

#### Optional Arguments

**Output:**
- `--output PATH` - JSON output file path (default: stdout)

**Filters:**
- `--min-mapq INT` - Minimum mapping quality (default: 20)
- `--min-indel-size INT` - Minimum indel size in bp (default: 1)

#### Output Format (JSON)

```json
{
  "region": "chr1:1000-2000",
  "filters": {
    "min_mapq": 20,
    "min_indel_size": 1
  },
  "reads": {
    "total": 500,
    "processed": 450
  },
  "summary": {
    "total_insertions": 15,
    "total_deletions": 8,
    "unique_insertions": 5,
    "unique_deletions": 3
  },
  "insertions": [
    {
      "position": 1050,
      "size": 3,
      "sequence": "ATG",
      "read_name": "read1",
      "mapping_quality": 60,
      "count": 3,
      "supporting_reads": ["read1", "read2", "read3"]
    }
  ],
  "deletions": [
    {
      "position": 1100,
      "size": 2,
      "read_name": "read2",
      "mapping_quality": 55,
      "count": 2,
      "supporting_reads": ["read2", "read5"]
    }
  ]
}
```

#### Implementation Details

- Parses CIGAR strings to identify I (insertion) and D (deletion) operations
- Extracts sequences for insertions from read sequences
- Groups identical indels by position and sequence/size
- Counts supporting reads for each unique indel
- Filters by mapping quality and minimum indel size

#### Usage Examples

```bash
# Extract all indels
python scripts/extract_indels.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --output indels.json

# Extract large indels only (>= 5bp)
python scripts/extract_indels.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-indel-size 5 \
  --output large_indels.json

# High-quality indels only
python scripts/extract_indels.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --output hq_indels.json
```

### calculate_coverage.py - Coverage Calculation

Calculate coverage statistics for specified genomic regions using pileup operations.

#### Required Arguments

- `--bam PATH` - Input BAM/SAM/CRAM file path
- `--region TEXT` - Genomic region (e.g., `chr1:1000-2000`)

#### Optional Arguments

**Output:**
- `--output PATH` - JSON output file path (default: stdout)

**Options:**
- `--min-mapq INT` - Minimum mapping quality (default: 0)
- `--min-baseq INT` - Minimum base quality (default: 0)

#### Output Format (JSON)

```json
{
  "region": "chr1:1000-2000",
  "filters": {
    "min_mapq": 0,
    "min_baseq": 0
  },
  "statistics": {
    "total_bases": 1000,
    "mean_coverage": 45.3,
    "median_coverage": 48,
    "min_coverage": 0,
    "max_coverage": 120,
    "bases_with_coverage": 995,
    "bases_without_coverage": 5,
    "percent_covered": 99.5
  }
}
```

#### Usage Examples

```bash
# Calculate coverage statistics
python scripts/calculate_coverage.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --output coverage.json

# High-quality bases only
python scripts/calculate_coverage.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --min-baseq 20 \
  --output hq_coverage.json
```

## Workflow Examples

### Example 1: Comprehensive Read Analysis Workflow

Combine all three scripts for complete BAM analysis:

```bash
# Step 1: Calculate coverage statistics
python scripts/calculate_coverage.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --output coverage.json

# Step 2: Extract indels
python scripts/extract_indels.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --output indels.json

# Step 3: Extract reads as JSON for detailed inspection
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --format json \
  --output reads.json
```

### Example 2: High-Quality Indel Discovery

Identify large insertions and deletions with high-quality reads:

```bash
# Extract large indels (>= 10bp) with high mapping quality
python scripts/extract_indels.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --min-indel-size 10 \
  --output large_indels.json

# Extract supporting reads for manual validation
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --output supporting_reads.bam
```

### Example 3: Coverage Quality Control

Assess sequencing coverage quality across target region:

```bash
# Calculate coverage statistics with quality filters
python scripts/calculate_coverage.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --min-baseq 20 \
  --output coverage_stats.json

# Extract reads from low-coverage regions for inspection
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1500-1600 \
  --format json \
  --output low_coverage_reads.json
```

## Error Handling

### Missing BAM Index

```bash
$ python scripts/extract_reads.py --bam alignment.bam --region chr1:1000-2000

Error fetching reads: random access requires an index
Make sure the region 'chr1:1000-2000' exists and BAM file is indexed.
```

**Solution:** Create BAM index with samtools:

```bash
samtools index alignment.bam
```

### Invalid Region Format

```bash
$ python scripts/extract_reads.py --bam alignment.bam --region 1000-2000

Error: Invalid region format: 1000-2000. Expected format: chr1:1000-2000
```

**Solution:** Use correct region format `chr:start-end`:

```bash
python scripts/extract_reads.py --bam alignment.bam --region chr1:1000-2000
```

## Best Practices

### 1. Always Index BAM Files

Create BAM index before using any scripts to enable efficient random access:

```bash
# ✅ Good: Index BAM file first
samtools index alignment.bam

# Then use bam-toolkit scripts
python scripts/extract_reads.py --bam alignment.bam --region chr1:1000-2000
```

### 2. Apply Quality Filters for Reliable Results

Use mapping quality and base quality filters to ensure reliable analysis:

```bash
# ✅ Good: Apply quality filters
python scripts/extract_indels.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30

# ✅ Good: Use proper pairs for structural variant analysis
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --proper-pairs \
  --no-duplicates
```

### 3. Extract Reads as BAM for Further Processing

Use BAM output when planning to use extracted reads with other tools:

```bash
# ✅ Good: Extract as BAM for use with samtools/IGV
python scripts/extract_reads.py \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --min-mapq 30 \
  --output filtered.bam

# Then index and use with other tools
samtools index filtered.bam
samtools view filtered.bam
```

## When to Use bam-toolkit vs samtools

| Task | bam-toolkit | samtools |
|------|-------------|----------|
| Read extraction as JSON | ✅ extract_reads.py | - |
| Indel extraction with grouping | ✅ extract_indels.py | - |
| Coverage statistics as JSON | ✅ calculate_coverage.py | ✅ samtools depth |
| BAM-to-BAM filtering | ✅ extract_reads.py | ✅ samtools view |
| Read alignment statistics | - | ✅ samtools flagstat |
| BAM indexing | - | ✅ samtools index |

**Recommended Workflow:**
1. Index BAM files with samtools
2. Use bam-toolkit scripts for structured JSON output
3. Use samtools for standard BAM operations (sorting, indexing, format conversion)

## Related Skills

- **vcf-toolkit** - VCF/BCF variant file operations
- **sequence-io** - FASTA/FASTQ sequence file operations
- **blast-search** - BLAST homology search
- **blat-api-searching** - BLAT genome mapping

## Troubleshooting

### BAM File Not Readable

Ensure BAM file is properly formatted and readable:

```bash
# Check BAM file integrity
samtools quickcheck alignment.bam

# View BAM header
samtools view -H alignment.bam
```

### Chromosome Name Mismatch

Chromosome names must match between BAM file and region specification:

```bash
# Check chromosome names in BAM
samtools idxstats alignment.bam | cut -f1

# Use correct chromosome name
# If BAM uses "1" instead of "chr1":
python scripts/extract_reads.py --bam alignment.bam --region 1:1000-2000
```

### Empty Output

If output is empty, check:
1. Region contains aligned reads: `samtools view alignment.bam chr1:1000-2000 | head`
2. Filters are not too restrictive (try reducing `--min-mapq`)
3. Chromosome name matches BAM file
