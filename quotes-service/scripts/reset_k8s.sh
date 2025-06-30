#!/bin/bash

echo "🔄 Running kubeadm reset..."
sudo kubeadm reset -f

echo "🧹 Cleaning up CNI network interfaces..."
sudo ip link delete cni0 2>/dev/null || true
sudo ip link delete flannel.1 2>/dev/null || true
sudo ip link delete cali0 2>/dev/null || true
sudo ip link delete cali* 2>/dev/null || true

echo "🧹 Flushing iptables rules..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

echo "🧹 Removing Kubernetes and CNI state..."
sudo rm -rf /etc/cni/net.d
sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet/*
sudo rm -rf /var/lib/etcd

echo "🧹 Removing local kubeconfig..."
rm -rf $HOME/.kube

echo "✅ Kubernetes reset complete."
echo "👉 Consider restarting kubelet if needed: sudo systemctl restart kubelet"
