locals {
  controller_count = var.k8s_controller_count
  az_count         = length(data.aws_availability_zones.available.names)
  subnet_count     = min(local.controller_count, local.az_count)
}
# ----------------------------------------------------
# GENERATE connect_k8s.sh
# ----------------------------------------------------
resource "local_file" "connect_k8s" {
  filename        = "${path.module}/scripts/connect_k8s.sh"
  file_permission = "0755"
  content         = <<-EOT
    #!/bin/bash

    echo "Setting PEM file permissions..."
    chmod 400 ../pems/k8s-key-pair.pem

    echo ""
    echo "SSH into masters:"
    %{ for m in aws_instance.controller  ~}
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/k8s-key-pair.pem ubuntu@${m.public_ip}
    %{ endfor ~}

    echo ""
    echo "Use AWS CLI or console to get their public IPs."
  EOT
}