process GATK_GENOTYPEGVCFS {
    tag "$meta.id"
    label 'process_medium'

    publishDir "${params.outdir}/vcf", mode: 'copy'

    container "${params.gatk_container}"

    input:
    tuple val(meta), path(gvcf), path(tbi)
    path genome
    path genome_fai
    path genome_dict

    output:
    tuple val(meta), path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: vcf
    path "versions.yml", emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gatk GenotypeGVCFs \\
        -R ${genome} \\
        -V ${gvcf} \\
        -L ${params.interval} \\
        -O ${prefix}.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
