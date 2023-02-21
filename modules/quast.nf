process QUAST {
    label 'process_medium'
    publishDir "${params.outdir}/quast", mode: 'copy', overwrite: true

    container 'quay.io/biocontainers/quast:5.0.2--py37pl526hb5aa323_2'

    input:
    path consensus
    path fasta
    path gff
    val use_fasta
    val use_gff

    output:
    path "${prefix}"    , emit: results
    path '*.tsv'        , emit: tsv

    script:
    prefix        = 'other_files'
    def features  = use_gff ? "--features $gff" : ''
    def reference = use_fasta ? "-r $fasta" : ''
    """
    quast.py \\
        --output-dir $prefix \\
        $reference \\
        $features \\
        --threads $task.cpus \\
        ${consensus.join(' ')}
    ln -s ${prefix}/report.tsv
    """
}
