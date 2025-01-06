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
Usage:
    nextflow run main.nf
Basic options:
   --manifest                   Manifest containing per-sample paths to .fastq.gz files (mandatory)
   --outdir                     Specify output directory [default: ./results] (optional)
   --help                       Print the help message (optional)
Extended options:
   --cleanup_intermediate_files Whether to delete intermediate files from the multiple iterations of SPAdes assembly as generated within Unicycler process [default: true] (optional)
   --mode                        Defines value for Unicycler option --mode and thus the aggressivity of the assembly scaffold resolution task; valid values are: 'conservative', 'normal' or 'bold'  [default: normal] (optional)
   --cutoff_auto                 Sets SPAdes option --cutoff to 'auto' [default: false] (optional)
   --lock_phred                  Sets SPAdes option --phred-offset to 33 (useful when reads quality information is missing e.g. when using SRAlite fastq reads) [default: false] (optional)
   --careful                     enables SPAdes option --careful (sets careful runnig mode); this parameter is exclusive of --isolate) [default: false] (optional)
   --isolate                     enables SPAdes option --isolate (sets isolate runnig mode); this parameter is exclusive of --careful) [default: false] (optional)
   --monochrome_logs Should logs appear in plain ASCII [default: false] (optional)

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
