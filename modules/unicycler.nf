process UNICYCLER {
    tag "$meta.id"
    label 'cpu_8'
    label 'mem_16'
    label 'time_12'
    publishDir "${params.outdir}/unicycler", mode: 'copy', overwrite: true

    container "quay.io/sangerpathogens/unicycler:0.5.1-vanillaspades"

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
    def spades_options = ""
        if (params.isolate) spades_options += "--isolate "
        if (params.careful) spades_options += "--careful "
        if (params.lock_phred) spades_options += "--phred-offset 33 "
        if (params.cutoff_auto) spades_options += "--cov-cutoff auto "
    def mode = params.mode == "" ? "normal" : params.mode
    def full_spades_options = spades_options == "" ? "" : "--spades_options \"${spades_options.trim()}\""

    """
    unicycler \\
        --threads $task.cpus \\
        $input_reads \\
        $full_spades_options \\
        --mode $mode \\
        --out ./
    mv assembly.fasta ${prefix}.assembly.fa
    mv assembly.gfa ${prefix}.assembly.gfa
    mv unicycler.log ${prefix}.unicycler.log
    """
}

