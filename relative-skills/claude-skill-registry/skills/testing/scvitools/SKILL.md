---
name: scvitools-docs-truly-complete
description: scvi-tools 深度学习单细胞分析工具包 - 100%覆盖文档（321个文件：完整API+用户指南+教程+开发者文档）
---

# Scvitools-Docs-Truly-Complete Skill

Comprehensive assistance with scvi-tools development, generated from official documentation covering deep probabilistic models for single-cell analysis.

## When to Use This Skill

This skill should be triggered when:

### Core scvi-tools Usage
- **Data Loading**: Reading or processing single-cell data (h5ad, csv,loom, 10x formats)
- **Model Training**: Setting up or training scVI, totalVI, MultiVI, scANVI, etc.
- **Data Integration**: Batch correction, cross-study integration, label transfer
- **Multi-modal Analysis**: CITE-seq, ATAC-seq, spatial transcriptomics data
- **Differential Analysis**: DE testing, trajectory inference, perturbation analysis

### Advanced Modeling
- **Custom Models**: Building probabilistic modules, custom data loaders
- **Hyperparameter Tuning**: Using autotune module, Ray integration
- **Model Hub**: Uploading/downloading pretrained models
- **Training Optimization**: Multi-GPU training, callbacks, minification

### Development Tasks
- **API Implementation**: Using core modules, distributions, neural networks
- **Extension Development**: Creating external models, custom training plans
- **Data Pipeline**: AnnData management, field validation, registry systems

## Quick Reference

### Essential Data Operations

**Load PBMC CITE-seq dataset**
```python
import scvi
adata = scvi.data.pbmc_seurat_v4_cite_seq()
```

**Read h5ad files with backing**
```python
adata = scvi.data.read_h5ad("data.h5ad", backed="r")
```

**Generate synthetic test data**
```python
adata = scvi.data.synthetic_iid(
    n_genes=100,
    n_batches=2,
    n_labels=3,
    return_mudata=False
)
```

### Core Model Setup

**Setup SCVI model**
```python
scvi.model.SCVI.setup_anndata(
    adata,
    layer="counts",
    batch_key="batch",
    labels_key="cell_type"
)
model = scvi.model.SCVI(adata)
```

**Train and extract latent space**
```python
model.train(max_epochs=100)
latent = model.get_latent_representation()
adata.obsm["X_scVI"] = latent
```

**Save and load models**
```python
model.save("my_model.pt")
loaded_model = scvi.model.SCVI.load("my_model.pt")
```

### Advanced Model Operations

**Setup MultiVI for multi-modal data**
```python
scvi.model.MULTIVI.setup_anndata(
    adata,
    layer="counts",
    protein_expression_obsm_key="protein_expression",
    batch_key="batch"
)
model = scvi.model.MULTIVI(adata)
```

**Differential expression analysis**
```python
de_results = model.differential_expression(
    groupby="cell_type",
    group1="CD4 T cells",
    group2="CD8 T cells"
)
```

**Hyperparameter tuning with autotune**
```python
import ray.tune as tune
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

results = scvi.autotune.run_autotune(
    scvi.model.SCVI,
    data=adata,
    mode="min",
    metrics="validation_loss",
    search_space=search_space,
    num_samples=5
)
```

### Model Hub Operations

**Download pretrained model**
```python
hub_model = scvi.hub.HubModel.pull_from_huggingface_hub("scvi-tools/model-name")
model = hub_model.load_model()
```

**Upload model to hub**
```python
metadata = scvi.hub.HubMetadata.from_dir("./model_dir", "0.8.0")
hub_model = scvi.hub.HubModel(local_dir="./model_dir", metadata=metadata)
hub_model.push_to_huggingface_hub("my-username/my-model")
```

### Data Field Management

**Access MuData layer fields**
```python
from scvi.data.fields import MuDataLayerField
field = MuDataLayerField(attr_name="layers", attr_key="counts", mod_key="rna")
registry_key = field.registry_key
```

**Use collection adapter for large datasets**
```python
from scvi.dataloaders import CollectionAdapter
adapter = CollectionAdapter(anndata_collection)
```

## Reference Files

### Core API Documentation
- **core_api_data.md**: Data loading utilities (68 pages) - `scvi.data.*` modules for reading various single-cell formats, synthetic data generation, and data field management
- **core_api_distributions.md**: Probability distributions (6 pages) - JAX-based distributions like `JaxNegativeBinomialMeanDisp` for probabilistic modeling
- **core_api_hub.md**: Model hub functionality (3 pages) - `scvi.hub.*` for uploading/downloading pretrained models via HuggingFace
- **core_api_models.md**: Model implementations - Comprehensive coverage of all scvi-tools models (SCVI, totalVI, MultiVI, etc.)
- **core_api_modules.md**: Neural network modules - VAE architectures, encoders/decoders, and probabilistic modules
- **core_api_neural_networks.md**: Neural network components - `scvi.nn.*` building blocks for custom architectures
- **core_api_training.md**: Training infrastructure - Training plans, callbacks, trainers, and optimization utilities
- **core_api_utils.md**: Utility functions - Helper functions and miscellaneous utilities

### User Guides
- **user_guide_overview.md**: High-level introduction to scvi-tools concepts and architecture
- **user_guide_models.md**: Detailed model documentation and usage patterns
- **user_guide_use_cases.md**: Common workflows and practical applications

### Tutorials
- **tutorials_quick_start.md**: Getting started guides and basic workflows
- **tutorials_scrna.md**: Single-cell RNA-seq specific tutorials (integration, DE, labeling)
- **tutorials_multimodal.md**: Multi-modal analysis (CITE-seq, MultiVI, totalVI)
- **tutorials_spatial.md**: Spatial transcriptomics analysis (gimVI, Tangram, Cell2location)
- **tutorials_atac.md**: ATAC-seq analysis (PeakVI, scBasset, PoissonVI)
- **tutorials_cytometry.md**: Flow cytometry and mass cytometry data (CytoVI)
- **tutorials_r.md**: R integration with reticulate package
- **tutorials_hub.md**: Model hub usage and deployment
- **tutorials_use_cases.md**: Specific use case examples and best practices
- **tutorials_advanced.md**: Advanced techniques and custom model development

### Development Resources
- **developer_docs.md**: Core development documentation and architecture
- **external_models.md**: External model integrations and extensions
- **installation_getting_started.md**: Setup and installation instructions
- **other.md**: Additional resources and references

## Working with This Skill

### For Beginners
1. **Start with tutorials_quick_start.md** for basic scvi-tools workflows
2. **Use tutorials_scrna.md** for standard single-cell RNA-seq analysis
3. **Reference core_api_data.md** for data loading and preprocessing
4. **Follow user_guide_overview.md** to understand core concepts

### For Intermediate Users
1. **Explore tutorials_multimodal.md** for CITE-seq and multi-modal analysis
2. **Use tutorials_spatial.md** for spatial transcriptomics applications
3. **Reference core_api_models.md** for advanced model configurations
4. **Consult tutorials_use_cases.md** for specific workflow patterns

### For Advanced Users
1. **Study developer_docs.md** for extending scvi-tools
2. **Use tutorials_advanced.md** for custom model development
3. **Reference core_api_training.md** for training optimization
4. **Explore external_models.md** for integration with other tools

### Navigation Tips
- **Quick model reference**: Check core_api_models.md for model-specific parameters
- **Data format help**: Core_api_data.md covers all supported input formats
- **Training issues**: Core_api_training.md has troubleshooting and optimization guides
- **Integration patterns**: Tutorials_multimodal.md and tutorials_spatial.md for complex data types
- **Development guidance**: Developer_docs.md for architectural understanding

## Key Concepts

### Core Models
- **SCVI**: Single-cell Variational Inference for scRNA-seq integration
- **totalVI**: Total Variational Inference for joint RNA+protein analysis
- **MultiVI**: Multi-modal Variational Inference for paired/unpaired data
- **scANVI**: Semi-supervised SCVI for cell type annotation
- **PeakVI**: Variational inference for scATAC-seq peak analysis

### Data Structures
- **AnnData**: Primary data structure for single-cell data
- **MuData**: Multi-modal data container for multiple assays
- **Data Registry**: Internal mapping of data fields to model inputs
- **Fields**: Data accessors for different AnnData/MuData attributes

### Training Infrastructure
- **Training Plans**: PyTorch Lightning modules for different model types
- **Autotune**: Ray Tune integration for hyperparameter optimization
- **Callbacks**: Training monitoring and early stopping utilities
- **Hub**: Model sharing and deployment platform

### Probabilistic Components
- **VAE**: Variational Autoencoder base architecture
- **Distributions**: Custom probability distributions for count data
- **Modules**: Neural network components and probabilistic layers
- **Inference**: Posterior approximation and variational inference methods

## Resources

### Quick Access
- **Model selection**: Use model-specific tutorials for guidance on choosing appropriate models
- **Data preparation**: Core_api_data.md for format-specific loading instructions
- **Troubleshooting**: Developer docs and training guides for common issues
- **Examples**: All tutorials contain runnable code examples with real datasets

### Development
- **External contributions**: Developer docs provide guidelines for extending scvi-tools
- **API reference**: Core API documentation for all public interfaces
- **Architecture**: Understanding the modular structure for custom development

## Notes

- This skill provides comprehensive coverage of scvi-tools v1.3.3 documentation
- All code examples are extracted from official tutorials and API documentation
- Reference files maintain original structure with complete examples and parameter descriptions
- Skill is optimized for both beginners learning scvi-tools and experts implementing advanced analyses

## Updating

To refresh this skill with updated documentation:
1. Re-run the documentation scraper with the current scvi-tools version
2. Update reference files with new API changes and tutorials
3. Verify code examples against the latest release
4. Test all patterns for compatibility with new versions