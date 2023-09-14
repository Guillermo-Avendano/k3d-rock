kubectl create ns eosdemo

# cluster name=mobius12
k3d image load server/eosopenserver-demo.tar -c mobius12

#NOOOOO --> kubectl apply -f server/persistence.yaml -n eosdemo

kubectl apply -f server/deployment.yaml -n eosdemo
kubectl apply -f server/service.yaml -n eosdemo

#----------------------------------------------------------------
# cluster name=mobius12
k3d image load access/eosaccess3.1.1.0.tar -c mobius12

kubectl apply -f access/persistence.yaml -n eosdemo
kubectl apply -f access/deployment.yaml -n eosdemo
kubectl apply -f access/service.yaml -n eosdemo
kubectl apply -f access/ingress.yaml -n eosdemo

--------------------------------------
kubectl get services -n eosdemo
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
eosopenserver-demo   ClusterIP   10.43.104.205   <none>        36000/TCP   15h
eosaccess            ClusterIP   10.43.32.130    <none>        8080/TCP    33s

kubectl get ingress -n eosdemo
NAME        CLASS   HOSTS                 ADDRESS      PORTS   AGE
eosaccess   nginx   eosaccess.local.net   172.25.0.5   80      63s
--------------------------------------

http://eosaccess.local.net/eos-access

user=RDS0
pass=RDS0

server API= eosopenserver-demo.eosdemo:36000/wsEOS
