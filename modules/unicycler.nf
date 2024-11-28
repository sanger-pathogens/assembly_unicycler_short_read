def buildSpadesOptions() {
    def options = []
    if (params.lock_phred) options << "--phred-offset 33"
    if (params.cutoff_auto) options << "--cov-cutoff auto"
    if (params.spades_options) options << "${params.spades_options}" //if there are any given add them
    return options ? "--spades_options '${options.join(' ')}'" : "" //return options or nothing if no options given
}

def getModeOption(mode) {
    //to prevent big ternary operator have a seperate switchcase for the given mode
    switch (mode) {
        case 'conservative': return '--mode conservative'
        case 'normal': return '--mode normal'
        case 'bold': return '--mode bold'
        default: return ''
    }
}

process UNICYCLER {
    tag "${meta.ID}"
    label 'cpu_8'
    label 'mem_16'
    label 'time_12'
    publishDir "${params.outdir}/unicycler", mode: 'copy', overwrite: true

    container "quay.io/biocontainers/unicycler:0.5.1--py311h6eedab3_2"

    input:
    tuple val(meta), path(read_1), path(read_2)

    output:
    tuple val(meta), path('*.assembly.fa')   , emit: assembly
    tuple val(meta), path('*.assembly.gfa') , emit: gfa
    tuple val(meta), path('*.log')          , emit: log

    script:
    def spades_options = buildSpadesOptions()
    def mode = getModeOption(params.mode)
    """
    unicycler \\
        --threads ${task.cpus} \\
        -1 ${read_1} -2 ${read_2} \\
        ${mode} \\
        --out unicycler \\
        ${spades_options}

    mv unicycler/assembly.fasta ${meta.ID}.assembly.fa
    mv unicycler/assembly.gfa ${meta.ID}.assembly.gfa
    mv unicycler/unicycler.log ${meta.ID}.unicycler.log
    """
}

