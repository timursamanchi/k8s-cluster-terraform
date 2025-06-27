
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
                    echo "SSH into master:"
                    ssh -i k8s-key-pair.pem ubuntu@${aws_instance.master.public_ip}

                    echo ""
                    echo "SSH into workers:"
                    %{ for worker in aws_instance.workers ~}
                    ssh -i k8s-key-pair.pem ubuntu@${worker.public_ip}
                    %{ endfor ~}
                    EOT
}