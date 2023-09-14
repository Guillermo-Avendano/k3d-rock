# k3d Rocket Solutions

## Introduction

- Enterprise Orchestrator 4.3.2

### Prerequisites
```bash
cd k3d-rock/orchestrator
```

## Copy .env.sample file as .env 
  Add Rocket Community user for downloading images 

## Summary of commands

| Command | Description |
|:---|:---|
| ./orchestrator.sh  imgls     | (disabled) list images from registry.rocketsoftware.com (var KUBE_IMAGES in env.sh) |
| ./orchestrator.sh  imgpull   | (disabled) pull images from registry.rocketsoftware.com (var KUBE_IMAGES in env.sh) |
| ./orchestrator.sh  dbinstall | Install database |
| ./orchestrator.sh  dbremove  | Remove database |
| ./orchestrator.sh  install   | Enterprise Orchestrator  (pre-req: 'imgpull', 'dbinstall') |
| ./orchestrator.sh  remove    | Remove Enterprise Orchestrator  |
| ./orchestrator.sh  sleep     | Sleep Enterprise Orchestrator  (replicas=0) |
| ./orchestrator.sh  wake      | Wake up Enterprise Orchestrator (replicas=normal) |
| ./orchestrator.sh  debug     | Generate detail of kubernetes objects in namespaces (./logs directory) |

