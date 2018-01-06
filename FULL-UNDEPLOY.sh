#!/bin/bash

LeaveSwarm=
StopVMs=

# Check for sudo/root
printf "Checking for root permissions..."
if [[ $(id -u) -ne 0 ]]; then
	>&2 echo "Error: Root permissions required"
	exit 1
else
	echo "OK"
fi

./remove-stack.sh
./leave-swarm.sh
./stop-vms.sh