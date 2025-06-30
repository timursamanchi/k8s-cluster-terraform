#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

touch /tmp/it-worked
echo "Create k8 controllers and installing apps: $(date '+%Y-%m-%d %H:%M:%S') - check /var/log/user-data" > /tmp/k8-welcome.txt

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

