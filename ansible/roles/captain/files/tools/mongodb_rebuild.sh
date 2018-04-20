#!/bin/bash

nodes=$(dcos percona-mongo pod status | jq -r 'to_entries[] | .key as $node | .value[] | select(.state=="TASK_LOST") | $node')

IFS=$'\n' read -rd '' -a pods <<< "${nodes}"

for i in "${pods[@]}"
do
    dcos percona-mongo pod replace "${i}"
done
