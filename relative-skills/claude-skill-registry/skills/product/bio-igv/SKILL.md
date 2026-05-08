---
name: bio-igv
description: "This skill should be used when the user needs to visualize BAM alignment files in IGV (Integrative Genomics Viewer). Triggers include requests to generate IGV screenshots, visualize genomic regions with multiple BAM tracks, or create batch visualizations for WGS analysis results."
user_invocable: true
---

# IGV Integration

Automated IGV (Integrative Genomics Viewer) snapshot generation for genomic regions with multiple BAM files. Designed for WGS/WES analysis visualization and quality control.

## Quick Start

### Install

Install IGV:

```bash
# macOS
brew install --cask igv

# Linux
wget https://data.broadinstitute.org/igv/projects/downloads/2.16/IGV_Linux_2.16.0_withJava.zip
unzip IGV_Linux_2.16.0_withJava.zip

# Windows
# Download from https://software.broadinstitute.org/software/igv/download
```

Install Python dependencies:

```bash
uv pip install typer
```

### Basic Usage

```bash
# Single region with multiple BAM files
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample1.bam sample2.bam sample3.bam \
  --region chr1:1000-2000 \
  --output-dir ./igv_snapshots

# Multiple regions from BED file
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample1.bam sample2.bam \
  --bed regions.bed \
  --output-dir ./igv_snapshots
```

## Scripts

### generate_igv_snapshots.py - IGV Snapshot Generation

Generate PNG screenshots of genomic regions with multiple BAM tracks using IGV batch mode.

#### Required Arguments

- `--genome TEXT` - Genome assembly ID (e.g., `hg38`, `hg19`, `mm39`)
- `--bam PATH` - BAM file path(s). Can specify multiple files.
- `--region TEXT` or `--bed PATH` - Either single region (e.g., `chr1:1000-2000`) or BED file with multiple regions
- `--output-dir PATH` - Output directory for snapshots

#### Optional Arguments

**IGV Configuration:**
- `--igv-path TEXT` - Path to IGV executable (default: auto-detect)
- `--max-panel-height INT` - Maximum panel height in pixels (default: 500)
- `--java-heap TEXT` - Java heap size (default: `2g`)

**Output:**
- `--save-batch-script` - Save IGV batch script for debugging (default: False)

#### Output Format

**PNG Screenshots:**
- Named by region: `chr1_1000-2000.png`
- Or by BED name field: `region_name.png`

**Optional Batch Script** (with `--save-batch-script`):
- `igv_batch_script.txt` - IGV commands used for snapshot generation

#### Usage Examples

```bash
# Visualize single region with 3 BAM files
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam control.bam treatment1.bam treatment2.bam \
  --region chr1:1000-2000 \
  --output-dir ./snapshots

# Visualize multiple regions from BED file
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam alignment.bam \
  --bed regions_of_interest.bed \
  --output-dir ./snapshots

# Custom IGV settings with larger panel height
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --region chr1:1000-2000 \
  --output-dir ./snapshots \
  --max-panel-height 800 \
  --java-heap 4g

# Save batch script for debugging
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --region chr1:1000-2000 \
  --output-dir ./snapshots \
  --save-batch-script
```

## Workflow Examples

### Example 1: Visualize BLAT Results

Visualize BLAT alignment results from BAM file:

```bash
# Step 1: Extract BLAT hit regions to BED file
# (Assuming you have BLAT results in PSL or JSON format)
echo -e "chr1\t1000\t2000\tinsert1" > blat_hits.bed
echo -e "chr2\t5000\t6000\tinsert2" >> blat_hits.bed

# Step 2: Generate IGV snapshots
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam alignment.bam \
  --bed blat_hits.bed \
  --output-dir ./blat_visualizations
```

### Example 2: Compare Multiple Samples

Visualize the same regions across multiple BAM files:

```bash
# Generate snapshots with all samples loaded
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample1.bam sample2.bam sample3.bam \
  --bed candidate_regions.bed \
  --output-dir ./multi_sample_comparison
```

### Example 3: Validate Variant Calls

Visualize variant sites with BAM alignment:

```bash
# Step 1: Extract variant positions to BED
# (From VCF file using vcf-toolkit or bcftools)
bcftools query -f '%CHROM\t%POS0\t%END\t%ID\n' variants.vcf > variant_sites.bed

# Step 2: Visualize with flanking regions
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam alignment.bam \
  --bed variant_sites.bed \
  --output-dir ./variant_validation \
  --max-panel-height 600
```

## IGV Batch Script Format

The script generates IGV batch commands in this format:

```
new
genome hg38
load /path/to/sample1.bam
load /path/to/sample2.bam
snapshotDirectory /path/to/output
maxPanelHeight 500
goto chr1:1000-2000
snapshot chr1_1000-2000.png
goto chr2:5000-6000
snapshot chr2_5000-6000.png
exit
```

## Error Handling

### IGV Not Found

```bash
$ python scripts/generate_igv_snapshots.py --genome hg38 --bam sample.bam --region chr1:1000-2000 --output-dir ./out

Error: IGV not found. Please install IGV or specify path with --igv-path.
Install: brew install --cask igv (macOS) or download from https://software.broadinstitute.org/software/igv/download
```

**Solution:** Install IGV or specify path:

```bash
# Install IGV
brew install --cask igv

# Or specify custom path
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --region chr1:1000-2000 \
  --output-dir ./out \
  --igv-path /path/to/igv.sh
```

### Invalid Region Format

```bash
$ python scripts/generate_igv_snapshots.py --genome hg38 --bam sample.bam --region 1000-2000 --output-dir ./out

Error: Invalid region format: 1000-2000. Expected format: chr1:1000-2000
```

**Solution:** Use correct region format `chr:start-end`:

```bash
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --region chr1:1000-2000 \
  --output-dir ./out
```

### No Snapshots Generated

```bash
$ python scripts/generate_igv_snapshots.py --genome hg38 --bam sample.bam --region chr1:1000-2000 --output-dir ./out

Snapshots generated successfully in: ./out
Total regions processed: 1

Warning: No snapshots found. Check IGV output for errors.
```

**Possible causes:**
1. BAM file not indexed (create with `samtools index`)
2. Region not present in BAM file
3. IGV failed to start (check `--save-batch-script` for debugging)

**Solution:**

```bash
# Check BAM file is indexed
samtools index sample.bam

# Save batch script to debug IGV execution
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --region chr1:1000-2000 \
  --output-dir ./out \
  --save-batch-script

# Manually run batch script to see errors
igv.sh -b ./out/igv_batch_script.txt
```

## Best Practices

### 1. Always Index BAM Files

Create BAM index before generating snapshots:

```bash
# ✅ Good: Index BAM files first
samtools index sample1.bam
samtools index sample2.bam

# Then generate snapshots
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample1.bam sample2.bam \
  --region chr1:1000-2000 \
  --output-dir ./snapshots
```

### 2. Use BED Files for Multiple Regions

For batch processing, use BED files instead of multiple script calls:

```bash
# ✅ Good: Single call with BED file
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --bed regions.bed \
  --output-dir ./snapshots

# ❌ Bad: Multiple script calls
python scripts/generate_igv_snapshots.py --bam sample.bam --region chr1:1000-2000 --output-dir ./out
python scripts/generate_igv_snapshots.py --bam sample.bam --region chr2:5000-6000 --output-dir ./out
# ... (inefficient, IGV starts/stops repeatedly)
```

### 3. Adjust Panel Height for Readability

Increase panel height when visualizing multiple BAM tracks:

```bash
# ✅ Good: Larger panel for 5 BAM files
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam s1.bam s2.bam s3.bam s4.bam s5.bam \
  --region chr1:1000-2000 \
  --output-dir ./snapshots \
  --max-panel-height 800
```

### 4. Use Appropriate Genome Assembly

Match genome assembly to BAM file reference:

```bash
# Check BAM header for reference genome
samtools view -H alignment.bam | grep @SQ

# Use matching genome assembly
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam alignment.bam \
  --region chr1:1000-2000 \
  --output-dir ./snapshots
```

## When to Use igv-integration vs Manual IGV

| Task | igv-integration | Manual IGV |
|------|----------------|------------|
| Visualize many regions (>10) | ✅ generate_igv_snapshots.py | ❌ Too tedious |
| Generate publication figures | ✅ Reproducible batch mode | ✅ Fine-tuned manual control |
| Compare multiple samples | ✅ Load all BAMs at once | ✅ Interactive comparison |
| Validate variant calls | ✅ Automate with BED file | ✅ Interactive inspection |
| Explore data interactively | ❌ Use manual IGV | ✅ Full GUI control |

**Recommended Workflow:**
1. Use igv-integration for batch snapshot generation
2. Use manual IGV for interactive exploration and fine-tuning
3. Combine both for comprehensive analysis

## Related Skills

- **bam-toolkit** - BAM file analysis and read extraction
- **vcf-toolkit** - VCF variant analysis
- **blat-api-searching** - BLAT genome mapping to find regions for visualization
- **sequence-io** - FASTA/FASTQ sequence operations

## Troubleshooting

### Java Heap Size Errors

If IGV fails with memory errors, increase Java heap size:

```bash
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam large_file.bam \
  --region chr1:1000-2000 \
  --output-dir ./out \
  --java-heap 4g
```

### Chromosome Name Mismatch

Ensure chromosome names match between BAM file and region specification:

```bash
# Check chromosome names in BAM
samtools idxstats sample.bam | cut -f1

# Use correct chromosome name
# If BAM uses "1" instead of "chr1":
python scripts/generate_igv_snapshots.py \
  --genome hg38 \
  --bam sample.bam \
  --region 1:1000-2000 \
  --output-dir ./out
```

### BED File Format Errors

Ensure BED file has at least 3 columns (chrom, start, end):

```bash
# ✅ Good: Valid BED format
chr1	1000	2000
chr2	5000	6000	region_name

# ❌ Bad: Missing columns
chr1:1000-2000
```

## References

- [IGV User Guide](https://software.broadinstitute.org/software/igv/UserGuide)
- [IGV Batch Commands](https://software.broadinstitute.org/software/igv/batch)
- [IGV Download](https://software.broadinstitute.org/software/igv/download)
