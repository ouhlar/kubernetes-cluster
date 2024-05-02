# ENVIRONMENT FOR CONTAINER ORCHESTRATION AT THE UNIVERSITY

This `README.md` document provides instructions on how to locally deploy a Kubernetes cluster for university infrastructure purposes. The script defined in Ruby using the Vagrant tool serves to automate the setup of virtual machines (VMs) that will function as nodes of the Kubernetes cluster.

## Deployment of the Kubernetes Cluster

The deployment process of the Kubernetes cluster is crucial for the successful creation of a robust and flexible container orchestration environment. The following steps provide a guide to establishing the cluster, from the basic requirements to starting and accessing the nodes.

### Requirements

Environment:

- Virtualbox 7.0.6
- Vagrant 2.4.1
- Ruby

Minimum requirements for the nodes:

- 2 CPUs
- 2 GB RAM
- 2 GB of free disk space

### Configuration

All specifications for the virtual machines are loaded from an external YAML file, `vagrant_config.yaml`. This file should contain configurations such as the number of master and worker nodes, their hardware specifications, IP addresses, and scripts needed for their setup.

### Installation and Running

1. Install all necessary dependencies (Vagrant, VirtualBox, Ruby).
2. Clone this repository or download the Vagrant script and the corresponding `vagrant_config.yaml` configuration file.
3. Open a terminal and navigate to the folder containing `Vagrantfile`.
4. Run the following commands to initialize and launch the virtual machines:

    ```bash
    vagrant up
    ```

    This command will sequentially start and configure all defined VMs as nodes of the Kubernetes cluster according to the settings in the YAML configuration file.
5. After successful cluster startup, you can access individual nodes using the command:

    ```bash
    vagrant ssh <node_name>
    ```

## Deployment of a Student Container

Part of the infrastructure can also be used for deploying student containers, which can be used for educational purposes or individual projects. The following section provides an example of Deployment and Service configurations for Kubernetes, which allow running and exposing a student container.

### Deployment Configuration

The `deployment.yaml` file defines a Kubernetes Deployment that automates the deployment and management of student containers. This configuration file creates a deployment with one replica of the container `uhlaro/student_container:latest`. The container will have port 22 open, which is commonly used for SSH (Secure Shell) connections.

### Service Configuration

The `expose_ssh_service.yaml` file defines a Kubernetes Service that allows access to the SSH port of the deployed container from the external network. The Service creates a NodePort that exposes the SSH port on the cluster, allowing students to connect to their containers from the external network.

### Deployment Procedure

1. Prepare the Kubernetes cluster according to the previous steps in this document.
2. Save the above-mentioned configuration files (`deployment.yaml` and `expose_ssh_service.yaml`) in your working directory.
3. Apply the configurations in the cluster using kubectl commands:

    ```bash
    kubectl apply -f deployment.yaml
    kubectl apply -f expose_ssh_service.yaml
    ```

4. Check the status of deployed resources:

    ```bash
    kubectl get pods
    kubectl get services
    ```

5. Find out which NodePort the SSH service is available on:

    ```bash
    kubectl get service student-container-service
    ```

6. Use the corresponding NodePort and the IP address of the cluster's worker node to connect to the student container via SSH.

7. To remotely connect to the student container via SSH, use the command in the following format, replacing `<Node_IP>` with the IP address of the cluster's worker node and `<NodePort>` with the NodePort assigned to your service (obtained using the previous `kubectl get service` command). For local deployments, you may need to add port forwarding in the network settings of the worker node.

    ```bash
    ssh -p <NodePort> user@<Node_IP>
    ```

### Additional Information

- If you want to scale the deployment and allow more students to use the containers, change the `replicas` value in the `deployment.yaml` file.
- To secure access, you can configure authentication using SSH keys instead of passwords.
- To make containers available on the standard SSH port (22), you can use a LoadBalancer service if available, or set up reverse proxy rules on the university firewall or router.

### Cleaning up the Environment

After completing work or if you want to remove deployed resources, use the following commands:

```bash
kubectl delete service student-container-service
kubectl delete deployment deployment-example
```

These commands will remove the service and the deployment of the student container, thereby freeing up resources on the cluster for other purposes.

For local Kubernetes clusters deployed using Vagrant, you can also clean up the virtual machines by running:

```bash
vagrant destroy -f
```

This command will forcefully shut down and destroy all the virtual machines created by Vagrant, effectively cleaning up your local environment.
