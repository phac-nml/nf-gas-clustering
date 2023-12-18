



nextflow.enable.dsl = 2

// Module imports
include { PROFILE_DISTS } from "./modules/local/profile_dists.nf"
include { GAS_MCLUSTER } from "./modules/local/gas_mcluster.nf"

// nf-core modules
include { CUSTOM_DUMPSOFTWAREVERSIONS } from './modules/nf-core/dumpsoftwareversions/main'

// Plugin imports
include { validateParameters; paramsHelp; fromSamplesheet } from 'plugin/nf-validation'

if (params.help) {
    log.info paramsHelp("nextflow run my_pipeline --input input_file.csv")
    exit 0
}


if (params.validate_params) {
    validateParameters()
}

def validateFilePath(String filep){
    if(filep){
        file_in = file(filep)
        if(file_in.exists()){
            return file_in
        }else{
            exit 1, "${filep} does not exist but was passed to the pipeline. Exiting now."
        }
    }
    return [] // empty value if file argument is null
}


workflow CLUSTER {

    versions = Channel.empty()

    input_profiles = Channel.fromSamplesheet('input', 
                            parameters_schema: 'nextflow_schema.json') // from the input get meta, path(query)
    
    input_profiles = input_profiles.map{
        meta, path -> tuple(meta, validateFilePath(path))
    }

    // optional files to be passed in
    mapping_file = validateFilePath(params.pd_mapping_file)
    columns_file = validateFilePath(params.pd_columns)
    
    // options related to output to be passed into profile idsts
    mapping_format = Channel.value(params.pd_outfmt)

    dist_data = PROFILE_DISTS(input_profiles, mapping_format, mapping_file, columns_file)
    versions = versions.mix(dist_data.versions)

    clustered_data = GAS_MCLUSTER(dist_data.results)
    versions = versions.mix(clustered_data.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS(versions.unique().collectFile(name: 'collated_versions.yml'))

}


workflow {
    CLUSTER()
}