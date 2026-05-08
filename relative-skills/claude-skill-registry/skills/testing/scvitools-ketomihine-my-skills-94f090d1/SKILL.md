---
name: scvitools
description: Comprehensive skill for scvi-tools - Deep probabilistic models for single-cell omics analysis. Use for scVI, scANVI, totalVI, MultiVI models, single-cell RNA-seq integration, batch correction, differential expression, and multimodal data analysis.
---

# Scvitools Skill

Comprehensive assistance with scvi-tools development and single-cell omics analysis using deep probabilistic models.

## When to Use This Skill

This skill should be triggered when:

**Core scvi-tools Tasks:**
- Working with scvi-tools models (scVI, scANVI, totalVI, MultiVI, etc.)
- Setting up AnnData objects for scvi-tools analysis
- Performing batch correction and data integration
- Running differential expression analysis
- Analyzing single-cell RNA-seq, ATAC-seq, or multimodal data
- Implementing custom model classes or modules

**Analysis and Visualization:**
- Getting latent representations and embeddings
- Creating UMAP/tSNE visualizations from scvi-tools outputs
- Interpreting model results and biological insights
- Working with spatial transcriptomics data

**Development and Advanced Tasks:**
- Building custom scvi-tools models
- Hyperparameter tuning with scvi.autotune
- Model evaluation and benchmarking
- Integration with Scanpy workflows
- Debugging scvi-tools code and installation issues

**Data Processing:**
- Preprocessing single-cell data for scvi-tools
- Setting up data registration with setup_anndata
- Handling batch effects and covariates
- Working with count data and normalization

## Quick Reference

### Core Model Setup and Training

**Basic scVI Model Setup**
```python
import scvi
import scanpy as sc

# Setup AnnData for scVI
scvi.model.SCVI.setup_anndata(
    adata,
    batch_key="batch",
    labels_key="cell_type"
)

# Create and train model
model = scvi.model.SCVI(adata)
model.train()

# Get latent representation
latent = model.get_latent_representation()
adata.obsm["X_scVI"] = latent
```

**Differential Expression Analysis**
```python
# 1-vs-1 DE test
de_results = model.differential_expression(
    groupby="cell_type",
    group1="T-cell",
    group2="B-cell"
)

# 1-vs-all DE test
de_results_all = model.differential_expression(
    groupby="cell_type",
    mode="change"
)
```

### Data Integration and Batch Correction

**Multimodal Data with totalVI**
```python
import scvi
from scvi.external import TOTALVI

# Setup for RNA + protein data
TOTALVI.setup_anndata(
    adata,
    batch_key="batch",
    protein_expression_obsm_key="protein_expression"
)

model = TOTALVI(adata)
model.train()

# Get normalized RNA and protein
rna_norm = model.get_normalized_expression()
protein_norm = model.get_protein_foregrounds()
```

**Spatial Transcriptomics with GIMVI**
```python
from scvi.external import GIMVI

# Setup spatial and seq data
spatial_adata = ...  # spatial data
seq_adata = ...      # single-cell seq data

model = GIMVI(seq_adata, spatial_adata)
model.train()

# Get latent representations for both modalities
spatial_latent = model.get_latent_representation(spatial_adata)
seq_latent = model.get_latent_representation(seq_adata)
```

### Advanced Model Customization

**Custom Model Class**
```python
from scvi.model.base import BaseModelClass, UnsupervisedTrainingMixin
from scvi.module import VAE

class CustomModel(UnsupervisedTrainingMixin, BaseModelClass):
    def __init__(self, adata, n_latent=30):
        super().__init__(adata)
        self.module = VAE(
            n_input=self.summary_stats["n_vars"],
            n_batch=self.summary_stats["n_batch"],
            n_latent=n_latent,
        )
        self._model_summary_string = f"CustomModel with n_latent: {n_latent}"
        self.init_params_ = self._get_init_params(locals())

    @classmethod
    def setup_anndata(cls, adata, batch_key=None, layer=None):
        setup_method_args = cls._get_setup_method_args(**locals())
        anndata_fields = [
            LayerField(REGISTRY_KEYS.X_KEY, layer, is_count_data=True),
            CategoricalObsField(REGISTRY_KEYS.BATCH_KEY, batch_key),
        ]
        adata_manager = AnnDataManager(fields=anndata_fields, setup_method_args=setup_method_args)
        adata_manager.register_fields(adata, **kwargs)
        cls.register_manager(adata_manager)
```

### Hyperparameter Tuning

**Automated Hyperparameter Search**
```python
import ray
from ray import tune
from scvi import autotune

# Define search space
search_space = {
    "model_params": {
        "n_hidden": tune.choice([64, 128, 256]),
        "n_layers": tune.choice([1, 2, 3])
    },
    "train_params": {
        "max_epochs": 100,
        "plan_kwargs": {"lr": tune.loguniform(1e-4, 1e-2)}
    }
}

# Run tuning
results = autotune.run_autotune(
    scvi.model.SCVI,
    data=adata,
    mode="min",
    metrics="validation_loss",
    search_space=search_space,
    num_samples=5,
    resources={"cpu": 10, "gpu": 1}
)
```

### ATAC-seq Analysis

**scBasset for scATAC-seq**
```python
from scvi.external import ScBasset

# Setup ATAC data
ScBasset.setup_anndata(adata, batch_key="batch")

# Create and train model
model = ScBasset(adata)
model.train()

# Get latent representation
latent = model.get_latent_representation()
adata.obsm["X_scBasset"] = latent

# Score TF activity
tf_activities = model.score_tf_activity("motif_library_path")
```

### Spatial Data Analysis

**ResolVI for Spatial Transcriptomics**
```python
from scvi.external import RESOLVI

# Setup spatial data
RESOLVI.setup_anndata(
    adata,
    batch_key="slice",
    labels_key="cell_type"
)

# Train model
model = RESOLVI(adata)
model.train()

# Get corrected counts
corrected_counts = model.get_corrected_counts()

# Differential abundance in spatial neighborhoods
da_results = model.differential_abundance(
    groupby="cell_type",
    group1="neuron_layer1",
    group2="neuron_layer2"
)
```

### Model Evaluation and Visualization

**Model Quality Assessment**
```python
# Get ELBO (reconstruction quality)
elbo_score = model.get_elbo()

# Get reconstruction error
recon_error = model.get_reconstruction_error()

# Visualize latent space
sc.pp.neighbors(adata, use_rep="X_scVI")
sc.tl.umap(adata)
sc.pl.umap(adata, color=["cell_type", "batch"])
```

### Installation and Setup

**Installation with GPU Support**
```bash
# Basic CPU installation
pip install scvi-tools

# GPU support for Linux
pip install scvi-tools[cuda]

# Apple Silicon (MPS) support
pip install scvi-tools[metal]

# Full installation with all dependencies
pip install scvi-tools[all,tutorials,jax]
```

**Environment Setup**
```python
import scvi
import torch

# Set seed for reproducibility
scvi.settings.seed = 0

# Configure GPU settings
torch.set_float32_matmul_precision("high")

# Check version
print(f"scvi-tools version: {scvi.__version__}")
```

## Key Concepts

**Core Models:**
- **scVI**: Single-cell Variational Inference for batch correction and integration
- **scANVI**: Semi-supervised scVI for cell type annotation
- **totalVI**: Total Variational Inference for joint RNA + protein (CITE-seq) data
- **MultiVI**: Multimodal Variational Inference for paired + unpaired data
- **GIMVI**: Generative Integrative Modeling for spatial + single-cell data

**Data Structures:**
- **AnnData**: Core data structure for single-cell data
- **AnnDataManager**: scvi-tools data registry and validation system
- **setup_anndata()**: Required preprocessing step to register data with scvi-tools

**Model Architecture:**
- **BaseModelClass**: Abstract base for all scvi-tools models
- **BaseModuleClass**: Abstract base for neural network modules
- **VAEMixin**: Provides VAE-specific methods (get_latent_representation, etc.)

## Reference Files

### references/api_reference.md
**Comprehensive API Documentation** - Complete reference for all classes and methods:
- Developer API for custom model building
- Data registration utilities (AnnDataManager, AnnDataFields)
- Model base classes and mixins
- Module building blocks (encoders, decoders)
- Training plans and utilities

### references/getting_started.md
**Installation and Tutorials** - Entry points for learning scvi-tools:
- Complete installation guide (CPU, GPU, dependencies)
- Introduction to scvi-tools workflow
- gimVI tutorial for spatial transcriptomics
- Basic setup and data preparation examples

### references/tutorials.md
**In-depth Tutorial Collection** - 60+ pages of detailed tutorials:
- Topic modeling with Amortized LDA
- scBasset for scATAC-seq analysis
- ResolVI for spatial transcriptomics correction
- SHAP and IntegratedGradients for model interpretability
- Advanced use cases and specialized analyses

### references/user_guide.md
**Comprehensive User Guide** - Detailed workflow documentation:
- Complete scvi-tools workflow overview
- Data loading and preprocessing best practices
- Model creation, training, and saving
- Integration with Scanpy for downstream analysis
- Visualization and interpretation techniques

## Working with This Skill

### For Beginners

**Start Here:**
1. Read the installation guide in `references/getting_started.md`
2. Follow the basic scvi-tools tutorial for data setup
3. Practice with the Quick Reference examples above
4. Focus on basic scVI workflows first

**Recommended Learning Path:**
1. Install scvi-tools and verify setup
2. Load a sample dataset and run `setup_anndata()`
3. Create and train a basic scVI model
4. Extract latent representations and create visualizations
5. Perform simple differential expression analysis

### For Intermediate Users

**Expand Your Skills:**
1. Explore multimodal models (totalVI, MultiVI)
2. Learn hyperparameter tuning with `scvi.autotune`
3. Practice batch correction with complex datasets
4. Implement custom model classes
5. Work with spatial transcriptomics data

**Common Tasks:**
- Setting up covariates and batch effects
- Choosing appropriate model parameters
- Evaluating model quality and convergence
- Integrating with existing Scanpy workflows

### For Advanced Users

**Advanced Features:**
1. Build custom model architectures
2. Implement new modules and training plans
3. Use Pyro-based models for Bayesian analysis
4. Develop specialized analysis pipelines
5. Contribute to scvi-tools development

**Expert Resources:**
- Developer API documentation in `references/api_reference.md`
- Advanced tutorials for specialized applications
- Model architecture and extension guides

## Common Workflows

### Standard scVI Analysis
```python
# 1. Data preparation
sc.pp.filter_genes(adata, min_counts=3)
sc.pp.normalize_total(adata, target_sum=1e4)
sc.pp.log1p(adata)

# 2. Setup with scvi-tools
scvi.model.SCVI.setup_anndata(adata, batch_key="batch")

# 3. Model training
model = scvi.model.SCVI(adata)
model.train()

# 4. Downstream analysis
adata.obsm["X_scVI"] = model.get_latent_representation()
sc.pp.neighbors(adata, use_rep="X_scVI")
sc.tl.umap(adata)
```

### Quality Control and Troubleshooting

**Model Training Issues:**
- Check data preprocessing (use raw counts, not normalized)
- Verify `setup_anndata()` was called correctly
- Monitor training loss and convergence
- Adjust learning rate and architectural parameters

**Data Integration Problems:**
- Ensure proper batch key registration
- Check for sufficient shared features across batches
- Consider using scANVI for semi-supervised integration
- Validate integration quality with biological markers

## Resources

### Installation and Environment
- Virtual environment setup recommended
- GPU support available for CUDA and Apple Silicon
- Optional dependencies for specialized features

### Community and Support
- Official scvi-tools documentation
- GitHub repository for issues and contributions
- Community forums and discussion boards
- Tutorial notebooks and examples

### Performance Optimization
- GPU acceleration for model training
- Memory-efficient data loading
- Distributed training options
- Hyperparameter tuning best practices

## Notes

- This skill covers scvi-tools v1.3+ features
- Always use raw count data as input to scvi-tools models
- `setup_anndata()` must be called before model initialization
- Models train faster with GPU acceleration when available
- Integration with Scanpy provides seamless downstream analysis workflows