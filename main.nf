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
include { validate_parameters } from './modules/helper_functions'
include { UNICYCLER           } from './modules/unicycler'
include { QUAST; SUMMARY      } from './modules/quast'

//
// SUBWORKFLOWS
//
include { INPUT_CHECK         } from './subworkflows/input_check'

/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

validate_parameters()

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    //parse manifest and run unicycler
    ch_input = file(params.manifest)
    INPUT_CHECK(ch_input)
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
