process CLEANUP_SPADES_OUTPUT {
    tag "${meta.ID}"
    label 'cpu_1'
    label 'mem_1'
    label 'time_30m'
/**
    * Cleanup unused output
    */

    input:
         tuple val(meta), path(workdir)
        
    script:
        """
        # Remove intermediary spades assembly folders
        unicycler_workdir=\$(cat ${workdir})
        cd \$unicycler_workdir
        rm -rf unicycler/spades_assembly
        """
}
