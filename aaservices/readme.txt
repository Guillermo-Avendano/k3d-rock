k3d image load ../images/aaservices-11.1.2.tar -c zenith.local-mycluster

kubectl create ns aaservices

kubectl -n aaservices apply -f ./aas-pvc.yaml 

helm install aas11-1-2 ./aas-11.1.2.tgz --namespace=aaservices --create-namespace -f ./values-local.yaml --wait   

# Add this entry to to /etc/hosts
127.0.0.1   aaservices.local.net 

kubectl -n aaservices apply -f ./aas-ingress.yaml 

verify access to aas-ingress: http://aaservices.local.net/aaservices/view

kubectl -n aaservices exec -it pod/aas-56b9b599f-mt9ph -- bash
   java -jar -Dspring.profiles.active=docker /home/mobius/Samples/Demo_All_Samples/Docker/aas-cli-11.1.2.jar -jobName XMLImport -user admin -password admin -file /home/mobius/Samples/Demo_All_Samples/Exported_Samples.xml  -loadtype BOTH -importfromolderthan9 true
   exit 

helm uninstall aas11-1-2 --namespace=aaservices 
