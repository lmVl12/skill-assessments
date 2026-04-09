# Single-Cell Transcriptomic Profiling of Human Cutaneous Melanoma

## Project Overview
This repository contains a comprehensive single-cell RNA-sequencing (scRNA-seq) analysis pipeline for human Dissociated Tumor Cells (DTCs) from a melanoma specimen. 
The study focuses on resolving intratumoral heterogeneity, identifying immune cell states, and mapping the complex signaling crosstalk within the tumor microenvironment (TME).

## Biological Context
Cutaneous melanoma is characterized by high genetic and phenotypic plasticity. This analysis aims to:
* **Deconvolute the TME:** Distinguish between malignant melanocytes, infiltrating lymphocytes (T/B/NK), and myeloid populations.
* **Map Cellular Dynamics:** Reconstruct developmental trajectories and metabolic transitions (e.g., Naive-to-Memory B cells, T-cell activation).
* **Decode Signaling Hubs:** Identify key intercellular communication axes (e.g., **MIF**, **MHC-I**, **SPP1**) that facilitate immune evasion and tumor progression.

## Data Source
* **Dataset:** 10k Human DTC Melanoma (Chromium GEM-X 5' v3).
* **Provider:** [10x Genomics (2024)](https://www.10xgenomics.com).
* **Sequencing:** Illumina NovaSeq 6000 (~70,000 read pairs per cell).

## Technical Pipeline
The analysis is implemented in **R (RMarkdown)** using a bioinformatics stack:
1. **Preprocessing & QC:** Stringent filtering of low-quality cells based on UMI counts, gene detection (500–6000), and mitochondrial content (<10%).
2. **Normalization:** Global-scaling (`LogNormalize`) and identification of the top 2,000 highly variable features.
3. **Dimensionality Reduction:** PCA-based linear reduction followed by **UMAP** for clustering and **PHATE/MAGIC** for manifold learning of continuous cell states.
4. **Annotation:** Dual-strategy approach using manual marker validation (e.g., *MLANA*, *CD8A*, *IGHG3*) and automated reference mapping via `SingleR` (Monaco & Blueprint/Encode databases).
5. **Functional Genomics:** Pathway enrichment analysis using `Enrichr` (KEGG, MSigDB Hallmark) and cell-cell communication modeling via `CellChat`.

## Repository Structure
* `analysis.Rmd` — Main analysis script with integrated visualization and interpretation.
* `processed_data/` — Local cache for `.rds` objects (intermediate Seurat, SingleR, and CellChat results).
* `NOTES` — Technical log and cluster-specific biological observations.
* `Cluster_Markers_manual.pdf` — Supplementary diagnostic plots for cluster verification.
* `Signaling_Heatmaps_Combined.png` — Global overview of outgoing/incoming cellular communication.

## Installation & Usage
### Prerequisites
* **R** (>= 4.2)
* **Python** (Required for PHATE/MAGIC via `reticulate`)
* **Required R Packages:** `Seurat`, `CellChat`, `monocle3`, `SingleR`, `phateR`, `tidyverse`, `patchwork`.
