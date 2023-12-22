# nf-gas-clustering

A small workflow for denovo clustering of genomic data (e.g. MLST allele calls)

## Requirements

- Container software (docker, singularity, apptainer, gitpod, wave, charliecloud etc.)
- Nextflow runtime

## Basic Usage

```
nextflow run ./main.nf --input {INPUT_CSV} --outdir {FILE_OUTPUT_LOCATION} -profile {singularity, docker etc..}
```

## Input Sheet

Input profiles must be a tab delimited file.

|profile|matrix|
|-------|-------|
|PROFILE_NAME|/Path/To/Distance/Matrix.tsv|