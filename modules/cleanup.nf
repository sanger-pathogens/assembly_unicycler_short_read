process CLEANUP_SPADES_OUTPUT {
    /**
    * Cleanup unused output
    */

    input:
         tuple val(meta), path(workdir)
        
    script:
        """
        # Remove intermediary spades assembly folders
        unicycler_work_dir=\$(cat $workdir)
        cd \$unicycler_work_dir
        rm -rf unicycler/spades_assembly
        """
}
