# -------------------------------
# LOCALS
# -------------------------------

locals {
  kube_install_script = <<-EOF
    #!/bin/bash
    set -e

    # Disable swap
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab

    # Load kernel modules
    modprobe br_netfilter
    echo 'br_netfilter' > /etc/modules-load.d/k8s.conf

    # Set sysctl params
    cat <<SYSCTL_EOF | tee /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward = 1
    SYSCTL_EOF
    sysctl --system

    # Install Docker
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Configure containerd
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd

    # Install Kubernetes
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    systemctl enable kubelet
  EOF
}