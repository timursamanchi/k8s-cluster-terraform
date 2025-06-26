# -------------------------------
# SSH KEY PAIR
# -------------------------------
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  content              = tls_private_key.ec2_key.private_key_pem
  filename             = "${path.module}/${var.key_name}.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}

# -------------------------------
# MASTER NODE
# -------------------------------
resource "aws_instance" "master" {
  ami                         = var.custom_ami_id
  instance_type               = "t3.medium"
  subnet_id                   = element(aws_subnet.public[*].id, 0)
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
    Role = "master"
    AZ   = element(aws_subnet.public[*].availability_zone, 0)
  }
}

# -------------------------------
# WORKER NODES
# -------------------------------
resource "aws_instance" "workers" {
  count                       = 2
  ami                         = var.custom_ami_id
  instance_type               = "t3.medium"
  subnet_id                   = element(aws_subnet.public[*].id, count.index + 1)
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
    AZ   = element(aws_subnet.public[*].availability_zone, count.index + 1)
  }

}
# -------------------------------
resource "local_file" "access_script" {
  filename        = "${path.module}/connect_k8s.sh"
  file_permission = "0755"

  content = <<EOT
#!/bin/bash

echo "Setting PEM file permissions..."
chmod 400 ${var.key_name}.pem

echo ""
echo "SSH into master:"
ssh -i ${var.key_name}.pem ubuntu@${aws_instance.master.public_ip}

echo ""
echo "SSH into workers:"
EOT
}

resource "null_resource" "append_worker_ssh_commands" {
  count = length(aws_instance.workers)

  triggers = {
    worker_ip = aws_instance.workers[count.index].public_ip
  }

  provisioner "local-exec" {
    command = <<EOT
echo 'ssh -i ${var.key_name}.pem ubuntu@${aws_instance.workers[count.index].public_ip}' >> connect_k8s.sh
EOT
  }

  depends_on = [local_file.access_script]
}
# -------------------------------