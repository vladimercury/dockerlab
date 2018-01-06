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

# Init swarm
printf "Getting manager IP..."
ManagerIP=$(docker-machine ls | grep ^$Manager | grep -ohE "([0-9]+\.){3}[0-9]+")
echo $ManagerIP
printf "Init swarm..."
JoinCommand=$(docker-machine ssh $Manager "docker swarm init --advertise-addr $ManagerIP" | grep "\--token" || exit 1)
echo $JoinCommand | grep -ohE "SWMTKN[^ ]+"
if [[ -n $JoinCommand ]]; then
	echo "Joining swarm..."
	for name in ${VMs[*]}; do
		if [[ $name != $Manager ]]; then
			printf "\t$name..."
			docker-machine ssh $name "$JoinCommand" >> /dev/null && echo "OK"
		fi
	done
else
	echo "Cannot join nodes without manager"
	exit 1
fi


# Setting labels to nodes
if [[ -z $SkipNodeLabeling ]]; then
	printf "Labeling nodes..."
	for name in ${Workers[*]}; do
		docker-machine ssh $Manager "docker node update $name --label-add type=worker" >> /dev/null
	done
	docker-machine ssh $Manager "docker node update $Persistence --label-add type=db" >> /dev/null
	echo "OK"
fi