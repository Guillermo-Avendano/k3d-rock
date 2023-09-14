kubectl -n shared apply -f ./templates/storage/if-storage.yaml
helm install inputframework ./helm/inputframework -f ./helm/values-inputframework.yaml -n shared
helm uninstall inputframework -n shared
