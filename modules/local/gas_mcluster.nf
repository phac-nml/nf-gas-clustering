// Denovo clustering module for GAS

process GAS_MCLUSTER{
    label "process_high"
    tag "Denovo Clustering"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/genomic_address_service%3A0.1.1--pyh7cba7a3_1' :
        'quay.io/biocontainers/genomic_address_service:0.1.1--pyh7cba7a3_0' }"

    input:
    tuple val(meta), path(dist_matrix)

    output:
    tuple val(meta), path("${prefix}/distances.{text,parquet}"), emit: distances, optional: true
    tuple val(meta), path("${prefix}/thresholds.json"), emit: thresholds
    tuple val(meta), path("${prefix}/clusters.{text,parquet}"), emit: clusters
    tuple val(meta), path("${prefix}/tree.nwk"), emit: tree
    tuple val(meta), path("${prefix}/run.json"), emit: run
    path  "versions.yml", emit: versions

    script:
    prefix = meta.id
    """
    gas mcluster --matrix $dist_matrix \\
                --outdir $prefix \\
                --threshold ${params.gm_thresholds} \\
                --delimeter ${params.gm_delimiter}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genomic_address_service: \$( gas mcluster -V | sed -e "s/gas//g" )
    END_VERSIONS
    """

}
