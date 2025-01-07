def buildSpadesOptions() {
    def options = []
    if (params.isolate) options << "--isolate "
    if (params.careful) options << "--careful "
    if (params.lock_phred) options << "--phred-offset 33"
    if (params.cutoff_auto) options << "--cov-cutoff auto"
    if (params.spades_options) options << "${params.spades_options}" //if there are any given add them
    return options ? "--spades_options '${options.join(' ')}'" : "" //return options or nothing if no options given
}

process UNICYCLER {
    tag "${meta.ID}"
    label 'cpu_8'
    label 'mem_16'
    label 'time_12'
    publishDir "${params.outdir}/${meta.ID}/unicycler", mode: 'copy', overwrite: true

    container "quay.io/sangerpathogens/unicycler:0.5.1-vanillaspades"

    input:
    tuple val(meta), path(read_1), path(read_2)

    output:
    tuple val(meta), path('*.assembly.fa')  , emit: assembly
    tuple val(meta), path('*.assembly.gfa') , emit: gfa
    tuple val(meta), path('*.log')          , emit: log
    tuple val(meta), val("${task.workDir}") , emit: workdir

    script:
    def spades_options = buildSpadesOptions()
    def mode = params.mode == "" ? "normal" : params.mode
    """
    unicycler \\
        --threads ${task.cpus} \\
        -1 ${read_1} -2 ${read_2} \\
        --mode ${mode} \\
        --out unicycler \\
        ${spades_options}

    mv unicycler/assembly.fasta ${meta.ID}.assembly.fa
    mv unicycler/assembly.gfa ${meta.ID}.assembly.gfa
    mv unicycler/unicycler.log ${meta.ID}.unicycler.log
    """
}

