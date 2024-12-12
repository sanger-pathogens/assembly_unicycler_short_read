#!/usr/bin/env nextflow

/*
========================================================================================
    HELP
========================================================================================
*/

def printHelp() {
    log.info """
    Usage:
        nextflow run main.nf

    Options:
        --manifest                   Manifest containing per-sample paths to .fastq.gz files (mandatory)
        --outdir                     Specify output directory [default: ./results] (optional)
        --help                       Print this help message (optional)
    """.stripIndent()
}

if (params.help) {
    printHelp()
    exit(0)
}

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULES
//
include { UNICYCLER           } from './modules/unicycler'
include { QUAST; SUMMARY      } from './modules/quast'

//
// SUBWORKFLOWS
//

include { MIXED_INPUT         } from './assorted-sub-workflows/combined_input/mixed_input.nf'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    MIXED_INPUT
    | UNICYCLER

    //run quast on all assembiles
    QUAST(UNICYCLER.out.assembly)

    QUAST.out.quast_out
    | collect
    | SUMMARY
}

/*
========================================================================================
    THE END
========================================================================================
*/
