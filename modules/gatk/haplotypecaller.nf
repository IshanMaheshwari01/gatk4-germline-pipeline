process GATK_HAPLOTYPECALLER {
    tag "$meta.id"
    label 'process_high'
    
    publishDir "${params.outdir}/gvcf", mode: 'copy'
    
    container "${params.gatk_container}"
    
    input:
    tuple val(meta), path(bam), path(bai)
    path genome
    path genome_fai
    path genome_dict
    
    output:
    tuple val(meta), path("*.g.vcf.gz"), emit: gvcf
    tuple val(meta), path("*.g.vcf.gz.tbi"), emit: tbi
    path "versions.yml", emit: versions
    
    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gatk HaplotypeCaller \\
        -R ${genome} \\
        -I ${bam} \\
        -O ${prefix}.g.vcf.gz \\
        -ERC GVCF \\
        -L ${params.interval}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
