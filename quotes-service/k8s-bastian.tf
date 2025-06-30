#######################################
# BASTION IN PUBLIC SUBNET FOR SSH
#######################################
resource "aws_instance" "bastion" {
  ami                         = var.node_config["bastion"].ami_id
  instance_type               = var.node_config["bastion"].instance_type
  count                       = var.node_config["bastion"].count
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_bastion_sg.id]
  associate_public_ip_address = true

  # Distribute bastions across public subnets / AZs
  subnet_id = element(
    aws_subnet.public[*].id,
    count.index % length(aws_subnet.public)
  )

  tags = {
    Name = "k8s-bastion-${count.index + 1}" # Make names unique for each bastion
    Role = "bastion"
    AZ = element(
      aws_subnet.public[*].availability_zone,
      count.index % length(aws_subnet.public)
    )
  }
}
#######################################
