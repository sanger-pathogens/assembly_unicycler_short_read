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
        --input                      Manifest containing per-sample paths to .fastq.gz files (mandatory)
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
include { UNICYCLER } from './modules/unicycler'
include { QUAST } from './modules/quast'

//
// SUBWORKFLOWS
//
include { INPUT_CHECK } from './subworkflows/input_check'

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

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    ch_input = file(params.input)
    INPUT_CHECK (
        ch_input
    )
    INPUT_CHECK.out.shortreads.dump(tag: 'shortreads')
        .map{ meta,reads -> tuple(meta,reads) }
        .dump(tag: 'ch_for_assembly')
        .set { ch_for_assembly }

    //
    // ASSEMBLY: Unicycler
    //
    UNICYCLER (
        ch_for_assembly
    )
    UNICYCLER.out.scaffolds.dump(tag: 'unicycler').set { ch_assembly }

    //
    // ASSEMBLY QC: QUAST
    //
    ch_assembly
        .map { meta, fasta -> fasta }
        .collect()
        .set { ch_to_quast }
    QUAST (
        ch_to_quast
    )
}

/*
========================================================================================
    THE END
========================================================================================
*/
