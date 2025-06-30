#######################################
# BASTION SECURITY GROUP
#######################################
resource "aws_security_group" "k8s_bastion_sg" {
  # Creates a security group for the bastion host
  # This SG allows limited inbound SSH and all outbound traffic
  # Bastion is used to access the private controllers and workers
  # It should be in the public subnet to allow SSH access from the internet
  name   = "k8s-bastion-sg"
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s-bastion-sg"
  }
}

resource "aws_security_group_rule" "bastion_ssh_in" {
  # Allows SSH (port 22) inbound to bastion, only from your IP
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ssh_cidr] # Now using variable for flexibility
  security_group_id = aws_security_group.k8s_bastion_sg.id
}

resource "aws_security_group_rule" "bastion_all_out" {
  # Allows all outbound traffic from bastion (e.g., to controllers, internet)
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_bastion_sg.id
}

#######################################
# CONTROLLER SECURITY GROUP
#######################################
resource "aws_security_group" "k8s_controller_sg" {
  # Creates a security group for Kubernetes control plane nodes (masters/controllers)
  name   = "k8s-controller-sg"
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s-controller-sg"
  }
}

resource "aws_security_group_rule" "controller_ssh_in" {
  # Allows SSH (port 22) from bastion to controllers
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_bastion_sg.id
  security_group_id        = aws_security_group.k8s_controller_sg.id
}

resource "aws_security_group_rule" "controller_worker_in" {
  # Allows kubelet traffic from workers to controller (10250)
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_worker_sg.id
  security_group_id        = aws_security_group.k8s_controller_sg.id
}

resource "aws_security_group_rule" "controller_all_out" {
  # Allows controllers to initiate any outbound connection
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_controller_sg.id
}

#######################################
# WORKER SECURITY GROUP
#######################################
resource "aws_security_group" "k8s_worker_sg" {
  # Creates a security group for worker nodes
  name   = "k8s-worker-sg"
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s-worker-sg"
  }
}

resource "aws_security_group_rule" "worker_ssh_in" {
  # Allows SSH (port 22) from bastion to workers
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_bastion_sg.id
  security_group_id        = aws_security_group.k8s_worker_sg.id
}

resource "aws_security_group_rule" "worker_all_out" {
  # Allows workers to initiate any outbound connection
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_worker_sg.id
}
#######################################
