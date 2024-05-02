#!/bin/bash -e

# Kubernetes Initialization Setup Script
# This script is intended to prepare a node for Kubernetes by disabling swap,
# configuring the hosts file, setting up required system settings, and installing
# necessary packages including Docker container runtime.

# Version variables
KUBE_VERSION="1.29.1-1.1"

# IP addresses for the master and worker nodes
MASTER_NODE_IP="10.10.0.10"
WORKER_NODE_IP="10.10.0.20"

# Disable swap to ensure Kubernetes works correctly
disable_swap() {
    echo "Disabling swap..."
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
}

# Configure /etc/hosts file with the IPs of master and worker nodes
configure_hosts_file() {
    echo "Configuring /etc/hosts..."
    cat <<EOF | sudo tee /etc/hosts
127.0.0.1 localhost
$MASTER_NODE_IP master-node-1
$WORKER_NODE_IP worker-node-1
EOF
}

# Load required kernel modules and configure sysctl for Kubernetes
configure_sysctl() {
    echo "Configuring sysctl for Kubernetes..."
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
    sudo modprobe overlay
    sudo modprobe br_netfilter

    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
    sudo sysctl --system
}

# Install required packages such as kubeadm, kubelet, and kubectl
install_required_packages() {
    echo "Installing required packages..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update
    sudo apt install -y kubeadm=${KUBE_VERSION} kubelet=${KUBE_VERSION} kubectl=${KUBE_VERSION}
}

# Install Docker container runtime and configure it for Kubernetes
install_docker_runtime() {
    echo "Installing Docker container runtime..."
    sudo apt install docker.io -y
    sudo mkdir -p /etc/containerd
    sudo sh -c "containerd config default > /etc/containerd/config.toml"
    sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo systemctl restart kubelet
    sudo systemctl enable kubelet
}

# Execute the functions in order
disable_swap
configure_hosts_file
configure_sysctl
install_required_packages
install_docker_runtime