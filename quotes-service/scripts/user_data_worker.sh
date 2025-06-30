#!/bin/bash
set -e

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-jammy main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y containerd kubelet kubeadm kubectl
systemctl enable --now containerd
apt-mark hold kubelet kubeadm kubectl

# Worker will wait for kubeadm join (run manually or automate later)
