#!usr/bin/env bash

#script executed on all the nodes of DCOS cluster
#usage: sh configure-docker-deamon.sh registry_port

REGISTRY_PORT=$1

if [ -z "$REGISTRY_PORT" ]
then
	REGISTRY_PORT=10005
fi

sudo tee /etc/docker/daemon.json << EOF
{
  "insecure-registries" : ["docker-registry.marathon.l4lb.thisdcos.directory:$REGISTRY_PORT"]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
