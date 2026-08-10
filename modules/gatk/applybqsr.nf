process GATK_APPLYBQSR {
    tag "$meta.id"
    label 'process_medium'
    
    container "${params.gatk_container}"
    
    input:
    tuple val(meta), path(bam), path(bai), path(recal_table)
    path genome
    path genome_fai
    path genome_dict
    
    output:
    tuple val(meta), path("*.recal.bam"), emit: bam
    tuple val(meta), path("*.recal.bai"), emit: bai
    path "versions.yml", emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gatk ApplyBQSR \\
        -R ${genome} \\
        -I ${bam} \\
        --bqsr-recal-file ${recal_table} \\
        -O ${prefix}.recal.bam \\
        --create-output-bam-index true
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
