process CLEANUP_SPADES_OUTPUT {
    /**
    * Cleanup unused output
    */

    input:
         tuple val(meta), path(workdir)
        
    script:
        """
        # Remove intermediary spades assembly folders
        cd $workdir/
        rm -rf unicycler/spades_assembly
        """
}
