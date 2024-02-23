#!/bin/sh
#

if [ -n "$MSYSTEM" ]; then
  	# Running in Git Bash on Windows
  	alias kubectl='minikube kubectl --'
fi

NS=parasoft-dtp-namespace

# Sequence is important
kubectl create namespace $NS
kubectl create -f pv-volume.yaml
kubectl create -f pv-claim.yaml

kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-storage.yaml
kubectl apply -f mysql-deployment.yaml

printf "Waiting for mysql pod to up: "
kubectl get pod | grep Running
while [ $? -ne 0 ];do
    printf "."
    sleep 5
    kubectl get pod | grep -q Running
done

echo
mysql_ipaddr=$(kubectl get svc | awk '/^mysql/ {print $3}')
sed -bi "s/jdbc:mysql:\/\/[0-9.]\+:/jdbc:mysql:\/\/$mysql_ipaddr:/g" parasoft-dtp.yaml

kubectl create -f parasoft-permissions.yaml
kubectl create -f parasoft-dtp.yaml

printf "Waiting for dtp pod to up: "
kubectl get pods -n $NS | grep Running
while [ $? -ne 0 ];do
    printf "."
    sleep 5
    kubectl get pods -n $NS | grep -q Running
done

echo
minikube service dtp -n $NS
