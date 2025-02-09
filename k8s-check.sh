#!/bin/bash

# Kubernetes Cluster Health Check Script
# This script verifies if the Kubernetes cluster is properly set up and all nodes are running

set -e  # Exit immediately if a command exits with a non-zero status

### 1️⃣ Check if kubectl is installed ###
if ! command -v kubectl &> /dev/null; then
    echo "❌ ERROR: kubectl is not installed. Please install it and try again."
    exit 1
fi

echo "✅ kubectl is installed. Proceeding with cluster health checks..."

### 2️⃣ Check if the control-plane is running ###
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ ERROR: Kubernetes API Server is not responding. Check if kube-apiserver is running on the control-plane."
    exit 1
fi

echo "✅ Kubernetes API Server is running."

### 3️⃣ Check if all nodes are ready ###
NOT_READY_NODES=$(kubectl get nodes --no-headers | grep -v "Ready" || true)
if [ -n "$NOT_READY_NODES" ]; then
    echo "⚠️ WARNING: Some nodes are not in Ready state:"
    echo "$NOT_READY_NODES"
else
    echo "✅ All nodes are in Ready state."
fi

### 4️⃣ Check if all system pods are running ###
NOT_RUNNING_PODS=$(kubectl get pods -n kube-system --no-headers | grep -v "Running\|Completed" || true)
if [ -n "$NOT_RUNNING_PODS" ]; then
    echo "⚠️ WARNING: Some system pods are not running correctly:"
    echo "$NOT_RUNNING_PODS"
else
    echo "✅ All system pods in kube-system namespace are running."
fi

### 5️⃣ Check if Calico network is working ###
if kubectl get pods -n kube-system | grep calico-node | grep -v "Running" &> /dev/null; then
    echo "❌ ERROR: Calico network is not working correctly. Check calico-node pods."
    exit 1
fi

echo "✅ Calico network is running properly."

### 6️⃣ Check overall cluster status ###
echo "🔍 Fetching detailed cluster status..."
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
kubectl get events --sort-by=.metadata.creationTimestamp

echo "🚀 Kubernetes cluster health check completed! If there were any warnings/errors, check the logs and take necessary actions."
