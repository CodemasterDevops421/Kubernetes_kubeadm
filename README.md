
# Kubernetes Cluster Setup Guide

## Prerequisites
Before you start setting up your Kubernetes cluster, make sure you have the following:

- Ubuntu 18.04 or higher: This is the operating system we will be using for this guide. It's similar to needing a specific type of venue to host an event.
- User with sudo privileges: This is like having administrative access or the "keys to the venue".

- 2 AWS EC2 instances:
  - Master (2 CPU, 2GB RAM) - t2.micro
  - Worker (1 CPU, 2GB RAM) - t2.small

- Server network (10.*.*.*) and pod network 192.*.*.* - Since we are setting up servers in cloud servers, open necessary ports.

## Key Components of Kubernetes
Here are the key parts of Kubernetes without the explanations:

- Pods
- Nodes
- Services
- Volumes
- Namespaces
- Ingress
- ConfigMaps
- Secrets

## Step 1: Disable Swap
Before we start building our cluster, we need to disable swap on our system. This is a requirement for Kubernetes, like having to clear out any previous decorations before setting up a new event at a venue.

```
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
Step 2: Update System Packages
Just like how you would want to make sure your venue is clean and ready before hosting an event, you want to make sure your system is up-to-date before installing new software.
````


```
sudo apt-get update && apt-get upgrade -y
Step 3: Load Kernel Modules
```
Next, we load the necessary Kernel modules on all nodes. This is like setting up the necessary equipment or facilities at your venue.

```
sudo tee /etc/modules-load.d/containerd.conf <<EOF 
overlay 
br_netfilter 
EOF
sudo modprobe overlay 
sudo modprobe br_netfilter
```
Step 4: Set Kernel Parameters
Setting the Kernel parameters for Kubernetes is like setting the rules or guidelines for your event. It helps ensure that everything runs smoothly.

```
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
net.ipv4.ip_forward = 1 
EOF
sudo sysctl --system
```

Step 5: Install containerd Runtime

Next, we install containerd runtime. containerd is an industry-standard container runtime with an emphasis on simplicity, robustness, and portability. It's like hiring a trusted event company to manage the logistics of your event.

The use of HTTPS for repositories and GPG keys for packages enhances the security of the setup process. It's like having security checks at your event to ensure only invited guests can enter.

```
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'
sudo apt update
sudo apt install -y containerd.io
```

Configure containerd using systemd as cgroup. Cgroups (short for control groups) is a Linux kernel feature to limit, account, and isolate resource usage (CPU, memory, disk I/O, etc.) of process groups.

When you configure containerd to use systemd as the cgroup driver, you're telling containerd to use systemd to manage and isolate the resources of the containers it runs.

```
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

Step 6: Install Kubernetes
Now, we install Kubernetes. This is like hiring the event manager who will oversee all the operations of your event.

```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository -y 'deb http://apt.kubernetes.io/ kubernetes-xenial main'
sudo apt update
sudo apt install -y kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION
sudo apt-mark hold kubelet kubeadm kubectl
```

Step 7: Initialize the Kubernetes Master Node
Finally, you initialize the Kubernetes master node. This is like making the final checks and getting everything ready for the event to start.

```
kubeadm init
```
