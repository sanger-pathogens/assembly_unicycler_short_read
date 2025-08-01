# assembly_unicycler_short_read

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![nf-test](https://img.shields.io/badge/tested_with-nf--test-337ab7.svg)](https://github.com/askimed/nf-test)

## Introduction

**assembly_unicycler_short_read** is a bioinformatics best-practice analysis pipeline for simple bacterial assembly and assembly QC. This particular pipeline is designed for **short read data**.

## Pipeline summary

The pipeline performs assembly of short read data using [Unicycler](https://github.com/rrwick/Unicycler). QC statistics are provided using [QUAST](http://bioinf.spbau.ru/quast).

## Getting started

### Running on the farm (Sanger HPC clusters)

1. Load nextflow and singularity modules:

   ```bash
   module load nextflow ISG/singularity
   ```

2. Clone the repo:

   ```bash
   git clone --recurse-submodules git@gitlab.internal.sanger.ac.uk:sanger-pathogens/pipelines/assembly_unicycler_short_read.git
   cd assembly_unicycler_short_read
   ```

3. Start the pipeline  
   For example input, please see [Generating a manifest](#generating-a-manifest).

   Example:

   ```bash
   nextflow run . --manifest ./test_data/inputs/test_manifest.csv --outdir my_output
   ```

   It is good practice to submit a dedicated job for the nextflow master process (use the `oversubscribed` queue):

   ```bash
   bsub -o output.o -e error.e -q oversubscribed -R "select[mem>4000] rusage[mem=4000]" -M4000 nextflow run . --manifest ./test_data/inputs/test_manifest.csv --outdir my_output
   ```

   See [usage](#usage) for all available pipeline options.

4. Once your run has finished, check output in the `outdir` and clean up any intermediate files. To do this (assuming no other pipelines are running from the current working directory) run:

   ```bash
   rm -rf work .nextflow*
   ```

## Generating a manifest

This pipeline has several input parameters that allow read data to be retrieved locally, from the ENA, and from iRODS. Further detail can be found by using the pipeline `--help` parameter, or [here](./assorted-sub-workflows/README.md).

Scripts have been developed to generate manifests appropriate for this pipeline:

- To generate a manifest from a file of lane identifiers visible to `pf`, use [this script](./scripts/generate_manifest_from_lanes.sh).

- To generate a manifest from a file of custom .fastq.gz paths, use [this script](./scripts/generate_manifest.sh).

Please run `--help` on these scripts for more information on script usage.

## Usage

```console
 The following parameters were provided on the command line:

      - help: true

 Sequencing reads input parameters

There are two ways of providing input reads, which can be combined
      1) through direct input of compressed fastq sequence reads files. This kind of input is passed by specifying the paths to the
      read files via a manifest listing the pair of read files pertaing to a sample, one per row.

      --manifest_of_reads
            default: false
            Manifest containing per-sample paths to .fastq.gz files (optional)

      2) through specification of data to be downloaded from iRODS.
      The selected set of data files is defined by a combination of parameters: studyid, runid, laneid, plexid, target and type (these refer to specifics of the sequencing experiment and data to be retrieved).
      Each parameter restricts the set of data files that match and will be downloaded; when omitted, samples for all possible values of that parameter are retrieved.
      At least one of studyid or runid parameters must be specified. laneid/plexid/target/type are optional parameters that can be provided only in combination with studyid or runid;
      if these are specified without a studyid or runid, the request will be ignored (no iRODS data or metadata download) with a warning
      - this condition aims to avoid indiscriminate download of thousands of files across all possible runs.
      These parameters can be specified through the following command line options: --studyid, --runid, --laneid, --plexid, --target and --type.

      --studyid
            default: -1
            Sequencing Study ID
      --runid
            default: -1
            Sequencing Run ID
      --laneid
            default: -1
            Sequencing Lane ID
      --plexid
            default: -1
            Sequencing Plex ID
      --target
            default: 1
            Marker of key data product likely to be of interest to customer
      --type
            default: cram
            File type

Alternatively, the user can provide a CSV-format manifest listing a batch of such combinations.

      --manifest_of_lanes
            default: false
            Path to a manifest of search terms as specified above.
            At least one of studyid or runid fields, or another field that matches the list of iRODS metadata fields must be specified; other parameters are not mandatory and corresponding
            fields in the CSV manifest file can be left blank. laneid/plexid are only considered when provided alongside a studyid or runid. target/type are only considered in combination with studyid, runid, or other fields.

            Example of manifest 1:
                studyid,runid,laneid,plexid
                ,37822,2,354
                5970,37822,,332
                5970,37822,2,

            Example of manifest 2:
                sample_common_name,type,target
                Romboutsia lituseburensis,cram,1
                Romboutsia lituseburensis,cram,0
      --manifest_ena
            default: false
            Path to a manifest/file of ENA accessions (run, sample or study). Please also set the --accession_type to the appropriate accession type.
-----------------------------------------------------------------
 Aliased options
      --manifest
            default:
            Alias for --manifest_of_reads (optional)
-----------------------------------------------------------------
 Output options
      --outdir
            default: results
            Path to output folder (optional)

      --cleanup_intermediate_files
            default: true
            whether to delete intermediate files from the multiple iterations of SPAdes assembly as generated within Unicycler process

-----------------------------------------------------------------
 Processing options
      --unicycler_max_jobs
            default: 100
            maximum number of UNICYCLER processes to be run at a given time. Upper limit allows to avoid the quick inflation of file count on filesystem due to generation of many (~15k) intermediate assembly files by SPAdes, which will only be cleaned up by a later process.

-----------------------------------------------------------------
 Unicycler pipeline options
      --mode
            default: normal
            defines value for Unicycler option --mode and thus the aggressivity of the assembly scaffold resolution task; valid values are: 'conservative', 'normal' or 'bold'

-----------------------------------------------------------------
 SPAdes assembler options
      --cutoff_auto
            default: false
            sets SPAdes option --cutoff to 'auto'

      --lock_phred
            default: false
            sets SPAdes option --phred-offset to 33 (useful when reads quality information is missing e.g. when using SRAlite fastq reads)

      --careful
            default: false
            enables SPAdes option --careful (sets careful running mode; this parameter is exclusive of --isolate)

      --isolate
            default: true
            enables SPAdes option --isolate (sets isolate running mode; this parameter is exclusive of --careful). This is the native built-in behaviour of Unicycler as a standalone tool

-----------------------------------------------------------------
 Logging options
      --monochrome_logs
            default: false
            Should logs appear in plain ASCII (optional)

-----------------------------------------------------------------
```

## Testing

Developer contributions to this pipeline will only be accepted if all pipeline tests pass. To check:

1. Make your changes.

2. Download the test data. A utility script is provided:

   ```
   python3 scripts/download_test_data.py
   ```

3. Install [`nf-test`](https://code.askimed.com/nf-test/installation/) (>=0.7.0) and run the tests:

   ```
   nf-test test
   ```

   If you are not running on the Sanger HPC, run the above command with `--profile docker` or `--profile singularity` (depending on your system).

## Credits

assembly_unicycler_short_read was inspired by the [nf-co.re/bacass](https://github.com/nf-core/bacass) and contains components derived from that pipeline.

## Support

For further information or help, don't hesitate to get in touch via [pam-informatics@sanger.ac.uk](mailto:pam-informatics@sanger.ac.uk).

## Citations

If you use `assembly_unicycler_short_read` for your analysis, please cite the `nf-co.re/bacass` pipeline using the following doi: [10.5281/zenodo.2669428](https://doi.org/10.5281/zenodo.2669428)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-co.re` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
