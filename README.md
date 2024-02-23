### Parasoft DTP & minikube

Steps:
```
git clone https://github.com/daparic/dtp-minikube.git
cd dtp-minikube

# Parasoft DTP needs 10GB of RAM recommended if using MySQL.
./create-single-node-kubernetes-cluster.sh 2 10g

./setup-dtp.sh
```

Once minikube setup is done, Parasoft DTP may need a few more minutes to initialize. When it has initialized, test open in browser the http url corresponding to *http-server/8080*. 
