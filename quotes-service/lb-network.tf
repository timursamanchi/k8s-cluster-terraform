# Network Load Balancer INTERNAL for Kubernetes API - on Private Subnet
resource "aws_lb" "k8s_api_nlb" {
  name               = "k8s-api-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.controller_priv[*].id  # NLB spans private controller subnets
  tags = {
    Name = "k8s-api-nlb"
  }
}

# Target group for the API servers (port 6443)
resource "aws_lb_target_group" "k8s_api_tg" {
  name        = "k8s-api-tg"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = aws_vpc.k8s.id
  target_type = "instance"
  health_check {
    protocol = "TCP"
    port     = "6443"
  }
  tags = {
    Name = "k8s-api-tg"
  }
}

# Register controllers in the target group
resource "aws_lb_target_group_attachment" "k8s_api_attachment" {
  count            = var.k8s_controller_count
  target_group_arn = aws_lb_target_group.k8s_api_tg.arn
  target_id        = aws_instance.controller[count.index].id
  port             = 6443
}
