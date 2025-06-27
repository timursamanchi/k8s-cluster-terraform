#!/bin/bash
set -e

# Disable swap (required by Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Kubernetes signing key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# Add Kubernetes apt repo (using Jammy as closest match for Noble)
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-jammy main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update again and install Kubernetes + containerd from Ubuntu repo
sudo apt-get update
sudo apt-get install -y containerd kubelet kubeadm kubectl

# Enable and start containerd
sudo systemctl enable --now containerd

# Mark Kubernetes packages on hold to avoid unintended upgrades
sudo apt-mark hold kubelet kubeadm kubectl

