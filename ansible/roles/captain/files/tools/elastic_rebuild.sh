#!/bin/bash

nodes=$(dcos elastic pod status | jq -r '.[] | select(.[].state | contains("TASK_LOST")) | .[].name')

IFS=$'\n' read -rd '' -a pods <<< "${nodes}"

for i in "${pods[@]}"
do
    dcos elastic pod replace "${i%-*}"
done

