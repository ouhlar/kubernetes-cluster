#!/bin/bash -e

# Worker Node Initialization Script for Kubernetes Cluster
# This script runs the join command that allows a worker node to join an existing Kubernetes cluster.

# Function to get and execute the join command
get_join_command() {
    echo "Joining the Kubernetes cluster..."
    /vagrant/join_command.sh
}

# Execute the function to join the cluster
get_join_command

echo "Worker node initialization complete."