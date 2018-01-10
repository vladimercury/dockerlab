#!/bin/bash

# Check for sudo/root
printf "Checking for root permissions..."
if [[ $(id -u) -ne 0 ]]; then
	>&2 echo "Error: Root permissions required"
	exit 1
else
	echo "OK"
fi

# worker or manager
InstanceName=$1
DirName=lab$1/
TempName=lab$1
ImageName=vladimirkuriy/dockerlab:$1

echo $DirName
echo $TempName
echo $ImageName

if [[ -d $DirName ]]; then
	docker build -t $TempName $DirName
	docker tag $TempName $ImageName
	docker push $ImageName
else
	>&2 echo "Error: directory not exists"
fi
