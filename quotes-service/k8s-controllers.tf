# ----------------------------------------------------
# controller NODE
# ----------------------------------------------------
resource "aws_instance" "controller" {
  count                       = var.node_config["controller"].count
  ami                         = var.node_config["controller"].ami_id
  instance_type               = var.node_config["controller"].instance_type
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_controller_sg.id]
  associate_public_ip_address = true

  subnet_id = element(
    aws_subnet.public[*].id,
    count.index % length(aws_subnet.public)
  )

  tags = {
    Name = "k8s-controller-${count.index + 1}"
    Role = "controller"
    AZ = element(
      aws_subnet.public[*].availability_zone,
      count.index % length(aws_subnet.controller_priv) # Assigns the availability zone based on the subnet index
    )
  }

  user_data = file("${path.module}/scripts/hello-world.sh")
}