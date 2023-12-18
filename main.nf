



nextflow.enable.dsl = 2

// Module imports
include { PROFILE_DISTS } from "modules/local/profile_dists.nf"
include { GAS_MCLUSTER } from "modules/local/gas_mcluster.nf"


// Plugin imports
include { validateParameters; paramsHelp; fromSamplesheet } from 'plugin/nf-validation'

if (params.validate_params) {
    validateParameters()
}

def validateFilePath(String filep){
    if(filep){
        File file_in = file(file_path)
        if(file_in.exists()){
            return file_in
        }else{
            exit 1, "${filep} does not exist but was passed to the pipeline. Exiting now."
        }
    }
    return [] // empty value if file argument is null
}


workflow CLUSTER {


    input_profiles = Channel.fromSamplesheet('input', 
                            parameters_shcema: 'nextflow_schema.json') // from the input get meta, path(query)
    

    // optional files to be passed in
    mapping_file = validateFilePath(params.pd_mapping_file)
    columns_file = validateFilePath(params.pd_columns)
    
    // options related to output to be passed into profile idsts
    mapping_format = Channel.value(params.pd_outfmt)

    dist_data = PROFILE_DISTS(input_profiles, mapping_format, mapping_file, columns_file)

    clustered_data = GAS_MCLUSTER(dist_data.results)

}


workflow {

    CLUSTER()
}