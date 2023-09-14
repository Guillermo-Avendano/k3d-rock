# k3d Rocket Solutions

## Introduction

- Mobius 12.2.0

### Prerequisites
```bash
cd k3d-rock/mobius
```

## Copy .env.sample file as .env 
  Add the license and Rocket Community user for downloading images

## Summary of commands

| Command | Description |
|:---|:---|
| ./mobius.sh  imgls     | list images from registry.rocketsoftware.com (var KUBE_IMAGES in env.sh) |
| ./mobius.sh  imgpull   | pull images from registry.rocketsoftware.com (var KUBE_IMAGES in env.sh) |
| ./mobius.sh  imgls-loc | list images from localhost:5000 |
| ./mobius.sh  shinstall | Install shared resources (db, elastic, kafka) |
| ./mobius.sh  shremove  | Remove shared resources (db, elastic, kafka) |
| ./mobius.sh  install   | Install Mobius 12.2.0 (pre-reqs: 1.'imgpull', 2.'shinstall') |
| ./mobius.sh  remove    | Remove Mobius 12.2.0 |
| ./mobius.sh  sleep     | Sleep Mobius 12.2.0 (replicas=0) |
| ./mobius.sh  wake      | Wake up Mobius 12.2.0 (replicas=normal) |
| ./mobius.sh  debug     | Generate detail of kubernetes objects in namespaces (./logs directory) |

