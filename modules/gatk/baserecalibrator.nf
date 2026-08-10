process GATK_BASERECALIBRATOR {
    tag "$meta.id"
    label 'process_medium'
    
    container "${params.gatk_container}"
    
    input:
    tuple val(meta), path(bam), path(bai)
    path genome
    path genome_fai
    path genome_dict
    path known_sites
    path known_sites_tbi
    path mills
    path mills_tbi
    
    output:
    tuple val(meta), path("*.recal.table"), emit: table
    path "versions.yml", emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gatk BaseRecalibrator \\
        -I ${bam} \\
        -R ${genome} \\
        --known-sites ${known_sites} \\
        --known-sites ${mills} \\
        -O ${prefix}.recal.table
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
