#!/usr/bin/env nextflow

include { BWA_MEM } from './modules/bwa/main'
include { BQSR } from './subworkflows/bqsr'
include { GATK_HAPLOTYPECALLER } from './modules/gatk/haplotypecaller'
include { GATK_GENOTYPEGVCFS } from './modules/gatk/genotypegvcfs'
include { MULTIQC } from './modules/multiqc/main'

workflow {
    // Parse samplesheet
    Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> 
            def meta = [id: row.sample]
            def reads = [file(row.fastq_1), file(row.fastq_2)]
            [meta, reads]
        }
        .set { ch_reads }
    
    // Reference channels
    ch_genome      = file(params.genome)
    ch_genome_fai  = file("${params.genome}.fai")
    ch_genome_dict = file("${params.genome}".replaceAll('.fa$', '.dict'))
    ch_known       = file(params.known_sites)
    ch_known_tbi   = file("${params.known_sites}.tbi")
    ch_mills       = file(params.mills)
    ch_mills_tbi   = file("${params.mills}.tbi")
    ch_ref_dir     = ch_genome.parent
    
    // Run pipeline
    BWA_MEM(ch_reads, ch_ref_dir)
    
    BQSR(
        BWA_MEM.out.bam,
        ch_genome, ch_genome_fai, ch_genome_dict,
        ch_known, ch_known_tbi,
        ch_mills, ch_mills_tbi
    )
    
    GATK_HAPLOTYPECALLER(
        BQSR.out.bam.join(BQSR.out.bai, by: [0]),
        ch_genome, ch_genome_fai, ch_genome_dict
    )
    
    GATK_GENOTYPEGVCFS(
        GATK_HAPLOTYPECALLER.out.gvcf.join(GATK_HAPLOTYPECALLER.out.tbi, by: [0]),
        ch_genome, ch_genome_fai, ch_genome_dict
    )

    // MultiQC: collect metrics from MarkDuplicates
    MULTIQC(
        BQSR.out.metrics.map { meta, metrics -> metrics }.collect()
    )
    
    // Print final output
    GATK_HAPLOTYPECALLER.out.gvcf.view { meta, gvcf -> "Sample: ${meta.id}, GVCF: ${gvcf}" }
}
