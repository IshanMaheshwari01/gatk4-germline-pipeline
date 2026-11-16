process MULTIQC {
    label 'process_low'
    
    publishDir "${params.outdir}/multiqc", mode: 'copy'
    
    container "ewels/multiqc:latest"
    
    input:
    path('*')
    
    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data"       , emit: data
    
    script:
    """
    multiqc .
    """

    stub:
    """
    touch multiqc_report.html
    mkdir multiqc_data
    touch multiqc_data/multiqc_data.json
    """
}
