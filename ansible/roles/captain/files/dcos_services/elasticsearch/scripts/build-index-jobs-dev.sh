#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export es_host=localhost
export es_port=9200
export es_index=cortex_jobs_dev
export mapping_path="$DIR/../mappings/cortex-jobs-dev.json"
source "$DIR/build-index.sh"
