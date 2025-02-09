#!/bin/bash

# Kubernetes Cluster Setup Script for Ubuntu 22.04
# Applies to all nodes (control-plane and workers)

set -e  # Exit immediately if a command exits with a non-zero status

# Detect if DNS is available
DNS_AVAILABLE=false
if host k8s-0.robirentsoft.com &>/dev/null; then
    DNS_AVAILABLE=true
fi

### 1️⃣ Configure Hosts ###
if [ "$DNS_AVAILABLE" = false ]; then
    echo "🔹 DNS is not available, adding entries to /etc/hosts"
    cat <<EOF | sudo tee -a /etc/hosts
192.168.4.100   k8s-0
192.168.4.101   k8s-1
192.168.4.102   k8s-2
192.168.4.103   k8s-3
EOF
else
    echo "✅ DNS is available, skipping /etc/hosts modifications"
fi

### 2️⃣ Disable Swap ###
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

### 3️⃣ Load Required Kernel Modules ###
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

### 4️⃣ Set sysctl Parameters ###
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

### 5️⃣ Install Containerd ###
sudo apt-get update
sudo apt-get install -y containerd

# Configure Containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

### 6️⃣ Install Kubernetes Components ###
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Add Kubernetes GPG Key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes Repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl containerd

# Enable kubelet service
sudo systemctl enable --now kubelet

# The cluster initialization and joining process has been moved to a separate script
echo "✅ System setup complete. Now run 'k8s-init-join.sh' on all nodes."
