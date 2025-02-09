#!/bin/bash

# Kubernetes Tools Installer Script
# This script provides a menu to install various Kubernetes components

set -e  # Exit immediately if a command exits with a non-zero status

install_helm() {
    if command -v helm &> /dev/null; then
        echo "✅ Helm is already installed. Skipping installation."
        return
    fi

    echo "🚀 Installing Helm..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "✅ Helm installed!"
}

install_kubectl() {
    if command -v kubectl &> /dev/null; then
        echo "✅ kubectl is already installed. Skipping installation."
        return
    fi

    echo "🚀 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "✅ kubectl installed!"
}

install_k9s() {
    if command -v k9s &> /dev/null; then
        echo "✅ k9s is already installed. Skipping installation."
    else
        echo "🚀 Installing k9s..."

        OS_TYPE="$(uname -s)"
        
        if [[ "$OS_TYPE" == "Linux" ]]; then
            curl -sS https://webinstall.dev/k9s | bash
            export PATH="$HOME/.local/bin:$PATH"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        elif [[ "$OS_TYPE" == "Darwin" ]]; then
            brew install k9s
        else
            echo "❌ Unsupported OS: $OS_TYPE"
            return 1
        fi

        echo "✅ k9s installed!"
    fi

    if [[ "$OS_TYPE" == "Linux" ]]; then
        source ~/.config/envman/PATH.env 2>/dev/null || true
    fi

    read -p "Do you want to run k9s now? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        k9s
    else
        echo "👍 You can run k9s later by typing 'k9s' in the terminal."
    fi
}

install_fzf() {
    if command -v fzf &>/dev/null; then
        echo "✅ fzf is already installed. Skipping installation."
        return
    fi

    echo "❌ fzf is not installed."

    read -p "Do you want to install fzf? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo "🚀 Installing fzf..."
        
        # Nustato, kokia sistema naudojama
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt update && sudo apt install -y fzf
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install fzf
        else
            echo "❌ Unsupported OS. Please install fzf manually."
            return 1
        fi

        echo "✅ fzf installed successfully!"
    else
        echo "⚠️ fzf installation skipped. Some features may not work."
    fi
}

install_metallb() {
    if ! kubectl cluster-info &>/dev/null; then
        echo "❌ No running Kubernetes cluster detected. Aborting MetalLB installation."
        return 1
    fi

    if kubectl get namespace metallb-system &>/dev/null; then
        echo "✅ MetalLB is already installed. Skipping installation."
        return
    fi

    echo "🚀 Installing MetalLB..."
    kubectl create namespace metallb-system
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
    echo "✅ MetalLB installed!"
}

configure_metallb() {
    echo "🚀 Configuring MetalLB..."
    
    if ! kubectl cluster-info &>/dev/null; then
        echo "❌ Kubernetes cluster is not running! Please start the cluster first."
        return 1
    fi
    
    DEFAULT_IP=$(hostname -I | awk '{print $1}')
    
    read -p "Enter MetalLB IP range (default: $DEFAULT_IP/32): " METALLB_IP
    METALLB_IP=${METALLB_IP:-$DEFAULT_IP/32}
    
    cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - $METALLB_IP
EOF

    cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-advertisement
  namespace: metallb-system
EOF
    
    echo "✅ MetalLB configured with IP range: $METALLB_IP"
}

install_ingress() {
    if ! kubectl cluster-info &>/dev/null; then
        echo "❌ No running Kubernetes cluster detected. Aborting NGINX Ingress Controller installation."
        return 1
    fi

    if kubectl get namespace ingress-nginx &>/dev/null; then
        echo "✅ NGINX Ingress Controller is already installed. Skipping installation."
        return
    fi

    echo "🚀 Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
    echo "✅ NGINX Ingress Controller installed!"
}

setup_ingress_test() {
    echo "🚀 Setting up a test Ingress..."
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - host: test.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: test-service
            port:
              number: 80
EOF
    echo "✅ Test Ingress created!"
}

copy_kubectl_config() {
    echo "🚀 Copying admin.conf from control plane..."
    read -p "Enter the control plane node hostname or IP: " CONTROL_PLANE
    if [ -z "$CONTROL_PLANE" ]; then
        echo "❌ No input provided. Aborting."
        return 1
    fi
    scp "$CONTROL_PLANE:/etc/kubernetes/admin.conf" ~/.kube/config
    chmod 600 ~/.kube/config
    export KUBECONFIG=~/.kube/config
    echo "✅ admin.conf copied successfully!"
}

delete_kubectl_config() {
    echo "🚀 Deleting local kubectl config..."
    rm -f ~/.kube/config
    unset KUBECONFIG
    echo "✅ Local kubectl config deleted!"
}

show_system_info() {
    echo "🔍 Showing system info..."
    uname -a
    kubectl version --client
}

view_pod_logs() {
    if ! kubectl cluster-info &>/dev/null; then
        echo "❌ No running Kubernetes cluster detected. Cannot view pod logs."
        return 1
    fi

    echo "🔍 Fetching pod list..."
    PODS=$(kubectl get pods -A --no-headers)
    
    if [[ -z "$PODS" ]]; then
        echo "❌ No pods found in the cluster."
        return 1
    fi

    if command -v fzf &>/dev/null; then
        echo "🔍 Select a pod using fzf..."
        SELECTED_POD=$(echo "$PODS" | fzf | awk '{print $1 " " $2}')
        NAMESPACE=$(echo "$SELECTED_POD" | awk '{print $1}')
        POD_NAME=$(echo "$SELECTED_POD" | awk '{print $2}')
    else
        kubectl get pods -A
        read -p "Enter the namespace: " NAMESPACE
        read -p "Enter the pod name: " POD_NAME
    fi

    # Patikrina, ar vartotojas įvedė namespace ir pod'o pavadinimą
    if [[ -z "$NAMESPACE" || -z "$POD_NAME" ]]; then
        echo "❌ Invalid input. Namespace and pod name cannot be empty."
        return 1
    fi

    echo "📜 Fetching logs for pod $POD_NAME in namespace $NAMESPACE..."
    kubectl logs -n "$NAMESPACE" "$POD_NAME"
}

show_menu() {
    echo "========================================"
    echo "  Kubernetes Tools Installer"
    echo "========================================"
    echo "1️⃣  Install Helm"
    echo "2️⃣  Install kubectl"
    echo "3️⃣  Install k9s"
    echo "4️⃣  Install fzf"
    echo "5️⃣  Install MetalLB"
    echo "6️⃣  Configure MetalLB"
    echo "7️⃣  Install NGINX Ingress Controller"
    echo "8️⃣  Create a test Ingress"
    echo "9️⃣  Copy kubectl config from control plane"
    echo "🔟  Delete local kubectl config"
    echo "1️⃣1️⃣  View pod logs"
    echo "1️⃣2️⃣  Show system information"
    echo "========================================"
    read -p "Select an option: " choice
    case $choice in
        1) install_helm ;;
        2) install_kubectl ;;
        3) install_k9s ;;
        4) install_fzf ;;
        5) install_metallb ;;
        6) configure_metallb ;;
        7) install_ingress ;;
        8) setup_ingress_test ;;
        9) copy_kubectl_config ;;
        10) delete_kubectl_config ;;
        11) view_pod_logs ;;
        12) show_system_info ;;
        *) echo "❌ Invalid option!"; show_menu ;;
    esac
}

show_menu
