---
name: multiplex-imaging-analysis
description: "Optimizing segmentation feature extraction, SOM clustering, and spatial analysis for multiplex immunofluorescence imaging with cell compartment and ECM features"
author: smith6jt
date: 2025-12-12
---

# Multiplex Imaging Analysis - Research Notes

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2025-12-12 |
| **Goal** | Review and optimize Notebook 4 for segmentation feature extraction, SOM clustering, and spatial analysis with ECM integration |
| **Environment** | KINTSUGI v1.2.0, Python 3.10+, InstanSeg, pyFlowSOM, scanpy 1.x, scimap 2.2.x, napari-simpleitk-image-processing |
| **Status** | Planning Complete - Improvements Identified |

## Context

KINTSUGI Notebook 4 performs cell/nuclear/ECM segmentation followed by feature extraction, SOM clustering, and spatial analysis. The current workflow uses:
- **InstanSeg** for deep learning segmentation
- **napari-simpleitk-image-processing.label_statistics** for feature extraction
- **pyFlowSOM** for self-organizing map clustering
- **scanpy + scimap** for spatial analysis and phenotyping

Literature review and analysis of forked repos (scimap, KODAMA, cylinter) identified optimization opportunities in all four areas.

## Verified Workflow

### Current Feature Extraction (Working)
```python
from napari_simpleitk_image_processing import label_statistics

# Basic features work well
marker_stats = label_statistics(
    intensity_image=marker[i],
    label_image=matched_cytoplasm_label,
    size=True,
    intensity=True,
    perimeter=True,
    shape=True,
    position=True,
    moments=True
)
```

### Current SOM Clustering (Working)
```python
import pyFlowSOM
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
train_array = scaler.fit_transform(pixel_data[channels].values.astype(np.float64))
som = pyFlowSOM.som(train_array, grid_size, grid_size, num_passes,
                    alpha_range=(lr_start, lr_end), seed=627)
clusters, dist = pyFlowSOM.map_data_to_nodes(som, train_array)
```

### ECM Mask Creation (Working)
```python
from skimage.segmentation import watershed
from scipy import ndimage

binary_mask = marker_label > 0
distance = ndimage.distance_transform_edt(~binary_mask)
ecm_label = watershed(distance, marker_label)
ecm_label[marker_label > 0] = 0  # Remove cell regions
```

### Matched Compartment Masks (Working)
```python
# Cytoplasm = cell mask minus nuclear regions
matched_cytoplasm_label = marker_label.copy()
matched_cytoplasm_label[nuclear_label > 0] = 0

# Nuclear regions from cell mask
matched_nuclear_label = marker_label.copy()
matched_nuclear_label[matched_cytoplasm_label > 0] = 0
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Using `resolve_cell_and_nucleus=True` in InstanSeg | Can cause label mismatches between cell and nuclear masks | Set to `False` and create matched masks post-hoc for consistent labels |
| Clustering all markers together without compartment separation | Dilutes compartment-specific signals, mixed phenotypes | Cluster cell, nuclear, ECM features separately then merge |
| Fixed SOM grid size (e.g., 10x10) | Under/over-clusters depending on data complexity | Use elbow method or try multiple grid sizes (5x5 to 15x15) |
| Single-pass SOM training | Unstable cluster assignments | Use 10+ passes with decreasing learning rate (0.06 -> 0.001) |
| Not StandardScaler normalizing before SOM | Markers with high intensity dominate clustering | Always z-score normalize: `StandardScaler().fit_transform()` |
| Using `sc.pp.log1p()` on uint16 without normalization | Incorrect scaling for scanpy downstream | Call `sc.pp.normalize_total()` before `sc.pp.log1p()` |
| Merging DataFrames without checking label alignment | NaN values in merged features | Use inner joins and verify label columns match |

## Recommended Improvements

### 1. Enhanced Feature Extraction
```python
from skimage.feature import graycomatrix, graycoprops
import numpy as np

def extract_texture_features(image, labels, distances=[1, 3], angles=[0, np.pi/4, np.pi/2]):
    """Add Haralick GLCM texture features per label."""
    props = ['contrast', 'homogeneity', 'energy', 'correlation']
    features = {}
    for label_id in np.unique(labels)[1:]:  # Skip background
        mask = labels == label_id
        region = image[mask].reshape(-1)
        # Compute GLCM and properties
        # Extract the region as a square patch (bounding box) for GLCM
        coords = np.argwhere(mask)
        if coords.size == 0:
            continue
        minr, minc = coords.min(axis=0)
        maxr, maxc = coords.max(axis=0) + 1
        patch = image[minr:maxr, minc:maxc]
        patch_mask = mask[minr:maxr, minc:maxc]
        # Mask out background in patch
        patch = np.where(patch_mask, patch, 0)
        # Rescale patch to 8-bit if needed
        if patch.max() > 255 or patch.dtype != np.uint8:
            patch = ((patch - patch.min()) / (patch.ptp() + 1e-8) * 255).astype(np.uint8)
        # Compute GLCM
        glcm = graycomatrix(patch, 
                            distances=distances, 
                            angles=angles, 
                            levels=256, 
                            symmetric=True, 
                            normed=True)
        # Extract properties
        features[label_id] = {}
        for prop in props:
            val = graycoprops(glcm, prop)
            # Average over distances and angles
            features[label_id][prop] = val.mean()
    return features

# Nuclear-cytoplasmic ratio (important for cell state)
nc_ratio = nuclear_df['nuclear_number_of_pixels'] / cell_df['cell_number_of_pixels']
dapi_nc_intensity_ratio = nuclear_df['nuclear_DAPI_mean'] / cell_df['cell_DAPI_mean']
```

### 2. Improved SOM Clustering (FuseSOM or minisom)
```python
# Alternative: minisom for more control
from minisom import MiniSom

som = MiniSom(xdim, ydim, n_features,
              sigma=1.0,
              learning_rate=0.5,
              neighborhood_function='gaussian',
              topology='hexagonal')
som.train_batch(data, num_iteration=1000)  # Batch training more stable

# Adaptive grid sizing
def optimal_grid_size(n_samples):
    """Heuristic: sqrt(5 * sqrt(n_samples))"""
    return int(np.ceil(np.sqrt(5 * np.sqrt(n_samples))))
```

### 3. Enhanced Spatial Analysis (scimap)
```python
import scimap as sm

# Neighborhood enrichment
sm.tl.spatial_count(adata, x_coordinate='X_centroid', y_coordinate='Y_centroid',
                    phenotype='merged_clusters', method='knn', knn=10)

# Spatial LDA for microenvironment identification
sm.tl.spatial_lda(adata, x_coordinate='X_centroid', y_coordinate='Y_centroid',
                  phenotype='merged_clusters', num_motifs=10)

# Cell-cell interaction analysis
sm.tl.spatial_interaction(adata, x_coordinate='X_centroid', y_coordinate='Y_centroid',
                          phenotype='merged_clusters', method='knn', knn=10)
```

### 4. ECM-Specific Features
```python
# Cell-ECM distance
from scipy.ndimage import distance_transform_edt

ecm_boundary = (ecm_label > 0).astype(int)
cell_ecm_distance = distance_transform_edt(~ecm_boundary)

# Per-cell ECM distance
cell_to_min_ecm_dist = {}
for cell_id in np.unique(marker_label)[1:]:
    cell_mask = marker_label == cell_id
    min_ecm_dist = cell_ecm_distance[cell_mask].min()
    cell_to_min_ecm_dist[cell_id] = min_ecm_dist
# cell_to_min_ecm_dist now maps each cell_id to its minimum ECM distance
```

## Final Parameters

### SOM Clustering (Recommended)
```yaml
# pyFlowSOM parameters
grid_size: 5-15 (adaptive based on sample size)
num_passes: 10
lr_start: 0.06
lr_end: 0.001
seed: 627 (or any fixed seed for reproducibility)
normalization: StandardScaler (z-score)
```

### Leiden Clustering
```yaml
resolution: 0.6-1.0 (tune based on desired granularity)
key_added: 'leiden_Res0.6'
```

### Consensus Phenotyping
```yaml
# Merge SOM + Leiden
n_final_clusters: 20-30 (hierarchical cut)
linkage_method: 'ward'
distance_metric: 'correlation'
```

### scanpy Preprocessing
```yaml
min_counts: 1
normalize_total: True
log1p: True
scale: zero_center=True
```

## Key Insights

- **Compartment-specific clustering is essential**: Cell, nuclear, and ECM features have different biological meanings. Cluster separately then integrate.
- **FuseSOM outperforms standard FlowSOM**: For imaging cytometry data specifically (Bioinformatics Advances 2023).
- **scimap has powerful spatial functions**: `spatial_lda`, `spatial_count`, `spatial_interaction` not currently used but highly valuable.
- **Label matching is critical**: When creating compartment masks, ensure labels propagate correctly to enable merging.
- **ECM watershed expansion**: Using distance transform + watershed from cell boundaries is effective for assigning ECM regions to nearest cells.
- **Texture features add value**: Haralick/GLCM features capture structural patterns especially in ECM and tissue organization.
- **3D considerations**: Literature shows 2D thin sections fragment ~95% of cells (Nature Methods 2025). Consider thicker sections if phenotype accuracy is critical.

## References

- [FlowSOM Original Paper](https://onlinelibrary.wiley.com/doi/full/10.1002/cyto.a.22625) - Van Gassen et al. 2015
- [FuseSOM - Improved Clustering](https://academic.oup.com/bioinformaticsadvances/article/3/1/vbad141/7301465) - Bioinformatics Advances 2023
- [scimap Documentation](https://scimap.xyz/) - Spatial Single-Cell Analysis Toolkit
- [SpaceANOVA](https://pubs.acs.org/doi/10.1021/acs.jproteome.3c00462) - Spatial co-occurrence analysis, J Proteome Research 2024
- [3D Multiplexed Imaging](https://www.nature.com/articles/s41592-025-02824-x) - Nature Methods 2025
- [ECM + Spatial Transcriptomics](https://www.cell.com/cell-systems/fulltext/S2405-4712(25)00094-8) - Cell Systems 2025
- [SITC Best Practices](https://pmc.ncbi.nlm.nih.gov/articles/PMC11749220/) - Multiplex IHC/IF standards, PMC 2025
- [cylinter](https://github.com/labsyspharm/cylinter) - QC filtering for multiplex microscopy
- [KODAMA](https://github.com/tund/KODAMA) - Feature extraction from high-dimensional data
