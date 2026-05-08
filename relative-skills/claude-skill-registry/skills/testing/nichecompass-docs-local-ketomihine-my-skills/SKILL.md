---
name: nichecompass-docs-local
description: NicheCompass 本地文档（en/latest）
---

# Nichecompass-Docs-Local Skill

Comprehensive assistance with NicheCompass spatial multi-omics analysis, generated from official documentation.

## When to Use This Skill

This skill should be triggered when:
- **Setting up NicheCompass** for spatial multi-omics analysis
- **Installing dependencies** and configuring environments for NicheCompass
- **Working with spatial transcriptomics data** and ATAC-seq integration
- **Building gene program masks** from prior knowledge databases
- **Training NicheCompass models** on spatial omics datasets
- **Analyzing model outputs** including latent spaces and niche identification
- **Performing differential analysis** of gene programs between niches
- **Visualizing spatial patterns** and cell-cell communication networks
- **Implementing multimodal analysis** with RNA + ATAC data
- **Troubleshooting NicheCompass workflows** and model training issues

## Quick Reference

### Common Patterns

**Pattern 1: Environment Setup with Virtual Environment**
```bash
python3 -m venv ${/path/to/new/virtual/environment}
source ${/path/to/new/virtual/environment}/bin/activate
pip install uv
```

**Pattern 2: NicheCompass Installation**
```bash
uv pip install nichecompass[all]
uv pip install jax[cuda12]  # For GPU support
```

**Pattern 3: PyTorch with CUDA Support**
```bash
uv pip install torch --index-url https://download.pytorch.org/whl/cu124
uv pip install pyg_lib torch_scatter torch_sparse -f https://data.pyg.org/whl/torch-2.6.0+cu124.html
```

**Pattern 4: Import Required Libraries**
```python
import os
import random
import warnings
from datetime import datetime

import gdown
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import scanpy as sc
import seaborn as sns
import squidpy as sq
from sklearn.preprocessing import MinMaxScaler

from nichecompass.models import NicheCompass
from nichecompass.utils import (add_gps_from_gp_dict_to_adata,
                                add_multimodal_mask_to_adata,
                                create_new_color_dict,
                                compute_communication_gp_network,
                                visualize_communication_gp_network,
                                extract_gp_dict_from_collectri_tf_network,
                                extract_gp_dict_from_mebocost_ms_interactions,
                                extract_gp_dict_from_nichenet_lrt_interactions,
                                extract_gp_dict_from_omnipath_lr_interactions,
                                filter_and_combine_gp_dict_gps_v2,
                                get_gene_annotations,
                                generate_enriched_gp_info_plots,
                                generate_multimodal_mapping_dict,
                                get_unique_genes_from_gp_dict)
```

**Pattern 5: Spatial Neighborhood Computation**
```python
# Compute spatial neighborhood
sq.gr.spatial_neighbors(adata,
                        coord_type="generic",
                        spatial_key=spatial_key,
                        n_neighs=n_neighbors)

# Make adjacency matrix symmetric
adata.obsp[adj_key] = (
    adata.obsp[adj_key].maximum(
        adata.obsp[adj_key].T))
```

**Pattern 6: Gene Program Extraction from OmniPath**
```python
# Retrieve OmniPath GPs (source: ligand genes; target: receptor genes)
omnipath_gp_dict = extract_gp_dict_from_omnipath_lr_interactions(
    species=species,
    load_from_disk=False,
    save_to_disk=True,
    lr_network_file_path=omnipath_lr_network_file_path,
    gene_orthologs_mapping_file_path=gene_orthologs_mapping_file_path,
    plot_gp_gene_count_distributions=True,
    gp_gene_count_distributions_save_path=f"{figure_folder_path}"
                                           "/omnipath_gp_gene_count_distributions.svg")
```

**Pattern 7: Model Configuration Parameters**
```python
### Dataset ###
dataset = "spatial_atac_rna_seq_mouse_brain"
species = "mouse"
spatial_key = "spatial"
n_neighbors = 4
n_sampled_neighbors = 4
filter_genes = True
n_svg = 3000
n_svp = 15000
filter_peaks = True
min_cell_peak_thresh_ratio = 0.005 # 0.05%
min_cell_gene_thresh_ratio = 0.005 # 0.05%

### Model ###
# AnnData keys
counts_key = "counts"
adj_key = "spatial_connectivities"
gp_names_key = "nichecompass_gp_names"
active_gp_names_key = "nichecompass_active_gp_names"
gp_targets_mask_key = "nichecompass_gp_targets"
gp_targets_categories_mask_key = "nichecompass_gp_targets_categories"
gp_sources_mask_key = "nichecompass_gp_sources"
gp_sources_categories_mask_key = "nichecompass_gp_sources_categories"
latent_key = "nichecompass_latent"

# Architecture
active_gp_thresh_ratio = 0.01
conv_layer_encoder = "gatv2conv" # change to "gcnconv" if not enough compute and memory

# Trainer
n_epochs = 400
n_epochs_all_gps = 25
lr = 0.001
lambda_edge_recon = 500000.
lambda_gene_expr_recon = 300.
lambda_chrom_access_recon = 300.
lambda_l1_masked = 0. # prior GP  regularization
lambda_l1_addon = 30. # de novo GP regularization
edge_batch_size = 256 # increase if more memory available or decrease to save memory
use_cuda_if_available = True
```

**Pattern 8: Jupyter Notebook Setup**
```python
%load_ext autoreload
%autoreload 2
warnings.filterwarnings("ignore")
pd.set_option("display.max_columns", None)

# Get time of notebook execution for timestamping saved artifacts
now = datetime.now()
current_timestamp = now.strftime("%d%m%Y_%H%M%S")
```

**Pattern 9: Bedtools Installation**
```bash
conda install bedtools=2.30.0 -c bioconda
```

**Pattern 10: Conda Environment from File**
```bash
conda env create -f environment.yaml
```

## Reference Files

This skill includes comprehensive documentation in `references/`:

- **api.md** - API documentation for NicheCompass modules and classes (54 pages)
  - `nichecompass.modules.VGPGAE` class with detailed parameters
  - Methods for forward pass, latent representation, and loss computation
  - Model architecture configuration options

- **tutorials.md** - Step-by-step tutorials and examples (9 pages)
  - Mouse Brain Multimodal Tutorial with complete workflow
  - Data preparation, model training, and analysis steps
  - Code examples for spatial multi-omics analysis

- **other.md** - General documentation (7 pages)
  - Installation instructions and setup requirements
  - User guide with hyperparameter selection recommendations
  - Release notes and version history
  - Contributing guidelines and references

Use `view` to read specific reference files when detailed information is needed.

## Working with This Skill

### For Beginners
Start with the installation guide in `references/other.md` to set up your environment properly. The mouse brain multimodal tutorial in `references/tutorials.md` provides a complete end-to-end workflow that's perfect for learning the basics.

### For Intermediate Users
Focus on the API documentation in `references/api.md` to understand the VGPGAE module parameters and methods. The user guide section in `references/other.md` contains valuable hyperparameter selection recommendations based on ablation experiments.

### For Advanced Users
The API reference provides detailed information about model architecture customization, loss function configuration, and advanced features like multimodal integration. Use the release notes in `references/other.md` to stay updated with the latest features and improvements.

### For Code Examples
The quick reference section above contains practical code patterns extracted from the official tutorials and documentation. These examples cover installation, data preparation, model configuration, and analysis workflows.

## Key Concepts

### Core NicheCompass Concepts

- **Gene Programs (GPs)**: Biological pathways that NicheCompass uses to make its latent feature space interpretable through linear masked decoders
- **Spatial Multi-omics**: Integration of spatial transcriptomics with other omics modalities like ATAC-seq
- **VGPGAE (Variational Gene Program Graph Autoencoder)**: The core neural architecture that learns spatially consistent cell niches
- **Prior Knowledge GPs**: Gene programs derived from databases like OmniPath, MEBOCOST, CollecTRI, and NicheNet
- **De Novo GPs**: New gene programs discovered by the model beyond prior knowledge
- **Niche Identification (NID)**: Process of identifying spatially consistent cell niches from latent representations
- **Gene Program Recovery (GPR)**: Ability of the model to reconstruct known gene programs
- **Spatial Neighborhood Graph**: KNN graph connecting spatially proximal cells/spots
- **Multimodal Masks**: Gene-peaks mapping for integrating RNA and ATAC-seq data

### Technical Terms

- **Active GP Threshold Ratio**: Parameter determining which gene programs are considered active (default: 0.03)
- **Edge Reconstruction Loss**: Loss component preserving spatial colocalization information
- **Gene Expression Reconstruction Loss**: Loss component ensuring interpretable gene programs
- **Categorical Covariates Contrastive Loss**: Loss for handling batch effects and sample differences
- **GATv2 vs GCNConv**: Different graph neural network layers for the encoder
- **Leiden Clustering**: Community detection algorithm used for niche identification

## Resources

### references/
Organized documentation extracted from official sources. These files contain:
- Detailed explanations of NicheCompass architecture and methods
- Complete code examples with language annotations
- Installation and setup instructions
- Hyperparameter recommendations based on experimental results
- Links to original documentation and supplementary materials

### scripts/
Add helper scripts here for common automation tasks such as:
- Data preprocessing pipelines
- Model training automation
- Result visualization workflows
- Batch processing of multiple samples

### assets/
Add templates, boilerplate, or example projects here such as:
- Configuration file templates
- Example datasets in proper format
- Custom gene program definitions
- Visualization scripts and utilities

## Notes

- NicheCompass requires Python 3.10 and GPU support is recommended for training
- Apple silicon and multi-GPU training are not yet supported
- Virtual environment setup is strongly recommended over system Python installation
- The package is built on PyG (PyTorch Geometric) and AnnData frameworks
- Model performance depends on proper hyperparameter selection and spatial neighborhood configuration
- Gene program quality significantly impacts niche identification and biological interpretability

## Updating

To refresh this skill with updated documentation:
1. Re-run the scraper with the same configuration on the latest NicheCompass documentation
2. The skill will be rebuilt with the latest API changes, tutorials, and features
3. Check the release notes in `references/other.md` for important updates and breaking changes