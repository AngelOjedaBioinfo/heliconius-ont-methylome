# DNA Methylation Analysis Pipeline for *Heliconius erato lativitta* (v1.1)

Bioinformatic pipeline for identification and characterization of DNA modifications
(**5mC** and **5hmC**) in *Heliconius erato lativitta* brain tissue. The pipeline
processed ~90 million unique CpG sites, evaluating the effect of the DNMT inhibitor
**RG108** on the epigenetic landscape using Oxford Nanopore Technology (ONT) sequencing.

> **Associated thesis:** Análisis bioinformático del metiloma cerebral en *Heliconius
> erato lativitta* mediante ONT: Efectos del RG108 — Ángel Ojeda Montesdeoca,
> Máster en Bioinformática, VIU, 2026.

---

## 1. Tool Versions

All versions validated in this study:

| Tool | Version | Purpose |
|---|---|---|
| modkit | v0.5.0 (ONT) | 5mC/5hmC calling from modBAM |
| samtools | v1.16.1 | BAM handling and QC |
| minimap2 | v2.24 | Alignment (external step) |
| bedtools | v2.30.0 | Genomic arithmetic |
| R | v4.2.2 | Statistical analysis |
| DSS | v2.46.0 (Bioconductor) | DMR detection |
| ggplot2 | v3.5 | Visualization |
| patchwork | — | Figure composition |

---

## 2. Key Methodological Decisions

### 2.1 General Pipeline

Full workflow: Dorado duplex basecalling → modkit pileup → coverage filtering →
bedtools intersect → DSS → CAT GFF3 annotation → candidate genes.

![Pipeline General](assets/figures/A_pipeline_general.png)

### 2.2 Probabilistic Threshold Calibration

Default modkit threshold (0.5) produces global methylation rates incompatible with
the 1–3% reported for Lepidoptera. An empirical threshold was derived from the 10th
percentile (p10) of the modification probability distribution: **p10 = 0.793**,
applied symmetrically to 5mC and 5hmC.

![Decisión Umbral](assets/figures/B_decision_umbral.png)

### 2.3 Dispersion Estimation in DSS

Experimental design: n=1 pooled per condition (no biological replicates).
`smoothing=TRUE` (Park & Wu, 2016) is mandatory — DSS rejects `smoothing=FALSE`
for replicate-free designs with an explicit error.

![Decisión Dispersión](assets/figures/C_decision_dispersion.png)

### 2.4 Genomic Context Classification

CpG sites categorized by hierarchical intersection with `Hlat.v1.1.CAT.gff3`.
Introns identified by exclusion (sites in genes minus sites in exons).

![Clasificación Contexto](assets/figures/D_clasificacion_contexto.png)

### 2.5 Coverage Normalization (Downsampling)

The treatment BAM (52.1×) was downsampled to match control coverage (33.5×)
using a fraction of 0.643 (seed 42 for reproducibility):

```bash
samtools view -s 42.643 -b -@ 8 Hlat.T.ONT.modmapped.bam > Hlat.T.ONT.modmapped.ds643.bam
samtools index -@ 8 Hlat.T.ONT.modmapped.ds643.bam
```

Result: 4,000,504 primary reads (from 6,222,642), mapping rate unchanged at 73.41%.

---

## 3. Scripts

### Bash (core processing)

| Script | Description |
|---|---|
| `config.sh` | Central configuration — all paths and parameters |
| `samtools_stats.sh` | QC metrics from modBAM files |
| `modkit_pileup.sh` | BEDMethyl generation (5mC + 5hmC simultaneously) |
| `filter_coverage.sh` | Filter sites by minimum coverage (parametrized) |
| `common_sites.sh` | Intersect control and treatment (shared sites only) |
| `prepare_dss_input.sh` | Convert BEDMethyl to DSS format (chr, pos, N, X) |
| `generate_bedgraphs.sh` | bedGraph tracks for IGV visualization |
| `genome_sizes.sh` | Chromosome length table for DMR normalization |
| `run_pipeline_core.sh` | Main orchestrator |

### R (analysis and visualization)

| Script | Description |
|---|---|
| `dss_analysis.R` | DML and DMR detection (beta-binomial, smoothing) |
| `genomic_context.R` | Functional annotation (exons, introns, intergenic) |
| `dmr_visualization.R` | Per-gene methylation profiles with exon tracks |

---

## 4. Usage

### Setup

```bash
# Recreate environment
mamba env create -f bioinfo.yml
conda activate bioinfo

# Configure paths
nano scripts/bash/config.sh   # set BAM paths, reference, parameters
```

### Run full pipeline

```bash
bash scripts/bash/run_pipeline_core.sh
```

### Run individual steps with custom parameters

```bash
# Filter with default coverage from config.sh
bash scripts/bash/filter_coverage.sh

# Filter with custom coverage threshold
bash scripts/bash/filter_coverage.sh 20
```

---

## 5. Institutions and Credits

- **Author:** Ángel Ojeda Montesdeoca — Universidad Regional Amazónica Ikiam
- **Supervisor:** Pablo Marín García, PhD — Universidad Internacional de Valencia (VIU)
- **External collaborator:** Caroline Bacquet, PhD — Jiggins Group, Cambridge/Sanger
  (functional annotation CAT GFF3)

---

## 6. License

MIT License — see [LICENSE](LICENSE) for details.