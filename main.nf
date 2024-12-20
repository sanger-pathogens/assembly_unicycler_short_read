#!/usr/bin/env nextflow

/*
========================================================================================
    HELP
========================================================================================
*/

def logo = NextflowTool.logo(workflow, params.monochrome_logs)

log.info logo

NextflowTool.commandLineParams(workflow.commandLine, log, params.monochrome_logs)

def printHelp() {
    NextflowTool.help_message(
        "${workflow.ProjectDir}/schema.json",
        [
            "${workflow.ProjectDir}/assorted-sub-workflows/mixed_input/schema.json"
        ],
        params.monochrome_logs, log
    )
}

def validateParameters() {
    if (params.isolate) and (params.careful){
        log.error """The parameters `--isolate` and `--careful` are exclusive and cannot be specified together. Please use `--isolate false --careful` to turn off default `isolate` and enable `careful`."""
    }
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

include { MIXED_INPUT         } from './assorted-sub-workflows/mixed_input/mixed_input.nf'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    if (params.help) {
        printHelp()
        exit(0)
    }

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
