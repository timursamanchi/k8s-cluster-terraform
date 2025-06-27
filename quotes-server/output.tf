
# -------------------------------
# OUTPUTS
# -------------------------------
output "k8s_key_pair_name" {
  description = "The name of the generated key pair"
  value       = aws_key_pair.k8s_key_pair.key_name
}

output "master_public_ip" {
  description = "Public IP of the Kubernetes master node"
  value       = aws_instance.master.public_ip
}

output "worker_public_ips" {
  description = "Public IPs of the Kubernetes worker nodes"
  value       = [for w in aws_instance.workers : w.public_ip]
}

output "connect_script_path" {
  description = "Path to the generated connect_k8s.sh script"
  value       = "${path.module}/scripts/connect_k8s.sh"
}