// Create genetic similarity matrix based on allelic profiles



process PROFILE_DISTS{
    label "process_high"
    tag "Distance Matrix Generation"

    container "https://depot.galaxyproject.org/singularity/profile_dists%3A1.0.0--pyh7cba7a3_0"

    input:
    // TODO need to be smarter about mapping against self due to name space collisions
    tuple val(meta), path(ref_query), path(query)
    val mapping_format
    path(mapping_file)
    path(columns)


    output:
    tuple val(meta), path("${prefix}_${mapping_format}/allele_map.json"), emit: allele_map
    tuple val(meta), path("${prefix}_${mapping_format}/query_profile.{text,parquet}"), emit: query_profile
    tuple val(meta), path("${prefix}_${mapping_format}/ref_profile.{text,parquet}"), emit: ref_profile
    tuple val(meta), path("${prefix}_${mapping_format}/results.{text,parquet}"), emit: results
    tuple val(meta), path("${prefix}_${mapping_format}/run.json"), emit: run
    path  "versions.yml", emit: versions


    script:
    def args = ""
    def ref = ref_query
    def query_profile = query
    if(!query){
        query_profile = ref
    }

    if(mapping_file){
        args = args + "--mapping_file $mapping_file"
    }
    if(columns){
        args = args + " --columns $columns"
    }
    if(params.profile_dists.force){
        args = args + " --force"
    }
    if(params.profile_dists.skip){
        args = args + " --skip"
    }
    if(params.profile_dists.count_missing){
        args = args + " --count_missing"
    }
    // --match_threshold $params.profile_dists.match_thresh \\
    prefix = meta.id
    """
    profile_dists --query $query_profile --ref $ref $args --outfmt $mapping_format \\
                --distm $params.profile_dists.distm \\
                --file_type $params.profile_dists.file_type \\
                --missing_thresh $params.profile_dists.missing_thresh \\
                --sample_qual_thresh $params.profile_dists.sample_qual_thresh \\
                --max_mem ${task.memory.toGiga()} \\
                --cpus ${task.cpus} \\
                -o ${prefix}_${mapping_format}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        profile_dists: \$( profile_dists -V | sed -e "s/profile_dists//g" )
    END_VERSIONS
    """

}
