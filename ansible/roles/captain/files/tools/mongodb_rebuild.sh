#!/bin/bash

nodes=$(dcos mongodb-replicaset pods status | jq -r '.[] | select(.[].state | contains("TASK_LOST")) | .[].name')

IFS=$'\n' read -rd '' -a pods <<< "${nodes}"

for i in "${pods[@]}"
do
    dcos mongodb-replicaset pods replace "${i%-*}"
done

until [[ $(dcos mongodb-replicaset pods status | grep TASK_RUNNING | wc -l) == 3 ]]; do sleep 30; done

CURRENT_SLAVES=$(aws ec2 describe-instances --filters "Name=tag:Role,Values=slave" "Name=tag:environment,Values=$ENVIRONMENT" --query "Reservations[].Instances[].PrivateIpAddress" | jq -r '.[]')
echo "$CURRENT_SLAVES" > current_slaves.txt

SHARED_HOSTS=$(grep -f current_slaves.txt ../dcos_services/mongo_hosts.txt)
OLD_HOST=$(grep -v -F -x -f current_slaves.txt ../dcos_services/mongo_hosts.txt)
NEW_HOST=$(grep -v -F -x -f ../dcos_services/mongo_hosts.txt current_slaves.txt)

MONGO_ARRAY=(`echo ${SHARED_HOSTS}`)

echo $SHARED_HOSTS
echo "${MONGO_ARRAY[0]}"
echo "${MONGO_ARRAY[1]}"
echo $OLD_HOST
echo $NEW_HOST

MONGO_MASTER=$(mongo "mongodb://${MONGO_ARRAY[0]}:27017" --eval "printjson(rs.isMaster())" | grep "primary" | cut -d"\"" -f4)

echo $MONGO_MASTER

mongo "mongodb://${MONGO_MASTER}" --eval "printjson(rs.remove('${OLD_HOST}:27017'))"
mongo "mongodb://${MONGO_MASTER}" --eval "printjson(rs.add('${NEW_HOST}:27017'))"

echo "$CURRENT_SLAVES" > ../dcos_services/mongo_hosts.txt