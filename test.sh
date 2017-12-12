#!/bin/bash

NUM_SLAVES=$(awk -F\" '/^slave_asg_max_size/{print $2}'  "environments/$CONFIG.tfvars")
NUM_PUB_SLAVES=$(awk -F\" '/^public_slave_asg_max_size/{print $2}'  "environments/$CONFIG.tfvars")
DCOS_NODES=$((NUM_SLAVES + NUM_PUB_SLAVES))

if $(dcos marathon deployment list | grep -q scale); then
    echo "stuff"
else 
    echo "otehr suff"
fi          

echo $DCOS_NODES