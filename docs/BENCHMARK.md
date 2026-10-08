# Benchmark: GIAB HG002, chromosome 20

Run date: 8 October 2026.

## Data
- Reads: HG002 NovaSeq PCR-free 35x, GRCh38 no-alt, chr20 subset (Google DeepVariant case-study data), reverted to FASTQ; 9,426,732 read pairs.
- Reference: UCSC hg38 chr20.
- BQSR known sites: 1000G phase 1 high-confidence SNPs and Mills/1000G gold-standard indels (Broad hg38 bundle), chr20.
- Truth: GIAB NISTv4.2.1 HG002 GRCh38 benchmark VCF and `noinconsistent` BED, restricted to chr20 (85,951 variants, 56.9 Mb).
- Comparison: RTG Tools 3.13 `vcfeval`, genotype-aware matching, chr20 confident regions only.

## Software
BWA 0.7.19, GATK 4.6.2.0, Nextflow 26.04.6, 2 CPUs, 7 GB RAM.

## Results

| Call set | Type | TP | FP | FN | Precision | Recall | F1 |
|---|---|---|---|---|---|---|---|
| Unfiltered | SNP | 70,936 | 923 | 426 | 0.9872 | 0.9940 | 0.9906 |
| Unfiltered | Indel | 11,099 | 113 | 128 | 0.9899 | 0.9886 | 0.9893 |
| Unfiltered | All | 82,035 | 1,036 | 554 | 0.9875 | 0.9933 | 0.9904 |
| GATK hard filters | SNP | 70,581 | 498 | 781 | 0.9930 | 0.9891 | 0.9910 |
| GATK hard filters | Indel | 11,099 | 101 | 128 | 0.9910 | 0.9886 | 0.9898 |
| GATK hard filters | All | 81,680 | 599 | 909 | 0.9927 | 0.9890 | 0.9909 |

Hard filters are the GATK-recommended thresholds (SNPs: QD<2, QUAL<30, SOR>3, FS>60, MQ<40, MQRankSum<-12.5, ReadPosRankSum<-8; indels: QD<2, QUAL<30, FS>200, ReadPosRankSum<-20), applied outside the pipeline. Ignoring genotype (vcfeval `--squash-ploidy`), unfiltered F1 is 0.9924.

## Notes
- The SNP/indel split is made by splitting truth and calls with `bcftools view -v snps` before `vcfeval`, which is close to, but not identical to, hap.py's stratification.
- HaplotypeCaller took 34 minutes on 2 threads; the remaining steps took about 12 minutes after alignment.
- Hard filtering is not yet a pipeline step.
