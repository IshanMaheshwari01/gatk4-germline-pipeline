# GATK4 Germline Variant Calling Pipeline

[![Nextflow](https://img.shields.io/badge/nextflow-24.04.6-brightgreen.svg)](https://www.nextflow.io/)
[![GATK](https://img.shields.io/badge/GATK-4.5.0.0-blue.svg)](https://gatk.broadinstitute.org/)
[![Docker](https://img.shields.io/badge/docker-20.10-blue.svg)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-grade, containerized germline variant calling pipeline following GATK Best Practices, built with Nextflow and Docker.

## Overview

This pipeline performs end-to-end germline short variant discovery from raw paired-end FASTQ files to genomic VCF (gVCF) outputs:

- **Alignment** with BWA-MEM
- **Duplicate Marking** with GATK MarkDuplicates
- **Base Quality Score Recalibration (BQSR)** with GATK BaseRecalibrator + ApplyBQSR
- **Variant Calling** with GATK HaplotypeCaller (ERC GVCF mode)
- **QC Reporting** with MultiQC

The pipeline is designed to be portable across local machines, HPC clusters (SLURM), and cloud platforms (AWS Batch).

## Features

- **Reproducible**: Docker containers ensure identical environments everywhere
- **Portable**: Run locally, on SLURM, or AWS Batch with profile switches
- **Modular**: Nextflow DSL2 modules for easy extension and maintenance
- **Best Practices**: Follows GATK4 germline variant discovery guidelines
- **QC Integration**: Automatic MultiQC report generation
- **Version Tracking**: Every process emits tool versions for full provenance

## Quick Start

```bash
# Clone the repository
git clone https://github.com/IshanMaheshwari01/gatk4-germline-pipeline.git
cd gatk4-germline-pipeline

# Download reference data
bash scripts/download_references.sh

# Run test pipeline
nextflow run main.nf -profile test,docker
```

## Prerequisites

| Tool                                   | Version   | Purpose                |
| -------------------------------------- | --------- | ---------------------- |
| [Nextflow](https://www.nextflow.io/)   | >= 24.04  | Workflow orchestration |
| [Docker](https://www.docker.com/)      | >= 20.10  | Containerization       |
| [BWA](http://bio-bwa.sourceforge.net/) | >= 0.7.17 | Sequence alignment     |
| [Samtools](http://www.htslib.org/)     | >= 1.15   | BAM manipulation       |
| Java                                   | >= 17     | GATK runtime           |


## Installation

```bash
# Install Nextflow
wget -qO- https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker $USER

# Install BWA and Samtools
sudo apt install -y bwa samtools
```

## Usage

Input: Samplesheet
Create a CSV file with your samples:

```csv
sample,fastq_1,fastq_2
NA12878,/path/to/NA12878_R1.fastq.gz,/path/to/NA12878_R2.fastq.gz
```

## Execution Profiles

| Profile     | Description                   |
| ----------- | ----------------------------- |
| `standard`  | Local execution               |
| `docker`    | Enable Docker containers      |
| `slurm`     | SLURM HPC cluster             |
| `aws_batch` | AWS Batch cloud execution     |
| `test`      | Reduced resources for testing |

Combine profiles: nextflow run main.nf -profile test,docker

## Example Commands

```bash
# Local execution with Docker
nextflow run main.nf -profile standard,docker --input samplesheet.csv

# SLURM cluster
nextflow run main.nf -profile slurm --input samplesheet.csv

# AWS Batch
nextflow run main.nf -profile aws_batch --input samplesheet.csv

# Resume from failed step
nextflow run main.nf -profile standard,docker -resume
```

## Pipeline Steps

1. BWA-MEM Alignment

- Aligns paired-end reads to the reference genome
- Attaches read group metadata (RG tags)
- Outputs coordinate-sorted BAM

2. MarkDuplicates

- Identifies PCR/optical duplicates
- Marks duplicates without removing them
- Generates duplication metrics

3. Base Quality Score Recalibration (BQSR)

- BaseRecalibrator: Learns sequencer error patterns using known variant sites
- ApplyBQSR: Adjusts base quality scores for downstream accuracy

4. HaplotypeCaller

- Performs local de novo assembly around variant sites
- Outputs genomic VCF (gVCF) with genotype likelihoods
- Uses ERC GVCF mode for joint genotyping compatibility

5. MultiQC

- Aggregates QC metrics from all steps
- Generates interactive HTML report

## Parameters

| Parameter          | Default                       | Description               |
| ------------------ | ----------------------------- | ------------------------- |
| `--input`          | `test_data/samplesheet.csv`   | Samplesheet CSV path      |
| `--outdir`         | `results`                     | Output directory          |
| `--genome`         | `test_data/references/...`    | Reference genome FASTA    |
| `--known_sites`    | `test_data/references/...`    | dbSNP VCF for BQSR        |
| `--mills`          | `test_data/references/...`    | Mills indels VCF for BQSR |
| `--gatk_container` | `broadinstitute/gatk:4.5.0.0` | GATK Docker image         |

## Outputs

```plain
results/
├── alignment/
│   └── {sample}.sorted.bam          # Aligned, sorted BAM
├── markduplicates/
│   ├── {sample}.dedup.bam            # Deduplicated BAM
│   ├── {sample}.dedup.bai            # BAM index
│   └── {sample}.metrics.txt         # Duplication metrics
├── bqsr/
│   ├── {sample}.recal.table         # BQSR recalibration table
│   └── {sample}.recal.bam           # BQSR-corrected BAM
├── gvcf/
│   ├── {sample}.g.vcf.gz            # Genomic VCF
│   └── {sample}.g.vcf.gz.tbi      # VCF index
└── multiqc/
    ├── multiqc_report.html          # Aggregate QC report
    └── multiqc_data/                # Raw QC data
```

## System Requirements

*Minimum (for testing)*

- CPU: 2 cores
- RAM: 4 GB
- Disk: 10 GB
- OS: Linux/macOS (Windows via WSL2)

*Recommended (for real data)*

- CPU: 8+ cores
- RAM: 16+ GB
- Disk: 100+ GB

## Testing

```bash
# Syntax check (dry run)
nextflow run main.nf -profile test -stub-run

# Full test with synthetic data
nextflow run main.nf -profile test,docker
```

## Roadmap

- [x] BWA-MEM alignment
- [x] MarkDuplicates
- [x] BQSR (BaseRecalibrator + ApplyBQSR)
- [x] HaplotypeCaller (gVCF output)
- [x] MultiQC reporting
- [x] Docker containerization
- [x] SLURM profile
- [x] AWS Batch profile
- [ ] Joint Genotyping (GenomicsDBImport + GenotypeGVCFs)
- [ ] Variant Quality Score Recalibration (VQSR)
- [ ] Somatic variant calling (Mutect2)
- [ ] Structural variant detection (Manta)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Broad Institute for GATK and Best Practices
- Nextflow community for workflow framework
- nf-core for pipeline design inspiration

## Contact

Ishan Maheshwari

- GitHub: @IshanMaheshwari01
