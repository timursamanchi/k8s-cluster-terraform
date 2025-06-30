# Application Load Balancer for Nginx Ingress - EXTERNAL for Public Subnets
resource "aws_lb" "ingress_alb" {
  name               = "k8s-ingress-alb"
  internal           = false  # This is now truly public... set to true if internal-only ingress
  load_balancer_type = "application"
  subnets            = aws_subnet.worker_priv[*].id  # ALB sits in worker's subnets for ingress
  enable_deletion_protection = false
  tags = {
    Name = "k8s-ingress-alb"
  }
}

# Target group for NGINX Ingress pods (NodePort or ClusterIP backed)
resource "aws_lb_target_group" "ingress_tg" {
  name        = "k8s-ingress-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.k8s.id
  target_type = "ip"  # Because NGINX Ingress pods will register themselves via annotations or controller logic
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "k8s-ingress-tg"
  }
}

# Example ALB listener forwarding to target group
resource "aws_lb_listener" "ingress_http" {
  load_balancer_arn = aws_lb.ingress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_tg.arn
  }
}
