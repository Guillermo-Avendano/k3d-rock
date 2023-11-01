
#!/bin/bash
kubectl -n mobius apply -f ./application-yaml-configmap.yaml
kubectl -n mobius apply -f ./secret-sec-configmap.yaml
kubectl -n mobius apply -f ./job_demo_mobius12_all.yaml