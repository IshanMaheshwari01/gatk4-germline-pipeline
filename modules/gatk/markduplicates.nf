process GATK_MARKDUPLICATES {
    tag "$meta.id"
    label 'process_medium'
    
    publishDir "${params.outdir}/markduplicates", mode: params.publish_dir_mode
    
    container "${params.gatk_container}"
    
    input:
    tuple val(meta), path(bam)
    
    output:
    tuple val(meta), path("*.dedup.bam"), emit: bam
    tuple val(meta), path("*.dedup.bai"), emit: bai
    tuple val(meta), path("*.metrics.txt"), emit: metrics
    path "versions.yml", emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gatk MarkDuplicates \\
        -I ${bam} \\
        -O ${prefix}.dedup.bam \\
        -M ${prefix}.metrics.txt \\
        --REMOVE_DUPLICATES false \\
        --CREATE_INDEX true
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
