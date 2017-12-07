#!/bin/sh

DIR=$(dirname ${BASH_SOURCE[0]})

export es_host=localhost
export es_port=9200
export es_index=cortex_job_heartbeats_dev
export mapping_path="$DIR/../mappings/cortex-job-heartbeats-dev.json"
source "$DIR/build-index.sh"
