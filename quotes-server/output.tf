
# -------------------------------
# OUTPUTS
# -------------------------------
output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "worker_public_ips" {
  value = [for instance in aws_instance.workers : instance.public_ip]
}

output "k8s_key_pair_name" {
  value = aws_key_pair.k8s_key_pair.key_name
}