include { GATK_MARKDUPLICATES } from '../modules/gatk/markduplicates'
include { GATK_BASERECALIBRATOR } from '../modules/gatk/baserecalibrator'
include { GATK_APPLYBQSR } from '../modules/gatk/applybqsr'

workflow BQSR {
    take:
    bam
    genome
    genome_fai
    genome_dict
    known_sites
    known_sites_tbi
    mills
    mills_tbi
    
    main:
    GATK_MARKDUPLICATES(bam)
    
    GATK_BASERECALIBRATOR(
        GATK_MARKDUPLICATES.out.bam.join(GATK_MARKDUPLICATES.out.bai, by: [0]),
        genome, genome_fai, genome_dict,
        known_sites, known_sites_tbi,
        mills, mills_tbi
    )
    
    GATK_APPLYBQSR(
        GATK_MARKDUPLICATES.out.bam
            .join(GATK_MARKDUPLICATES.out.bai, by: [0])
            .join(GATK_BASERECALIBRATOR.out.table, by: [0]),
        genome, genome_fai, genome_dict
    )
    
    emit:
    bam     = GATK_APPLYBQSR.out.bam
    bai     = GATK_APPLYBQSR.out.bai
    metrics = GATK_MARKDUPLICATES.out.metrics
}
