
# -------------------------------
# OUTPUTS
# -------------------------------
output "k8s_key_pair_name" {
  description = "The name of the generated key pair"
  value       = aws_key_pair.k8s_key_pair.key_name
}

output "master_public_ips" {
  description = "Public IPs of all Kubernetes master nodes"
  value       = [for m in aws_instance.master : m.public_ip]
}

output "connect_script_path" {
  description = "Path to the generated connect_k8s.sh script"
  value       = "${path.module}/scripts/connect_k8s.sh"
}

output "workers_asg_name" {
  description = "Name of the Auto Scaling group for workers"
  value       = aws_autoscaling_group.workers_asg.name
}
