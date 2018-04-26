#!usr/bin/env bash

#script executed on the master node
#usage: sh populate-local-registry.sh s3_url registry_port

s3_URL=$1
REGISTRY_PORT=$2

if [ -z "$1" ]
then
	s3_URL="s3://falcon-scorpius-assets/packages/docker-tars"
fi

if [ -z "$2" ]
then
	REGISTRY_PORT=10005
fi

docker_tar_name_arr=($(aws s3 ls $s3_URL/ | awk {'print $4'}))
 
for docker_tar_name in "${docker_tar_name_arr[@]}"
do
	echo "Fetching and deploying $docker_tar_name"
	aws s3 cp $s3_URL/$docker_tar_name .
	image=`docker load --input $docker_tar_name | grep "Loaded image:" | awk {'print $3'}`
	docker tag $image docker-registry.marathon.l4lb.thisdcos.directory:$REGISTRY_PORT/$image
	docker push docker-registry.marathon.l4lb.thisdcos.directory:$REGISTRY_PORT/$image
	docker rmi $image docker-registry.marathon.l4lb.thisdcos.directory:$REGISTRY_PORT/$image
	rm $docker_tar_name
done

echo "Local docker registry is now populated"
