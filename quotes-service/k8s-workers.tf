# ----------------------------------------------------
# Worker NODES
# ----------------------------------------------------

# Launch Template for Worker Nodes
resource "aws_launch_template" "workers_lt" {
  name_prefix            = "k8s-worker-" # Each template will have a unique name starting with this prefix
  image_id               = var.node_config["worker"].ami_id
  instance_type          = var.node_config["worker"].instance_type # For production workloads, consider t3.medium or larger based on resource needs (CPU, memory).
  key_name               = aws_key_pair.k8s_key_pair.key_name      # SSH key pair to access the worker nodes (used for debugging or manual operations)
  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]   # Controls inbound/outbound traffic; should allow necessary ports (e.g., 10250 for kubelet, nodeport range, etc.)

  user_data = base64encode(file("${path.module}/scripts/user_data_worker.sh"))
  # User data script that runs on instance boot; typically contains 'kubeadm join' or equivalent setup commands.
  # Ensure this script is idempotent or design for reboots.

  tag_specifications {
    resource_type = "instance" # These tags apply to EC2 instances created by this template

    tags = {
      Name = "k8s-worker" # Helps with easy identification in AWS console or CLI
      Role = "worker"     # Useful for IAM policies, cost allocation, or automation
    }
  }
}
# ----------------------------------------------------
# Auto Scaling Group for Worker Nodes
# ----------------------------------------------------
resource "aws_autoscaling_group" "workers_asg" {
  name = "k8s-workers-asg-${random_string.asg_suffix.result}"
  # ASG name; random suffix ensures uniqueness across multiple deployments
  min_size            = var.worker_min_size         # Minimum worker count; e.g., 2 for HA Kubernetes
  max_size            = var.worker_max_size         # Maximum worker count; set based on expected peak load
  desired_capacity    = var.worker_desired_capacity # Target worker count at creation; typically = min_size
  vpc_zone_identifier = aws_subnet.worker_priv[*].id
  # List of private subnets where workers will launch. 
  # Private subnets recommended to prevent direct internet exposure.

  health_check_type = "EC2"
  # Health checks based on EC2 instance status; for tighter Kubernetes integration, consider ELB health checks if using load balancer.

  force_delete = true
  # Allows the ASG and associated instances to be deleted without waiting (useful for CI pipelines or test environments; use carefully in production).

  launch_template {
    id      = aws_launch_template.workers_lt.id # Attach the launch template defined above
    version = "$Latest"                         # Always use the most recent template version (ensure backward compatibility if template changes)
  }

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true # Automatically apply this tag to EC2 instances created by ASG
  }

  tag {
    key                 = "Role"
    value               = "worker"
    propagate_at_launch = true # Automatically apply this tag to EC2 instances created by ASG
  }

  lifecycle {
    create_before_destroy = true
    # Ensures that a new ASG is created before the old one is destroyed (zero downtime during updates or changes)
  }
}

# ----------------------------------------------------
# (Optional) Scaling Policies
# ----------------------------------------------------

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "workers-scale-out"                    # Scaling policy name for increasing capacity
  autoscaling_group_name = aws_autoscaling_group.workers_asg.name # The ASG this policy targets
  adjustment_type        = "ChangeInCapacity"                     # Directly changes the number of instances
  scaling_adjustment     = 1                                      # Adds one worker node on scale-out
  cooldown               = 300                                    # Prevents subsequent scaling actions for 5 minutes; adjust based on workload stabilization time
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "workers-scale-in"                     # Scaling policy name for decreasing capacity
  autoscaling_group_name = aws_autoscaling_group.workers_asg.name # The ASG this policy targets
  adjustment_type        = "ChangeInCapacity"                     # Directly changes the number of instances
  scaling_adjustment     = -1                                     # Removes one worker node on scale-in
  cooldown               = 300                                    # Prevents subsequent scaling actions for 5 minutes; adjust to avoid flapping
}

