process BWA_MEM {
    tag "$meta.id"
    label 'process_high'
    
    publishDir "${params.outdir}/alignment", mode: 'copy'
    
    input:
    tuple val(meta), path(reads)
    path ref_dir
    
    output:
    tuple val(meta), path("*.sorted.bam"), emit: bam
    path "versions.yml"                  , emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def read_group = "\"@RG\\tID:${meta.id}\\tSM:${meta.id}\\tPL:ILLUMINA\\tLB:${meta.id}\\tPU:1\""
    def ref_base = "${ref_dir}/Homo_sapiens_assembly38.chr21.fa"
    """
    bwa mem \\
        -R ${read_group} \\
        -t ${task.cpus} \\
        ${ref_base} \\
        ${reads[0]} ${reads[1]} \\
        | samtools sort -@ ${task.cpus} -O bam -o ${prefix}.sorted.bam -
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
