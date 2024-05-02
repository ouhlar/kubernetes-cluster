#!/bin/bash -e

# Master Node Initialization Script for Kubernetes Cluster
# This script will set up the Kubernetes master node by initializing the cluster,
# configuring kubectl, installing a network CNI, and creating a join command for worker nodes.

# Set the Pod Network CIDR variable for network communication between pods
POD_NETWORK_CIDR="10.10.0.0/16"
CALICO_VERSION="v3.27.2"

# Initialize the Kubernetes master node
initialize_master_node() {
    echo "Initializing the Kubernetes master node..."
    kubeadm config images pull
    local current_ip=$(/sbin/ip -o -4 addr list enp0s8 | awk '{print $4}' | cut -d/ -f1)
    kubeadm init --apiserver-advertise-address=${current_ip} --pod-network-cidr=${POD_NETWORK_CIDR}
}

# Configure kubectl for the current user
configure_kubectl() {
    echo "Configuring kubectl..."
    mkdir -p $HOME/.kube
    cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    echo "export KUBECONFIG=$HOME/.kube/config" | tee -a $HOME/.bashrc
    source $HOME/.bashrc
}

# Install the Calico CNI (Container Network Interface) plugin
install_network_cni() {
    echo "Installing Calico CNI plugin..."
    kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml"
    curl -sSL "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml" -o custom-resources.yaml
    sed -i 's|cidr: 192\.168\.0\.0/16|cidr: '${POD_NETWORK_CIDR}'|g' custom-resources.yaml
    kubectl create -f custom-resources.yaml
}

# Create the join command for worker nodes and save it to a file
create_join_command() {
    echo "Creating join command for worker nodes..."
    kubeadm token create --print-join-command | tee /vagrant/join_command.sh
    chmod +x /vagrant/join_command.sh
}

initialize_master_node
configure_kubectl
install_network_cni
create_join_command

echo "Master node initialization complete."