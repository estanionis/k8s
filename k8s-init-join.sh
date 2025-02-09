#!/bin/bash

# Kubernetes Cluster Init & Join Script
# This script detects if the node is control-plane or worker and runs the appropriate command.

set -e  # Exit on error

# Prompt the user to enter the domain name
read -p "Enter your domain: " DOMAIN

# Check if the domain is empty
if [ -z "$DOMAIN" ]; then
    echo "❌ Domain cannot be empty!"
    exit 1
fi

# Detect if the node is control-plane
IS_CONTROL_PLANE=false
if [[ "$(hostname)" == "k8s-0" ]]; then
    IS_CONTROL_PLANE=true
fi

# Detect if DNS is available
DNS_AVAILABLE=false
if host "k8s-0.$DOMAIN" &>/dev/null; then
    DNS_AVAILABLE=true
fi

# Define Control Plane Endpoint
if [ "$DNS_AVAILABLE" = true ]; then
    CONTROL_PLANE_ENDPOINT="k8s-0.$DOMAIN"
else
    CONTROL_PLANE_ENDPOINT="192.168.4.100"
fi

### 1️⃣ Initialize Control-Plane ###
if [ "$IS_CONTROL_PLANE" = true ]; then
    echo "🚀 Initializing Kubernetes Control Plane on $(hostname)"
    sudo kubeadm init --control-plane-endpoint "$CONTROL_PLANE_ENDPOINT:6443" --pod-network-cidr=192.168.0.0/16

    # Configure kubectl for the control-plane user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Install Calico Network Plugin
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    
    echo "✅ Control-plane initialized successfully. Run 'kubectl get nodes' to verify."

    # Generate the join command for workers
    kubeadm token create --print-join-command | tee kubeadm_join_command.sh
    chmod +x kubeadm_join_command.sh
    echo "⚡ Run 'cat kubeadm_join_command.sh' and execute the command on worker nodes."
else
    ### 2️⃣ Join Worker Nodes ###
    echo "🔄 Joining worker node $(hostname) to the Kubernetes cluster"
    if [ -f kubeadm_join_command.sh ]; then
        sudo bash kubeadm_join_command.sh
    else
        echo "❌ ERROR: Join command not found. Run this script first on the control-plane node."
    fi
fi
