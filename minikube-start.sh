#!/bin/sh
#

if [ -n "$MSYSTEM" ]; then
  # Running in Git Bash on Windows
  alias kubectl='minikube kubectl --'
fi

CPUS=${1:-2}
MEMORY=${2:-10g}
DISK_SIZE=${3:-20g}
NS=parasoft-dtp-namespace

if ! minikube status;then
    # minikube start --no-vtx-check
    minikube start --cpus $CPUS --memory=$MEMORY --disk-size=$DISK_SIZE
fi

count=$(kubectl get namespaces | awk '!/^(kube|NAME)/{print $1}' | while read ns;do kubectl get pods -n $ns 2>/dev/null | awk 'NR > 1{print $1}';done|grep -c -E '^(dtp|mysql-)')
if [ $count -ne 2 ];then

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
fi

minikube service dtp -n $NS
