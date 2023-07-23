#!/bin/bash

# Log file path
LOG_FILE="kubernetes_setup_log.txt"
KUBERNETES_VERSION="1.27.1-00"

# Disable swap
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# Check if lsb_release is installed
if ! command -v lsb_release &> /dev/null; then
  echo "lsb_release command is not installed. Please install it to continue."
  exit 1
fi

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check for necessary commands
commands=(curl tee modprobe sysctl apt-key)
for cmd in "${commands[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd is not installed. Please install it to continue."
    exit 1
  fi
done

# Cool ASCII art for the script header - Happy Smiley Face
cat << "EOF"
:-) Kubernetes Cluster Setup :-)

EOF

# Function to execute commands and log the output
function execute_command {
  local command="$1"
  echo "Executing: $command"
  echo "Executing: $command" >> "$LOG_FILE"
  eval "$command" >> "$LOG_FILE" 2>&1
  local status=$?
  if [ $status -eq 0 ]; then
    echo "Command executed successfully."
  else
    echo "Error occurred. Please check the log file: $LOG_FILE"
    exit 1
  fi
}

# Update and upgrade the system
execute_command "apt-get update && apt-get upgrade -y"

# Load the Kernel modules on all the nodes
execute_command "tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF"

execute_command "modprobe overlay"
execute_command "modprobe br_netfilter"

# Set Kernel params for Kubernetes
execute_command "tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF"

# Reload the system changes
execute_command "sysctl --system"

# Install containerd runtime
execute_command "apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates"

execute_command "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg"

execute_command "add-apt-repository -y 'deb [arch=amd64] https://download.docker.com/linux/ubuntu '$(lsb_release -cs)' stable'"

# Update apt index after adding the repository
execute_command "apt update"

execute_command "apt install -y containerd.io"

# Configure containerd using systemd as cgroup
execute_command "containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1"

execute_command "sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml"

execute_command "systemctl restart containerd"
execute_command "systemctl enable containerd"

# Add apt repository for Kubernetes
execute_command "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
execute_command "apt-add-repository -y 'deb http://apt.kubernetes.io/ kubernetes-xenial main'"

# Update apt index after adding the repository
execute_command "apt update"

execute_command "apt install -y kubelet=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION"
execute_command "apt-mark hold kubelet kubeadm kubectl"

# Cool success message with blinking text
echo -e "\e[5m\e[1mKubernetes Cluster Setup is complete!\e[0m"
echo "Kubernetes Cluster Setup is complete!" >> "$LOG_FILE"

# Prompt the user to run "kubeadm init" and then join worker nodes (if applicable)
echo -e "Please run \e[1m'kubeadm init'\e[0m to initialize the Kubernetes master node."
echo "Please run 'kubeadm init' to initialize the Kubernetes master node." >> "$LOG_FILE"

echo -e "After successful initialization, you will get a command to join worker nodes to the cluster."
echo "After successful initialization, you will get a command to join worker nodes to the cluster." >> "$LOG_FILE"

# Cool ASCII art for the end of the script - Happy Smiley Face
cat << "EOF"
:-) Kubernetes Cluster Setup :-)

EOF

