---
name: bio-vcf
description: "This skill should be used when the user asks to analyze, filter, or inspect VCF/BCF variant files from WGS/WES sequencing. Triggers include requests to calculate variant statistics, filter variants by quality/depth/frequency, extract variants from specific chromosomes or regions, or export variant data as JSON for downstream analysis."
user_invocable: true
---

# VCF Toolkit

Toolkit for VCF/BCF variant file analysis: calculate statistics, filter variants, and export as JSON. Designed for WGS/WES sequencing result inspection and quality control.

## Quick Start

### Install

```bash
uv pip install pysam typer
```

### Basic Usage

```bash
# 1. VCF 統計情報を取得
python scripts/vcf_stats.py --vcf variants.vcf.gz --chrom chr1

# 2. 高品質バリアントのみをフィルタして新しい VCF を作成
python scripts/filter_vcf.py \
  --vcf variants.vcf.gz \
  --output high_quality.vcf \
  --min-qual 30 \
  --min-dp 10

# 3. フィルタされたバリアントを JSON で出力（≤100 エントリ）
python scripts/inspect_vcf.py \
  --vcf high_quality.vcf \
  --chrom chr1 \
  --output chr1.json
```

## Scripts

### inspect_vcf.py - VCF Inspection & JSON Export

Extract variants from VCF files for specific chromosomes or regions and export as JSON format.

#### Required Arguments

- `--vcf PATH` - Input VCF file path
- `--chrom TEXT` or `--region TEXT` - Either one required
  - `--chrom`: Entire chromosome (e.g., `chr1`)
  - `--region`: Specific region (e.g., `chr1:1000000-2000000`)

#### Optional Arguments

**Output:**
- `--output PATH` - JSON output path (default: stdout)

**Filter Conditions:**
- `--min-qual FLOAT` - Minimum quality score (QUAL >= X)
- `--min-dp INT` - Minimum depth (INFO/DP >= X)
- `--min-af FLOAT` - Minimum allele frequency (INFO/AF >= X)
- `--max-af FLOAT` - Maximum allele frequency (INFO/AF <= X)
- `--pass-only` / `--all-filters` - PASS only (default) / Include all filters

**Limits:**
- `--max-variants INT` - Maximum variant count (default: 100)
- `--force` - Ignore entry limit (allows large JSON output)

#### Output Format (JSON)

```json
{
  "num_variants": 45,
  "samples": ["sample1", "sample2"],
  "variants": [
    {
      "chrom": "chr1",
      "pos": 12345,
      "id": "rs123456",
      "ref": "A",
      "alts": ["G"],
      "qual": 100.0,
      "filter": ["PASS"],
      "info": {
        "DP": 50,
        "AF": [0.5],
        "AC": [25]
      },
      "samples": {
        "sample1": {"GT": "0/1", "DP": 25, "GQ": 99},
        "sample2": {"GT": "0/0", "DP": 25, "GQ": 99}
      }
    }
  ]
}
```

### vcf_stats.py - VCF Statistics

Calculate comprehensive statistics from VCF files and output as JSON. Includes variant counts, quality distributions, depth distributions, and allele frequency statistics.

#### Arguments

**Required:**
- `--vcf PATH` - Input VCF file path

**Optional:**
- `--chrom TEXT` - Chromosome specification (default: all chromosomes)
- `--region TEXT` - Region specification (e.g., `chr1:1000-2000`)
- `--output PATH` - JSON output path (default: stdout)

#### Output Content (JSON)

- `total_variants` - Total variant count
- `filter_counts` - Breakdown by filter (PASS, LowQual, etc.)
- `variant_types` - Breakdown by variant type (SNP, insertion, deletion)
- `chrom_counts` - Variant count per chromosome
- `quality_stats` - Quality score statistics (min, max, mean, median)
- `depth_stats` - Depth statistics (INFO/DP)
- `allele_frequency_stats` - Allele frequency statistics (INFO/AF)

#### Usage Examples

```bash
# Calculate statistics for chr1
python scripts/vcf_stats.py --vcf variants.vcf.gz --chrom chr1

# Calculate statistics for all chromosomes (output to JSON file)
python scripts/vcf_stats.py --vcf variants.vcf.gz --output stats.json

# Calculate statistics for specific region
python scripts/vcf_stats.py --vcf variants.vcf.gz --region chr1:10000-20000
```

### filter_vcf.py - VCF Filtering

Filter VCF files by quality, depth, and allele frequency criteria. Output filtered variants as a new VCF file.

#### Arguments

**Required:**
- `--vcf PATH` - Input VCF file path
- `--output PATH` - Output VCF file path

**Optional:**
- `--chrom TEXT` - Chromosome specification
- `--region TEXT` - Region specification (e.g., `chr1:1000-2000`)
- `--min-qual FLOAT` - Minimum quality score
- `--min-dp INT` - Minimum depth (INFO/DP)
- `--min-af FLOAT` - Minimum allele frequency (INFO/AF)
- `--max-af FLOAT` - Maximum allele frequency (INFO/AF)
- `--pass-only` - PASS variants only (default: False)

#### Usage Examples

```bash
# Extract chr1 PASS variants only
python scripts/filter_vcf.py \
  --vcf variants.vcf.gz \
  --output chr1_pass.vcf \
  --chrom chr1 \
  --pass-only

# Extract high-quality variants (QUAL >= 30, DP >= 10)
python scripts/filter_vcf.py \
  --vcf variants.vcf.gz \
  --output high_quality.vcf \
  --min-qual 30 \
  --min-dp 10

# Extract rare variants (AF <= 0.01)
python scripts/filter_vcf.py \
  --vcf variants.vcf.gz \
  --output rare_variants.vcf \
  --max-af 0.01
```

## Workflow Examples

### Example 1: Comprehensive Variant Analysis Workflow

Combine all three scripts for complete VCF analysis:

```bash
# Step 1: Calculate overall statistics
python scripts/vcf_stats.py --vcf variants.vcf.gz --chrom chr1 --output stats.json

# Step 2: Filter high-quality variants to new VCF
python scripts/filter_vcf.py \
  --vcf variants.vcf.gz \
  --output high_quality.vcf \
  --chrom chr1 \
  --min-qual 30 \
  --min-dp 10 \
  --pass-only

# Step 3: Export filtered variants as JSON for downstream analysis
python scripts/inspect_vcf.py \
  --vcf high_quality.vcf \
  --chrom chr1 \
  --output chr1_filtered.json
```

### Example 2: Rare Variant Discovery

Identify and export rare variants from specific region:

```bash
# Filter rare variants (AF <= 0.01)
python scripts/filter_vcf.py \
  --vcf variants.vcf.gz \
  --output rare.vcf \
  --region chr17:41196312-41277500 \
  --max-af 0.01

# Export as JSON for analysis
python scripts/inspect_vcf.py \
  --vcf rare.vcf \
  --region chr17:41196312-41277500 \
  --output brca1_rare.json
```

## Error Handling

### Variant Count Exceeds Limit

```bash
$ python scripts/inspect_vcf.py --vcf huge.vcf --chrom chr1 --output out.json

Error: VCF contains 1,234+ variants after filtering (limit: 100).

Suggestions:
  - Apply more restrictive filters: --min-qual, --min-dp, --pass-only
  - Specify a genomic region: --region chr1:1000-2000
  - Override limit with --force (warning: may produce very large JSON)
  - Use bcftools directly for large-scale processing

Current filter conditions:
  --chrom chr1 --pass-only
```

**Solutions:**
- Apply more restrictive filters: `--min-qual 30`, `--min-dp 10`
- Narrow down the region: `--region chr1:1000000-1100000`
- Override limit with `--force` (use cautiously)

### Missing Chromosome/Region Specification

```bash
$ python scripts/inspect_vcf.py --vcf variants.vcf --output out.json

Error: Either --chrom or --region must be specified.
```

**Solutions:**
- Add `--chrom chr1` or `--region chr1:1000-2000` to the command

## Best Practices

### 1. Always Specify Chromosome or Region

Always specify chromosome or region when using inspect_vcf.py to avoid processing entire VCF files inefficiently.

```bash
# ❌ Bad: No chromosome specified
python scripts/inspect_vcf.py --vcf variants.vcf

# ✅ Good: Chromosome specified
python scripts/inspect_vcf.py --vcf variants.vcf --chrom chr1
```

### 2. Apply Additional Filters for Efficiency

Combine quality and depth filters with default PASS-only filtering for better results.

```bash
# ✅ Good: Multiple filters applied
python scripts/inspect_vcf.py \
  --vcf variants.vcf \
  --chrom chr1 \
  --min-qual 30 \
  --min-dp 10
```

### 3. Respect 100-Entry Limit for JSON Export

Use inspect_vcf.py for small datasets only. Pre-filter large VCF files with filter_vcf.py or bcftools before JSON export.

```bash
# Pre-filter large datasets with bcftools
bcftools view -i 'QUAL>=30 && DP>=10' -r chr1:1000000-2000000 variants.vcf > filtered.vcf

# Then export to JSON
python scripts/inspect_vcf.py --vcf filtered.vcf --chrom chr1 --output filtered.json
```

### 4. Use --force Cautiously

Use --force only when necessary. JSON files with thousands of entries can become several MB to tens of MB in size.

## When to Use vcf-toolkit vs bcftools

| Task | vcf-toolkit | bcftools |
|------|-------------|----------|
| Small dataset JSON export | ✅ inspect_vcf.py | - |
| Large-scale filtering | filter_vcf.py | ✅ bcftools view |
| Complex filter expressions | - | ✅ bcftools |
| VCF-to-VCF conversion | filter_vcf.py | ✅ bcftools |
| Variant statistics | ✅ vcf_stats.py | ✅ bcftools stats |

**Recommended Workflow:**
1. Pre-filter large datasets with bcftools or filter_vcf.py
2. Export filtered results to JSON with inspect_vcf.py for detailed inspection
3. Perform downstream analysis in Python/R using JSON output

## Related Skills

- **pysam** - BAM/CRAM alignment file operations
- **sequence-io** - FASTA/FASTQ sequence file operations
- **blast-search** - BLAST homology search
- **blat-api-searching** - BLAT genome mapping

## Troubleshooting

### VCF File Too Large

Specify a narrower region or pre-filter with bcftools before JSON export.

```bash
# Specify narrower region
python scripts/inspect_vcf.py --vcf variants.vcf --region chr1:1000000-1100000

# Pre-filter with bcftools
bcftools view -i 'QUAL>=50' variants.vcf | python scripts/inspect_vcf.py --vcf - --chrom chr1
```

### Index Error

Create tabix index for compressed VCF files.

```bash
# Compress with bgzip
bgzip variants.vcf

# Create tabix index
tabix -p vcf variants.vcf.gz

# Use indexed VCF
python scripts/inspect_vcf.py --vcf variants.vcf.gz --chrom chr1
```

### Include Non-PASS Variants

Use `--all-filters` flag to include all variants regardless of FILTER field.

```bash
python scripts/inspect_vcf.py --vcf variants.vcf --chrom chr1 --all-filters
```
