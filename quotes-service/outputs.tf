# -------------------------------
# OUTPUTS
# -------------------------------

# Outputs the name of the SSH key pair used for the cluster instances.
# Useful for SSH connections or external documentation.
output "k8s_key_pair_name" {
  description = "The name of the generated key pair"
  value       = aws_key_pair.k8s_key_pair.key_name
}

# The public DNS name of the Application Load Balancer (ALB) used to expose apps via Ingress.
# Use this in DNS records or access it directly for app endpoints.
output "ingress_alb_dns" {
  description = "Public DNS of the Ingress ALB"
  value       = aws_lb.ingress_alb.dns_name
}

# The DNS name of the Network Load Balancer (NLB) used for Kubernetes API server access.
# Note: In your setup, this NLB is internal, so this DNS is resolvable only inside the VPC.
output "k8s_api_nlb_dns" {
  description = "DNS name of the Kubernetes API NLB"
  value       = aws_lb.k8s_api_nlb.dns_name
}

# The public Elastic IP assigned to your NAT Gateway.
# This is the public egress IP address that private subnets (controllers/workers) use for outbound traffic.
output "nat_gateway_eip" {
  description = "Elastic IP of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

# List of the IDs of the public subnets created.
# Useful for debugging, documentation, or other module references.
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

# List of the CIDR blocks of the public subnets.
# Good for visibility or passing to other modules that need public subnet ranges.
output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

# The path on disk where the connect_k8s.sh helper script is generated.
# This script typically provides SSH commands to connect to controllers (if public IPs) or through a bastion.
output "connect_script_path" {
  description = "Path to the generated connect_k8s.sh script"
  value       = "${path.module}/scripts/connect_k8s.sh"
}

output "workers_asg_name" {
  description = "The unique name of the worker Auto Scaling Group"
  value       = aws_autoscaling_group.workers_asg.name
}
# -------------------------------
# OUTPUTS - Bastian Host
# -------------------------------
# Output the Bastion's first public IP (if needed for single-bastion reference)
output "bastion_primary_public_ip" {
  description = "Public IP address of the first bastion server"
  value       = aws_instance.bastion[0].public_ip
}

# Output all Bastion public IPs
output "bastion_public_ips" {
  description = "Public IP addresses of all bastion servers"
  value       = [for b in aws_instance.bastion : b.public_ip]
}

# Output all Bastion public DNS names
output "bastion_public_dns" {
  description = "Public DNS names of all bastion servers"
  value       = [for b in aws_instance.bastion : b.public_dns]
}

# Output all Bastion SSH connection strings
output "bastion_ssh_commands" {
  description = "SSH command strings to connect to all bastion servers"
  value = [
    for b in aws_instance.bastion :
    "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/${var.key_name}.pem ubuntu@${b.public_dns}"
  ]
}
