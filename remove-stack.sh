#!/bin/bash

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


# Undeploy
docker-machine ssh $Manager "docker stack rm dockerlab"
