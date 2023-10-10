# k3d Rocket Solutions

## Introduction

- k3d installation : Orchestrator 4.3.2, Mobius 12.2.0, AAS 11.2.1, Input Framework 

## Prerequisites

- Ubuntu-WSL / Ubuntu 20.04 or higher
- 16 GB / 4 CPUs
- Ubuntu WSL Installation: <https://learn.microsoft.com/en-us/windows/wsl/install-manual>

## Preinstallation actions

### Ubuntu: get installations scripts (don't use root user)

```bash
git clone https://github.com/guillermo-avendano/k3d-rock.git
cd k3d-rock
```

## Install dos2unix

```bash
sudo apt install -y dos2unix
```

## Change files to unix/linux format

```bash
# k3d-rock folder
find . -name "*.yaml" -exec dos2unix {} \;
find . -name "*.sh" -exec dos2unix {} \;
```

## Enable scripts for execution

```bash
# k3d-rock folder
chmod -R u+x *.sh
```

## Copy .env.sample file as .env 
  Add license/s, Rocket Community user for downloading images, change URLs if needed, adapt versions

### Refresh environment variables

```bash
# k3d-rock folder
source ./env.sh
```

### Optional: add KUBECONFIG to $HOME/.profile or $HOME/.bashrc


**export KUBECONFIG="$kube_dir/cluster/$HOSTNAME-cluster_config.yaml"**

It's key for interaction among the commands: kubectl, helm, etc., with the cluster k3d.
***

## Install Infrastructure

1; Install docker, k3d, helm, kubectl 

```bash
# k3d-rock folder
./pre-reqs-install.sh
```

2; Verify docker (more information <https://docs.docker.com/desktop/install/ubuntu/>)

```bash
docker version
```

## Operate with Cluster

```bash
# k3d-rock folder
./rockcluster.sh create
```

## Summary of commands

| Command | Description |
|:---|:---|
| ./rockcluster.sh start | start cluster |
| ./rockcluster.sh stop | stop cluster |
| ./rockcluster.sh list | list clusters |
| ./rockcluster.sh create | create cluster |
| ./rockcluster.sh remove | remove cluster |

## Mobius installation
[Mobius](mobius/README.md)

## Audit and Analytics Services installation
[A&A Services](aaservices/README.md)

## Enterprise Orchestrator installation
[Orchestrator](orchestrator/README.md)

## InputFramework Installation
[InputFramework](inputframework/README.md)

## Tools: pgadmin, grafana, portainer installation
[Tools](tools/README.md)