process UNICYCLER {
    tag "$meta.id"
    label 'cpu_8'
    label 'mem_16'
    label 'time_12'
    publishDir "${params.outdir}/unicycler", mode: 'copy', overwrite: true

    container "quay.io/biocontainers/unicycler:0.4.8--py38h8162308_3"

    input:
    tuple val(meta), file(reads)

    output:
    tuple val(meta), path('*.assembly.fa')   , emit: assembly
    tuple val(meta), path('*.assembly.gfa') , emit: gfa
    tuple val(meta), path('*.log')          , emit: log

    script:
    def software    = 'unicycler'
    def prefix      = "${meta.id}"
    def input_reads = "-1 ${reads[0]} -2 ${reads[1]}"
    def lock_phred = params.lock_phred ? '--spades_args "--phred-offset 33"' : ''
    """
    unicycler \\
        --threads $task.cpus \\
        $input_reads \\
        ${lock_phred} \\
        --out ./

    mv assembly.fasta ${prefix}.assembly.fa
    mv assembly.gfa ${prefix}.assembly.gfa
    mv unicycler.log ${prefix}.unicycler.log
    """
}