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
  subnet_id                   = aws_subnet.public[0].id

  tags = {
    Name = "k8s-bastion"
    Role = "bastion"
    AZ = element(
      aws_subnet.public[*].availability_zone,
      count.index % length(aws_subnet.public)
    )
  }
}
