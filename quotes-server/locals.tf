
# ----------------------------------------------------
# GENERATE connect_k8s.sh
# ----------------------------------------------------
resource "local_file" "connect_k8s" {
  filename        = "${path.module}/scripts/connect_k8s.sh"
  file_permission = "0755"
  content         = <<-EOT
    #!/bin/bash

    echo "Setting PEM file permissions..."
    chmod 400 k8s-key-pair.pem

    echo ""
    echo "SSH into masters:"
    %{ for m in aws_instance.master ~}
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i k8s-key-pair.pem ubuntu@${m.public_ip}
    %{ endfor ~}

    echo ""
    echo "Workers are managed by Auto Scaling Group: ${aws_autoscaling_group.workers_asg.name}"
    echo "Use AWS CLI or console to get their public IPs."
  EOT
}
# ----------------------------------------------------
