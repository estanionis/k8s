#!/bin/bash

# 🚀 Kubernetes Worker Node Join Script
# This script copies the Kubernetes join command to worker nodes.

set -e  # Exit on error

# Prompt the user to enter the SSH username
read -p "🔑 Enter your SSH username: " USERNAME

# Check if the username is empty
if [ -z "$USERNAME" ]; then
    echo "❌ Username cannot be empty!"
    exit 1
fi

# Prompt the user to enter the domain name
read -p "🌍 Enter your domain: " DOMAIN

# Check if the domain is empty
if [ -z "$DOMAIN" ]; then
    echo "❌ Domain cannot be empty!"
    exit 1
fi

# Prompt the user to enter the number of worker nodes
read -p "🔢 Enter the number of worker nodes: " NODE_COUNT

# Validate the input
if ! [[ "$NODE_COUNT" =~ ^[0-9]+$ ]] || [ "$NODE_COUNT" -le 0 ]; then
    echo "❌ Invalid input! Please enter a positive integer."
    exit 1
fi

# Define worker nodes dynamically
WORKER_NODES=()
for ((i=1; i<=NODE_COUNT; i++)); do
    WORKER_NODES+=("k8s-$i")
done

# Ensure the join command script exists
if [ ! -f "kubeadm_join_command.sh" ]; then
    echo "❌ ERROR: kubeadm_join_command.sh not found! Run this script on the control-plane first."
    exit 1
fi

# Copy the join command script to all worker nodes
for NODE in "${WORKER_NODES[@]}"; do
    echo "📤 Copying kubeadm_join_command.sh to $NODE.$DOMAIN..."
    scp kubeadm_join_command.sh "$USERNAME@$NODE.$DOMAIN:~/"
    echo "✅ Successfully copied to $NODE.$DOMAIN"
done

echo "🎉 All worker nodes have received the join command script!"
