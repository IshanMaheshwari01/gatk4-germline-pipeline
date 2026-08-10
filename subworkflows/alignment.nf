include { BWA_MEM } from '../modules/bwa/main'

workflow ALIGNMENT {
    take:
    reads
    ref_dir
    
    main:
    BWA_MEM(reads, ref_dir)
    
    emit:
    bam = BWA_MEM.out.bam
}
