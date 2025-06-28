
# ----------------------------------------------------
# MASTER NODE
# ----------------------------------------------------
resource "aws_instance" "master" {
  count                      = var.master_count
  ami                        = var.custom_ami_id
  instance_type              = "t3.medium"
  key_name                   = aws_key_pair.k8s_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  subnet_id = element(aws_subnet.public[*].id, count.index % length(aws_subnet.public))

  tags = {
    Name = "k8s-master-${count.index + 1}"
    Role = "master"
    AZ   = element(aws_subnet.public[*].availability_zone, count.index % length(aws_subnet.public))
  }

  user_data = file("${path.module}/scripts/master_user_data.sh")
}
# ----------------------------------------------------
# WORKER NODES
# ----------------------------------------------------
# Launch Template for Worker Nodes
resource "aws_launch_template" "workers_lt" {
  name_prefix   = "k8s-worker-"
  image_id      = var.custom_ami_id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.k8s_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # Base64-encode user_data when using launch template
  user_data = base64encode(file("${path.module}/scripts/worker_user_data.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "k8s-worker"
      Role = "worker"
    }
  }
}
# ----------------------------------------------------
# Auto Scaling Group for Worker Nodes
resource "aws_autoscaling_group" "workers_asg" {
  name                  = "k8s-workers-asg"
  min_size              = var.worker_min_size
  max_size              = var.worker_max_size
  desired_capacity       = var.worker_desired_capacity
  vpc_zone_identifier    = aws_subnet.public[*].id
  health_check_type      = "EC2"
  force_delete           = true

  launch_template {
    id      = aws_launch_template.workers_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "worker"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------------------
# (Optional) Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "workers-scale-out"
  autoscaling_group_name  = aws_autoscaling_group.workers_asg.name
  adjustment_type         = "ChangeInCapacity"
  scaling_adjustment      = 1
  cooldown                = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "workers-scale-in"
  autoscaling_group_name  = aws_autoscaling_group.workers_asg.name
  adjustment_type         = "ChangeInCapacity"
  scaling_adjustment      = -1
  cooldown                = 300
}

