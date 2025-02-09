#!/bin/bash

# Prompt the user to enter the SSH username
read -p "Enter your SSH username: " USERNAME

# Check if the username is empty
if [ -z "$USERNAME" ]; then
    echo "❌ Username cannot be empty!"
    exit 1
fi

# Prompt the user to enter the domain name
read -p "Enter your domain: " DOMAIN

# Check if the domain is empty
if [ -z "$DOMAIN" ]; then
    echo "❌ Domain cannot be empty!"
    exit 1
fi

# Copy the join command script to all worker nodes
for host in k8s-1 k8s-2 k8s-3; do
    scp kubeadm_join_command.sh "$USERNAME@$host.$DOMAIN:~/"
done