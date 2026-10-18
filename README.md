# GATK4 Germline Variant Calling Pipeline

[![Nextflow](https://img.shields.io/badge/nextflow-24.04-brightgreen.svg)](https://www.nextflow.io/)
[![GATK](https://img.shields.io/badge/GATK-4.5.0.0-blue.svg)](https://gatk.broadinstitute.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Nextflow (DSL2) pipeline that takes paired-end FASTQ files and produces a gVCF per sample, following the GATK Best Practices for germline short variants. Every step runs in a Docker container.

I built this to learn how a variant calling workflow is put together properly: one module per tool, config kept separate from code, and the same pipeline running on a laptop, a SLURM cluster or AWS Batch just by changing the profile.

## Steps

1. **BWA-MEM** aligns reads to the reference, adds read group tags and sorts the BAM.
2. **MarkDuplicates** flags PCR and optical duplicates (they are marked, not removed).
3. **BaseRecalibrator + ApplyBQSR** correct base quality scores using known variant sites (dbSNP and Mills indels).
4. **HaplotypeCaller** calls variants in `-ERC GVCF` mode, so the output can be joint-genotyped later.
5. **MultiQC** turns the duplication metrics into an HTML report. (For now it only reads the MarkDuplicates metrics.)

Each tool step also writes out the version it used to `versions.yml`.

## Quick start

```bash
git clone https://github.com/IshanMaheshwari01/gatk4-germline-pipeline.git
cd gatk4-germline-pipeline

# check the wiring without running any tools (this is what CI runs)
nextflow run main.nf -profile test -stub-run

# download chr21 of hg38 plus the dbSNP and Mills files, and build the indexes
bash scripts/download_references.sh

# run it
nextflow run main.nf -profile standard,docker --input samplesheet.csv
```

To keep things small I use chromosome 21 only. `scripts/download_references.sh` pulls hg38 from UCSC, cuts out chr21, and builds the FASTA, BWA and sequence dictionary indexes.

## Requirements

- Nextflow 24.04 or newer
- Docker
- Java 17
- BWA and samtools (only needed by the reference download script)

## Input

A CSV samplesheet with one row per sample:

```csv
sample,fastq_1,fastq_2
NA12878,/path/to/NA12878_R1.fastq.gz,/path/to/NA12878_R2.fastq.gz
```

## Profiles

| Profile | What it does |
|---|---|
| `standard` | Run on the local machine |
| `docker` | Use the Docker containers |
| `slurm` | Submit jobs to a SLURM cluster |
| `aws_batch` | Run on AWS Batch |
| `test` | Lower CPU and memory limits (2 CPUs, 4 GB) |

Profiles can be combined, for example `-profile test,docker`. Add `-resume` to pick up from the last step that finished.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `--input` | `test_data/samplesheet.csv` | Samplesheet |
| `--outdir` | `results` | Output folder |
| `--genome` | chr21 FASTA in `test_data/references/` | Reference genome |
| `--known_sites` | dbSNP 146 (chr21) | Known SNPs for BQSR |
| `--mills` | Mills and 1000G indels (chr21) | Known indels for BQSR |
| `--gatk_container` | `broadinstitute/gatk:4.5.0.0` | GATK image |

## Output

```
results/
├── alignment/        {sample}.sorted.bam
├── markduplicates/   {sample}.dedup.bam, .bai, .metrics.txt
├── gvcf/             {sample}.g.vcf.gz, .tbi
└── multiqc/          multiqc_report.html
```

## Repository layout

```
main.nf               main workflow
subworkflows/         alignment and BQSR subworkflows
modules/              one module per tool (bwa, gatk, multiqc)
conf/                 base, docker, slurm and aws_batch configs
scripts/              reference download script
test_data/            samplesheet for the test run
```

## What's missing

- Joint genotyping (GenomicsDBImport and GenotypeGVCFs). Right now the pipeline stops at per-sample gVCFs.
- Variant filtering (VQSR or hard filters).
- More QC in the MultiQC report, for example samtools stats and the BQSR tables.
- A small test FASTQ set committed to the repo, so the full run (not just the stub run) can be tested in CI.
- Later on I'd like to add somatic calling with Mutect2.

## Acknowledgements

GATK and the Best Practices workflows are from the Broad Institute. The module layout is loosely based on nf-core.

## License

MIT
