process QUAST {
    tag "${meta.ID}"
    label "cpu_1"
    label "mem_1"
    label "time_30m"

    container  'quay.io/biocontainers/quast:5.0.2--py36pl5321hcac48a8_7'

    publishDir mode: 'copy', pattern: "${report_txt}", saveAs: { filename -> "${output}.txt" }, path: "${params.outdir}/${meta.ID}/quast"

    input:
    tuple val(meta), path(consensus)

    output:
    path(report_path), emit: quast_out
    path(report_txt), emit: text_report
    path(consensus)

    script:
    output = "${meta.ID}_assembly_stats"
    report_path = "${output}/transposed_report.tsv"
    report_txt = "${output}/report.txt"
    """
    quast.py ${consensus} -o ${output} --no-html --no-plots
    """
}

process SUMMARY {
    label "cpu_1"
    label "mem_1"
    label "time_1"

    container  'quay.io/biocontainers/quast:5.0.2--py36pl5321hcac48a8_7'

    publishDir mode: 'copy', pattern: "${summary}", path: "${params.outdir}/"

    input:
    path('transposed_report???.tsv')

    output:
    path(summary), emit: summary_out

    script:
    summary = "summary_quast_report.tsv"
    """
    head -n 1 transposed_report001.tsv > ${summary} && tail -n +2 -q transposed_report*.tsv >> ${summary}
    """
}
