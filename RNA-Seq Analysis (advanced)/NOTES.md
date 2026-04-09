# Caki-1 Bulk RNA-Seq: Physiological Hypoxia vs. Chemical Mimicry

This project provides a comparative transcriptomic analysis of human Caki-1 cells (renal cell carcinoma) under two conditions: **Physiological Hypoxia** (low oxygen) and **Chemical Mimicry** (Cobalt Chloride treatment). The main goal is to evaluate whether CoCl2 effectively replicates the biological response to real hypoxia.

---

## Project Overview
* **Data Source:** RNA-seq data from NCBI BioProject (recount2 accession: `SRP066934`).
* **Biological Model:** Caki-1 cell line.
* **Key Question:** Does Chemical Hypoxia (CoCl2) trigger the same transcriptomic program as Real Hypoxia?

## Tech Stack
* **Language:** R (RMarkdown)
* **Analysis:** `DESeq2` for differential expression.
* **Pathway Analysis:** `clusterProfiler` (GSEA) with KEGG database.
* **Visualization:** `ggplot2`, `pheatmap`, `EnhancedVolcano`, `patchwork`.

## Key Findings
1. **Partial Overlap:** Both models successfully induce core hypoxia markers like *HMOX1* and *DDIT4*.
2. **Metabolic Divergence:** Real Hypoxia triggers a coordinated adaptive shift in **Glycolysis** and **Propanoate metabolism**, which is largely absent or suppressed in the CoCl2 model.
3. **Chemical Toxicity:** CoCl2 induces unique stress-response pathways related to DNA damage and amino acid degradation, suggesting a "chemical footprint" that differs from physiological low-oxygen conditions.

## Interactive Analysis Report
Click the link below to view the full interactive research report:

> [**View Full Interactive Report**](https://lmvl12.github.io/skill-assessments/RNA-Seq%20Analysis%20(advanced)/Caki-1_rna_seq.html)
