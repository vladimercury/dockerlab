Images pushed to [vladimirkuriy/dockerlab/](https://hub.docker.com/r/vladimirkuriy/dockerlab/)


## Manager

Code at `labmanager` directory

Image is `vladimirkuriy/dockerlab:manager`

## Worker

Code at `labworker` directory

Image is `vladimirkuriy/dockerlab:worker`

Placed on nodes with label `type=worker`

## Persistence

Placed on nodes with label `type=db`

## Scripts

* `start-vms.sh` - Create and/or start VMs (vmanager, vworker1, vworker2, vdb)
* `init-swarm.sh` - Initialize docker swarm at manager and join workers to it
* `deploy-stack.sh` - Send `docker-compose.yml` to manager then deploy app
* `FULL-DEPLOY.sh` - `start-vms.sh` then `init-swarm.sh` then `deploy-stack.sh`
* `remove-stack.sh` - Undeploy app
* `leave-swarm.sh` - All nodes leave swarm
* `stop-vms.sh` - Stop VMs
* `FULL-UNDEPLOY.sh` - `remove-stack.sh` then `leave-swarm.sh` then `stop-vms.sh`
* `build-push-instance.sh <manager/worker>` - push changes to manager/worker image at docker.io