
# ----------------------------------------------------
# MASTER NODE
# ----------------------------------------------------
resource "aws_instance" "master" {
  ami                        = var.custom_ami_id
  instance_type              = "t3.medium"
  subnet_id                  = element(aws_subnet.public[*].id, 0)
  key_name                   = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-master"
    Role = "master"
    AZ   = element(aws_subnet.public[*].availability_zone, 0)
  }

  user_data = file("${path.module}/scripts/master_user_data.sh")
}
# ----------------------------------------------------
# WORKER NODES
# ----------------------------------------------------
resource "aws_instance" "workers" {
  count                      = 2
  ami                        = var.custom_ami_id
  instance_type              = "t3.medium"
  subnet_id                  = element(aws_subnet.public[*].id, count.index + 1)
  key_name                   = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
    AZ   = element(aws_subnet.public[*].availability_zone, count.index + 1)
  }

  user_data = file("${path.module}/scripts/worker_user_data.sh")
}