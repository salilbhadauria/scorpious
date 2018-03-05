#!/bin/bash

ssh -i /opt/private_key -o StrictHostKeyChecking=no -f -L 27017:mongodb.mongodb-replicaset.l4lb.thisdcos.directory:27017 deployer@10.0.1.193 sleep 10 & mongo "mongodb://localhost:27017/?replicaSet=rs"