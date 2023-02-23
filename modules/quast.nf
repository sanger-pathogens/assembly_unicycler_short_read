process QUAST {
    label 'process_medium'
    publishDir "${params.outdir}/quast", mode: 'copy', overwrite: true

    container 'quay.io/biocontainers/quast:5.0.2--py37pl526hb5aa323_2'

    input:
    path consensus

    output:
    path "${prefix}"    , emit: results
    path '*.tsv'        , emit: tsv

    script:
    prefix = 'other_files'
    """
    quast.py \\
        --output-dir $prefix \\
        --threads $task.cpus \\
        ${consensus.join(' ')}
    ln -s ${prefix}/report.tsv
    """
}
