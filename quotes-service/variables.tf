#######################################
# VPC Configuration
#######################################
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
#######################################
# Node configuration map to control instance type, AMI, and count for each role
#######################################
variable "node_config" {
  description = "Map of node types to their configuration"
  type = map(object({
    instance_type = string
    ami_id        = string
    count         = number
  }))
}

#######################################
# SSH Key
#######################################
variable "key_name" {
  description = "SSH key name used for EC2 instances"
  type        = string
  default     = "k8s-key-pair-new"
}

#######################################
# AMI
#######################################
variable "custom_ami_id" {
  description = "Custom AMI ID to use for the EC2 instances (leave empty to use default AMI)"
  type        = string
}

#######################################
# Instance Types
#######################################
variable "instance_type" {
  description = "Instance type for the Kubernetes worker nodes"
  type        = string
  default     = "t2.micro"
}

variable "controller_instance_type" {
  description = "Instance type for the Kubernetes control plane nodes (controllers)"
  type        = string
  default     = "t3.medium"
}

#######################################
# Kubernetes Controller Configuration
#######################################
variable "k8s_controller_count" {
  description = "Number of Kubernetes control plane nodes (controllers)"
  type        = number
  default     = 3
}

#######################################
# Kubernetes Worker Configuration
#######################################
variable "worker_min_size" {
  description = "Minimum number of worker nodes in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "worker_max_size" {
  description = "Maximum number of worker nodes in the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "worker_desired_capacity" {
  description = "Desired number of worker nodes at launch"
  type        = number
  default     = 2
}

#######################################
# SSH Access Configuration
#######################################
variable "allowed_ssh_cidr" {
  description = "The CIDR block allowed to SSH into the bastion host (e.g. your public IP with /32 mask)"
  type        = string
  default     = "0.0.0.0/0" # ⚠ Replace with your actual IP or provide via -var or tfvars for better security
}
#######################################
