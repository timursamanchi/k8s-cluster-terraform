resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_key_pair" {
  key_name   = "k8s-key-pair"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${path.module}/k8s-key-pair.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "0400"
}

resource "local_file" "public_key" {
  filename        = "${path.module}/k8s-key-pair.pub"
  content         = tls_private_key.ec2_key.public_key_openssh
  file_permission = "0644"
}