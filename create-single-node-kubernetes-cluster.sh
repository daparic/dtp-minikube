#!/bin/sh
#

if [ -n "$MSYSTEM" ]; then
  # Running in Git Bash on Windows
  alias kubectl='minikube kubectl --'
fi

CPUS=${1:-2}
MEMORY=${2:-6g}
DISK_SIZE=${3:-20g}

# minikube start --no-vtx-check
minikube start --cpus $CPUS --memory=$MEMORY --disk-size=$DISK_SIZE
