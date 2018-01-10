#!/bin/bash

SkipVMCreation=
SkipNodeJoining=
SkipNodeLabeling=

# Check for sudo/root
printf "Checking for root permissions..."
if [[ $(id -u) -ne 0 ]]; then
	>&2 echo "Error: Root permissions required"
	exit 1
else
	echo "OK"
fi

VMs=(vmanager vworker1 vworker2 vdb)
Manager=vmanager
Workers=(vworker1 vworker2)
Persistence=vdb

echo "" > stack.log

# Send docker-compose to manager
printf "Sending docker-compose to $Manager..."
docker-machine scp docker-compose.yml $Manager:~ >> stack.log && echo "OK"

# Creating .data dir on manager
printf "Creating data dir on $Persistence..."
docker-machine ssh $Persistence "mkdir -p ./data" >> stack.log && echo "OK"

# Deploy stack
printf "Deploying stack..."
docker-machine ssh $Manager "docker stack deploy -c docker-compose.yml dockerlab" >> stack.log && echo "OK"