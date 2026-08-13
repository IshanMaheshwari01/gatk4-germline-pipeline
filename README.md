# GATK4 Germline Variant Calling Pipeline

[![Nextflow](https://img.shields.io/badge/nextflow-24.04.6-brightgreen.svg)](https://www.nextflow.io/)
[![GATK](https://img.shields.io/badge/GATK-4.5.0.0-blue.svg)](https://gatk.broadinstitute.org/)
[![Docker](https://img.shields.io/badge/docker-20.10-blue.svg)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A production-grade, containerized germline variant calling pipeline following GATK Best Practices, built with Nextflow and Docker.

## Overview

This pipeline performs end-to-end germline short variant discovery from raw paired-end FASTQ files to genomic VCF (gVCF) outputs.

## Pipeline Steps

1. **BWA-MEM Alignment** - Aligns paired-end reads to reference genome
2. **MarkDuplicates** - Identifies and marks PCR duplicates
3. **BQSR** - Base Quality Score Recalibration
4. **HaplotypeCaller** - Variant calling with gVCF output
5. **MultiQC** - Aggregate QC reporting

## Quick Start

```bash
git clone https://github.com/IshanMaheshwari01/gatk4-germline-pipeline.git
cd gatk4-germline-pipeline
bash scripts/download_references.sh
nextflow run main.nf -profile test,docker
```

## License

MIT License - see [LICENSE](LICENSE) file.

## Contact

- GitHub: [@IshanMaheshwari01](https://github.com/IshanMaheshwari01)
