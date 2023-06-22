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
    VALIDATE INPUTS
========================================================================================
*/

def validate_path_param(
    param_option, 
    param, 
    type="file", 
    mandatory=true) {
        valid_types=["file", "directory"]
        if (!valid_types.any { it == type }) {
                log.error("Invalid type '${type}'. Possibilities are ${valid_types}.")
                return 1
        }
        param_name = (param_option - "--").replaceAll("_", " ")
        if (param) {
            def file_param = file(param)
            if (!file_param.exists()) {
                log.error("The given ${param_name} '${param}' does not exist.")
                return 1
            } else if (
                (type == "file" && !file_param.isFile())
                ||
                (type == "directory" && !file_param.isDirectory())
            ) {
                log.error("The given ${param_name} '${param}' is not a ${type}.")
                return 1
            }
        } else if (mandatory) {
            log.error("No ${param_name} specified. Please specify one using the ${param_option} option.")
            return 1
        }
        return 0
    }

def validate_parameters() {
    def errors = 0

    errors += validate_path_param("--input", params.input)

    if (errors > 0) {
        log.error(String.format("%d errors detected", errors))
        exit 1
    }
}

validate_parameters()

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULES
//
include { UNICYCLER } from './modules/unicycler'
include { QUAST } from './modules/quast'

//
// SUBWORKFLOWS
//
include { INPUT_CHECK } from './subworkflows/input_check'

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
    UNICYCLER.out.assembly.dump(tag: 'unicycler').set { ch_assembly }

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
