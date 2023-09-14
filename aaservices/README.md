# k3d Rocket Solutions

## Introduction

- Audit and Analytics Services 11.2.1

### Prerequisites
```bash
cd k3d-rock/aaservices
```
## Copy .env.sample file as .env 
  Add the license and Rocket Community user for downloading images 
## Summary of commands

| Command | Description |
|:---|:---|
| k3d image load aaservices-11.1.2.tar -c "_cluster-name_" | load aaservices image in "_cluster-name_" cluster |
| ./aaservices.sh  imgls     | (disabled) list images from registry.rocketsoftware.com (var KUBE_IMAGES in env.sh) |
| ./aaservices.sh  imgpull   | (disabled) pull images from registry.rocketsoftware.com (var KUBE_IMAGES in env.sh) |
| ./aaservices.sh  dbinstall | Install database |
| ./aaservices.sh  dbremove  | Remove database |
| ./aaservices.sh  install   | Install A&A Services (pre-req: load asservices image, 'dbinstall') |
| ./aaservices.sh  remove    | Remove A&A Services |
| ./aaservices.sh  sleep     | Sleep A&A Services (replicas=0) |
| ./aaservices.sh  wake      | Wake up A&A Services (replicas=normal) |
| ./aaservices.sh  debug     | Generate detail of kubernetes objects in namespaces (./logs directory) |

