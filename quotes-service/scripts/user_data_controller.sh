#!/bin/bash
set -e

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install packages
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Kubernetes signing key + repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-jammy main" > /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes + containerd
apt-get update
apt-get install -y containerd kubelet kubeadm kubectl
systemctl enable --now containerd
apt-mark hold kubelet kubeadm kubectl

# Init master
kubeadm init --pod-network-cidr=192.168.0.0/16

# Setup kubeconfig for ubuntu
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
