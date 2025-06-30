resource "null_resource" "create_pems_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/pems"
  }
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${path.module}/pems/${var.key_name}.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "0400"

  depends_on = [null_resource.create_pems_dir]
}