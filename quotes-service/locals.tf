locals {
  controller_count = var.k8s_controller_count
  az_count         = length(data.aws_availability_zones.available.names)
  subnet_count     = min(local.controller_count, local.az_count)
}
# ----------------------------------------------------
# GENERATE controller_connect_k8s.sh
# ----------------------------------------------------
resource "local_file" "controller_connect_k8s" {
  filename        = "${path.module}/scripts/controller_connect_k8s.sh"
  file_permission = "0755"
  content         = <<-EOT
    #!/bin/bash

    echo "Setting PEM file permissions..."
    chmod 400 ../pems/k8s-key-pair.pem

    echo ""
    echo "SSH into masters:"
    %{for m in aws_instance.controller~}
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/k8s-key-pair.pem ubuntu@${m.public_ip}
    %{endfor~}

    echo ""
    echo "Use AWS CLI or console to get their public IPs."
  EOT
}

# ----------------------------------------------------
# GENERATE bastians_connect_k8s.sh
# ----------------------------------------------------
resource "local_file" "bastians_connect_k8s" {
  filename        = "${path.module}/scripts/bastian_connect_k8s.sh"
  file_permission = "0755"

  content = <<-EOT
    #!/bin/bash

    echo "Setting PEM file permissions..."
    chmod 400 ../pems/${var.key_name}.pem

    echo ""
    echo "SSH into bastion:"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/${var.key_name}.pem ubuntu@${aws_instance.bastion[0].public_dns}

    echo ""
    echo "SSH into controllers:"
    %{for m in aws_instance.controller~}
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/${var.key_name}.pem ubuntu@${m.public_ip}
    %{endfor~}

    echo ""
    echo "Use AWS CLI or console to get their public IPs if needed."
  EOT
}
# ----------------------------------------------------