#!/bin/bash
# Run this on BOTH master and worker. Identical setup on both -
# the only thing that differs later is which node runs `kubeadm init`
# vs `kubeadm join`.

set -euxo pipefail

# -----------------------------------------------------------------------
# 1. Disable swap - kubelet refuses to start with swap enabled, since
#    swap breaks the memory guarantees Kubernetes makes to pods
# -----------------------------------------------------------------------
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# -----------------------------------------------------------------------
# 2. Load required kernel modules and sysctl params for K8s networking
# -----------------------------------------------------------------------
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# -----------------------------------------------------------------------
# 3. Install containerd (the container runtime kubelet talks to)
# -----------------------------------------------------------------------
sudo apt-get update
sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# kubeadm requires the SystemdCgroup driver to match kubelet's default
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# -----------------------------------------------------------------------
# 4. Install kubeadm, kubelet, kubectl (pinned to a specific stable
#    version so master and worker never drift apart)
# -----------------------------------------------------------------------
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Installation complete. Versions installed:"
kubeadm version
kubelet --version
kubectl version --client
