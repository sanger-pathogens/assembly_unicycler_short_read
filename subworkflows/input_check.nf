//
// Check input samplesheet and get read channels
//

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    Channel
        .fromPath( samplesheet )
        .ifEmpty {exit 1, log.info "Cannot find path file ${tsvFile}"}
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channels(it) }
        .filter{ meta, R1, R2 -> R1 != null && R2 != null }
        .set { shortreads }

    emit:
    shortreads // channel: [ val(meta), [ reads ] ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_fastq_channels(LinkedHashMap row) {
    def meta = [:]
    meta.ID = row.ID

    Path read_1 = null
    Path read_2 = null

    def array = []
    // check R1
    if ( !file(row.R1).exists() ) {
        exit 1, "ERROR: Please check input manifest -> Read 1 file does not exist!\n${row.R1}"
    }
    read_1 = file(row.R1)

    // check R2
    if ( !file(row.R2).exists() ) {
        exit 1, "ERROR: Please check input manifest -> Read 2 file does not exist!\n${row.R2}"
    }
    read_2 = file(row.R2)

    array = [ meta, read_1, read_2 ]
    return array
}
