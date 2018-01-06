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
Workers=(vworker1 vworker2)
Persistence=vdb

# Creating and starting VMs
echo "Creating and starting VMs..."
for name in ${VMs[*]}; do
	printf "\t"$name"..."
	if [[ -z $(docker-machine ls | grep ^$name) ]]; then
		RAM=""
		# Less RAM for non-manager
		if [[ $name != $Manager ]]; then
			RAM="--virtualbox-memory 512"
		fi
		docker-machine create --driver virtualbox $RAM $name >> /dev/null && echo "created"
	else
		docker-machine start $name >> /dev/null && echo "started"
	fi
done

# Regenerate certificates
for name in ${VMs[*]}; do
	if [[ -n $(docker-machine ls | grep ^$name | grep "Unable to query") ]]; then
		printf "Regenerating certificate for $name..."
		docker-machine regenerate-certs -f $name >> /dev/null && echo "OK"
	fi
done