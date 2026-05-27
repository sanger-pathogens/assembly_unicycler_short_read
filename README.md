# assembly_unicycler_short_read

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[[_TOC_]]

## Pipeline overview

**assembly_unicycler_short_read** is a Nextflow DSL2 pipeline for assembling bacterial genomes from short-read (paired-end Illumina) sequencing data. It uses [Unicycler](https://github.com/rrwick/Unicycler) for de novo assembly and [QUAST](https://quast.sourceforge.net/) for assembly quality assessment.

The pipeline performs the following steps:

1. **Assembly** — Unicycler assembles paired short reads into contigs using SPAdes internally.
2. **Quality assessment** — QUAST evaluates assembly statistics (N50, contig count, total length) and produces a cross-sample summary.

## Usage

### Quickstart

#### From source code

1. Clone this repository (including submodules):

   ```bash
   git clone --recurse-submodules https://gitlab.internal.sanger.ac.uk/sanger-pathogens/pipelines/assembly_unicycler_short_read.git
   cd assembly_unicycler_short_read
   ```

2. To run with `docker`, use the `-profile docker` option:

   ```bash
   nextflow run main.nf \
       -profile docker \
       --manifest manifest.csv \
       --outdir my_output
   ```

   Other profiles are also supported (`singularity`).  
   :warning: If no profile is specified the pipeline will run with the Sanger HPC-specific configuration.

3. Once the run has finished, clean up intermediate files:

   ```bash
   rm -rf work .nextflow*
   ```

#### Using on the Sanger farm

Load Nextflow and Singularity:

```bash
module load nextflow ISG/singularity
```

Submit to LSF:

```bash
bsub -o output.o -e error.e -q oversubscribed -R "select[mem>4000] rusage[mem=4000]" -M4000 \
    nextflow run main.nf \
        --manifest manifest.csv \
        --outdir my_output
```

### Input

#### Manifest (`--manifest`)

A CSV file with the required header `ID,R1,R2`, containing per-sample paths to paired `.fastq.gz` files:

```
ID,R1,R2
sampleA,/path/to/sampleA_1.fastq.gz,/path/to/sampleA_2.fastq.gz
sampleB,/path/to/sampleB_1.fastq.gz,/path/to/sampleB_2.fastq.gz
```

Input can also be provided via iRODS query or ENA accession using the `mixed_input` sub-workflow — run `--help` for details.

### Output

Results are written to `--outdir` (default: `./results`):

```
results/
  <sample_ID>/
    assembly.fasta                   # Unicycler assembled contigs
  quast/
    report.tsv                       # Per-sample QUAST assembly statistics
    summary.tsv                      # Cross-sample QUAST summary
```

### Parameters

**Output options**

| Option                         | Type      | Default   | Description                                                                                                                             |
| ------------------------------ | --------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `--outdir`                     | `path`    | `results` | Directory where results are written.                                                                                                    |
| `--cleanup_intermediate_files` | `boolean` | `true`    | Delete SPAdes intermediate files generated during Unicycler assembly. Strongly recommended — SPAdes generates ~15,000 files per sample. |

---

**Processing options**

| Option                 | Type      | Default | Description                                                                                                             |
| ---------------------- | --------- | ------- | ----------------------------------------------------------------------------------------------------------------------- |
| `--unicycler_max_jobs` | `integer` | `100`   | Maximum number of concurrent Unicycler processes. Reduce to limit intermediate file accumulation on shared filesystems. |

---

**Unicycler options**

| Option   | Type     | Default  | Description                                                   |
| -------- | -------- | -------- | ------------------------------------------------------------- |
| `--mode` | `string` | `normal` | Unicycler assembly mode: `conservative`, `normal`, or `bold`. |

---

**SPAdes options**

| Option          | Type      | Default | Description                                                                                                                                                                                                                                                                 |
| --------------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--isolate`     | `boolean` | `true`  | Enable SPAdes `--isolate` mode (recommended for bacterial isolates). Mutually exclusive with `--careful`.                                                                                                                                                                   |
| `--careful`     | `boolean` | `false` | Enable SPAdes `--careful` mode. Recommended for small or viral genomes only. :warning: Can generate millions of intermediate files on bacterial genomes — use with `--cleanup_intermediate_files true` and low `--unicycler_max_jobs`. Mutually exclusive with `--isolate`. |
| `--cutoff_auto` | `boolean` | `false` | Set SPAdes k-mer coverage cutoff to `auto`.                                                                                                                                                                                                                                 |
| `--lock_phred`  | `boolean` | `false` | Force PHRED offset 33 (useful for SRAlite FASTQ reads with missing quality encoding).                                                                                                                                                                                       |

---

**Logging options**

| Option              | Type      | Default | Description                 |
| ------------------- | --------- | ------- | --------------------------- |
| `--monochrome_logs` | `boolean` | `false` | Output logs in plain ASCII. |

### Advanced usage

#### Controlling filesystem impact

SPAdes generates a large number of intermediate files per sample. To avoid saturating filesystem quotas when running at scale, keep `--cleanup_intermediate_files true` (default) and reduce `--unicycler_max_jobs`:

```bash
nextflow run main.nf --manifest manifest.csv --unicycler_max_jobs 5 --outdir my_output
```

#### Careful mode for small genomes

For small or viral genomes where careful SPAdes error correction is beneficial:

```bash
nextflow run main.nf --manifest manifest.csv --isolate false --careful true --unicycler_max_jobs 1 --outdir my_output
```

### Dependencies

All software dependencies are containerised. No external databases are required.

## Software versions

| Software  | Version | Image                                                     |
| --------- | ------- | --------------------------------------------------------- |
| Unicycler | 0.5.1   | `quay.io/sangerpathogens/unicycler:0.5.1-vanillaspades`   |
| QUAST     | 5.0.2   | `quay.io/biocontainers/quast:5.0.2--py36pl5321hcac48a8_7` |

See `modules/` for pinned container versions.

## Troubleshooting

- **Filesystem quota exceeded**: reduce `--unicycler_max_jobs` and ensure `--cleanup_intermediate_files true`.
- **`--isolate` and `--careful` conflict**: these flags are mutually exclusive. Use `--isolate false --careful true` to disable isolate mode and enable careful mode.
- **Poor assembly quality**: try `--mode bold` for more aggressive bridging, or `--mode conservative` for fewer false joins.
- **Resuming a failed run**: add `-resume` to restart from cached intermediate results.
- For further help, check `.nextflow.log` and the per-process logs in the `work/` directory.

## Issues and Contributions

If you find an issue with this pipeline, or would like to suggest an improvement, please log an issue or open a pull request on this repository.

If you are at Sanger and need internal support, you can raise an issue on the PAM Freshservice portal: https://sanger.freshservice.com/support/catalog/items/426
